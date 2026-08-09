import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_ingestion/domain/financial_message_filter.dart';
import 'package:money_sync/features/sms_ingestion/domain/manual_input_validation.dart';

enum IngestionSource { manualPaste, shareIntent, historySelection }

sealed class ManualIngestOutcome {
  const ManualIngestOutcome();
}

final class ManualIngestStored extends ManualIngestOutcome {
  const ManualIngestStored({required this.eventId});
  final int eventId;
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
  const IngestManualMessage({required this.database});
  final AppDatabase database;

  Future<ManualIngestOutcome> call({
    required String rawBody,
    required String rawSender,
    required IngestionSource source,
    required bool userOverrodeFilter,
    required int epochMs,
    required int privacyEpoch,
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

    final sourceKey =
        '${accepted.normalizedSender}|${accepted.normalizedBody.hashCode}|$epochMs';
    final safeSourceKey = _hashToHex(sourceKey);

    try {
      final result = await database.insertSmsEventIfAbsent(
        sourceKey: safeSourceKey,
        senderHash: accepted.normalizedSender,
        encryptedBody:
            triage == MessageTriage.otpOnly || triage == MessageTriage.unrelated
            ? null
            : accepted.normalizedBody,
        redactedBody: accepted.redactedPreview,
        ingestionSource: _sourceString(source),
        receivedAtEpochMs: epochMs,
        status: 'review',
        privacyEpoch: privacyEpoch,
      );

      if (result.inserted) {
        return ManualIngestStored(eventId: result.id);
      }
      return ManualIngestAlreadyPresent(result.id);
    } on StalePrivacyEpochException {
      return const ManualIngestBlockedByEpoch();
    }
  }
}

String _sourceString(IngestionSource source) => switch (source) {
  IngestionSource.manualPaste => 'manual_paste',
  IngestionSource.shareIntent => 'share_intent',
  IngestionSource.historySelection => 'history_selection',
};

String _hashToHex(String input) {
  var hash = 0;
  for (var i = 0; i < input.length; i++) {
    hash = 0x1fffffff & (hash + input.codeUnitAt(i));
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash = hash ^ (hash >> 6);
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return hash.toRadixString(16).padLeft(8, '0');
}
