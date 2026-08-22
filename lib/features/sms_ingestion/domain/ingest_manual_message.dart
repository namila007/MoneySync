import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:money_sync/core/database/app_database.dart'
    hide TransactionCandidate;
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/sms_ingestion/domain/financial_message_filter.dart';
import 'package:money_sync/features/sms_ingestion/domain/manual_input_validation.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

enum IngestionSource { manualPaste, shareIntent, historySelection }

sealed class ManualIngestOutcome {
  const ManualIngestOutcome();
}

final class ManualIngestStored extends ManualIngestOutcome {
  const ManualIngestStored({
    required this.eventId,
    this.duplicateSuspected = false,
  });

  final int eventId;

  /// Same content hash as an existing row, but a distinct canonical key —
  /// stored anyway; surfaced as a review hint, never a drop (M4.14 WP4).
  final bool duplicateSuspected;
}

final class ManualIngestAlreadyPresent extends ManualIngestOutcome {
  const ManualIngestAlreadyPresent(this.eventId);
  final int eventId;
}

final class ManualIngestFiltered extends ManualIngestOutcome {
  const ManualIngestFiltered(this.triage);
  final MessageTriage triage;
}

final class ManualIngestRejected extends ManualIngestOutcome {
  const ManualIngestRejected(this.reason);
  final ManualInputRejection reason;
}

final class ManualIngestBlockedByEpoch extends ManualIngestOutcome {
  const ManualIngestBlockedByEpoch();
}

final class IngestManualMessage {
  const IngestManualMessage({
    required this.database,
    this.interpret,
    required this.identitySigner,
  });

  final AppDatabase database;

  /// Optional interpretation hook. When provided and the message is stored,
  /// a successful interpretation writes a candidate + decision trace +
  /// activity event atomically. ponytail: wired by the caller; the registry
  /// and full pack set arrive with M4.6.
  final Future<InterpretationResult> Function({
    required String rawBody,
    required String sender,
    required DateTime receivedAtUtc,
  })?
  interpret;

  /// Keyed-HMAC boundary for canonical identity (M4.14 WP4). Required: a
  /// message must never be stored under a weak hash. Wired by the caller with
  /// the platform Keystore-backed implementation.
  final SourceIdentitySigner identitySigner;

  Future<ManualIngestOutcome> call({
    required String rawBody,
    required String rawSender,
    required IngestionSource source,
    required bool userOverrodeFilter,
    required int epochMs,
    required int privacyEpoch,
    bool recordImportActivity = true,
    bool recordCandidateActivity = true,
  }) async {
    final validation = validateManualInput(rawBody, rawSender: rawSender);
    if (validation case ManualInputRejected(:final reason)) {
      return ManualIngestRejected(reason);
    }
    final accepted = validation as ManualInputAccepted;

    final triage = FinancialMessageFilter().call(accepted.normalizedBody);

    if (!userOverrodeFilter) {
      if (triage == MessageTriage.otpOnly ||
          triage == MessageTriage.unrelated) {
        return ManualIngestFiltered(triage);
      }
    }

    // Canonical identity: keyed HMAC over version, normalized sender,
    // normalized body, and the provider timestamp. The 29-bit hand-rolled
    // hash is gone; the content hash is a review hint only (M4.14 WP4).
    final identity = await _identify(accepted, epochMs);
    final contentSha256 = sha256
        .convert(
          utf8.encode(
            '${accepted.normalizedSender}|${accepted.normalizedBody}',
          ),
        )
        .toString();

    try {
      final result = await database.insertSmsEventIfAbsent(
        sourceKey: identity.value,
        senderKey: accepted.normalizedSender,
        senderDisplay: _senderDisplay(rawSender, accepted.normalizedSender),
        encryptedBody:
            triage == MessageTriage.otpOnly || triage == MessageTriage.unrelated
            ? null
            : accepted.normalizedBody,
        redactedBody: accepted.redactedPreview,
        ingestionSource: _sourceString(source),
        receivedAtEpochMs: epochMs,
        status: SmsEventStatus.review,
        privacyEpoch: privacyEpoch,
        captureCanonicalizationVersion: identity.canonicalizationVersion,
        contentSha256: contentSha256,
      );

      if (result.inserted) {
        // Batch imports (M4.15 WP3) suppress the per-message event and record
        // one aggregate event instead — see ImportSmsHistory.
        if (recordImportActivity) {
          await database.insertActivity(
            activityType: ActivityEventCode.messageImported,
            safeDetailCode: ActivityStateTransition.logEvent,
            occurredAtEpochMs: epochMs,
            privacyEpoch: privacyEpoch,
            detailMessage: 'Message imported',
          );
        }
        await _interpretAndStore(
          eventId: result.id,
          normalizedBody: accepted.normalizedBody,
          normalizedSender: accepted.normalizedSender,
          epochMs: epochMs,
          privacyEpoch: privacyEpoch,
          recordActivity: recordCandidateActivity,
        );
        return ManualIngestStored(
          eventId: result.id,
          duplicateSuspected: result.duplicateSuspected,
        );
      }
      return ManualIngestAlreadyPresent(result.id);
    } on StalePrivacyEpochException {
      return const ManualIngestBlockedByEpoch();
    }
  }

  Future<SourceMessageKey> _identify(
    ManualInputAccepted accepted,
    int epochMs,
  ) {
    return SourceMessageCanonicalizer(signer: identitySigner).identify(
      SmsSourceMessage(
        sender: accepted.normalizedSender,
        body: accepted.normalizedBody,
        receivedAtUtc: DateTime.fromMillisecondsSinceEpoch(
          epochMs,
          isUtc: true,
        ),
        ingestionSource: SmsIngestionSource.historySelection,
      ),
    );
  }

  String _senderDisplay(String rawSender, String normalizedSender) {
    final trimmed = rawSender.trim();
    return trimmed.isEmpty ? normalizedSender : trimmed;
  }

  Future<void> _interpretAndStore({
    required int eventId,
    required String normalizedBody,
    required String normalizedSender,
    required int epochMs,
    required int privacyEpoch,
    bool recordActivity = true,
  }) async {
    final interpret = this.interpret;
    if (interpret == null) return;

    InterpretationResult result;
    try {
      result = await interpret(
        rawBody: normalizedBody,
        sender: normalizedSender,
        receivedAtUtc: DateTime.fromMillisecondsSinceEpoch(
          epochMs,
          isUtc: true,
        ),
      );
    } catch (_) {
      // Interpretation is best-effort: a parser failure must not fail the
      // ingest. The message stays stored for review.
      return;
    }
    if (result is! InterpretedCandidate) return;

    final candidate = result.candidate;
    await database.insertCandidateAndActivityAtomically(
      smsEventId: eventId,
      candidateState: CandidateRecordState.needsReview,
      encryptedPayload: _candidatePayload(candidate),
      revision: 1,
      createdAtEpochMs: epochMs,
      activityType: ActivityEventCode.candidateNeedsReview,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.parsedComplete,
      privacyEpoch: privacyEpoch,
      recordActivity: recordActivity,
    );
  }

  String _candidatePayload(TransactionCandidate candidate) {
    final directionSign = candidate.direction == TransactionDirection.credit
        ? 1
        : -1;
    return '{"kind":"${candidate.kind.name}",'
        '"direction":"${candidate.direction.name}",'
        '"lifecycle":"${candidate.lifecycle.name}",'
        '"amountMinor":${candidate.originalAmount.minorUnits * directionSign},'
        '"amountCurrency":"${candidate.originalAmount.currency.code}",'
        '"transactionAtUtc":"${candidate.transactionAtUtc.toIso8601String()}",'
        '"confidenceBasisPoints":${candidate.confidence.basisPoints},'
        '"requiresReview":${candidate.requiresReview}}';
  }
}

String _sourceString(IngestionSource source) => switch (source) {
  IngestionSource.manualPaste => 'manual_paste',
  IngestionSource.shareIntent => 'share_intent',
  IngestionSource.historySelection => 'history_selection',
};
