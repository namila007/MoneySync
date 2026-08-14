import 'package:money_sync/core/database/app_database.dart'
    show StalePrivacyEpochException;
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// Outcome of a review→outbox submission.
sealed class ReviewSubmissionResult {
  const ReviewSubmissionResult();
}

final class ReviewSubmitted extends ReviewSubmissionResult {
  const ReviewSubmitted();
}

final class ReviewBlocked extends ReviewSubmissionResult {
  const ReviewBlocked(this.gateIndex, this.reason);

  final int gateIndex;
  final String reason;
}

final class ReviewDuplicate extends ReviewSubmissionResult {
  const ReviewDuplicate();
}

/// The atomic write boundary the use case delegates to. Implemented in the
/// data layer with a single Drift transaction so a failure anywhere rolls back
/// the candidate, the outbox row, and the activity event together (M5.9).
abstract interface class ReviewOutboxWriter {
  /// Atomically: (a) write the approved candidate revision, (b) insert the
  /// queued `wallet_mutations` row + its `wallet_mutation_item` row, (c) write
  /// the activity event. Throws on rollback; a partial write is never
  /// observable.
  Future<void> submitAtomically({
    required int smsEventId,
    required CandidateRecordState candidateState,
    required String encryptedPayload,
    required int revision,
    required int createdAtEpochMs,
    required int privacyEpoch,
    required WalletMutationIntent intent,
    required WalletItemLegRole itemLegRole,
    required String itemPayloadCiphertext,
    required ActivityEventCode activityType,
    required ActivityStateTransition safeDetailCode,
    required DecisionTraceCode decisionTraceCode,
  });

  /// True when an active create lineage already exists for [candidateId]
  /// (double-submit / duplicate backstop used before opening the write).
  Future<bool> hasActiveLineage(String candidateId);
}

/// Submits an approved review to the outbox (M5.9). Correctness-critical: this
/// is the only place a Wallet create enters the queue, so double-submit must
/// never produce two active mutation rows for the same candidate.
final class ReviewTransactionUseCase {
  ReviewTransactionUseCase({
    required this._writer,
    required this._policy,
  });

  final ReviewOutboxWriter _writer;
  final WalletCreateEligibilityPolicy _policy;

  /// Runs the pre-send gate chain; only when it fully passes opens the atomic
  /// outbox write. Re-checks lineage inside the writer so a concurrent second
  /// submit is rejected, not silently duplicated.
  Future<ReviewSubmissionResult> submit({
    required PreSendContext context,
    required int smsEventId,
    required CandidateRecordState candidateState,
    required String encryptedPayload,
    required int revision,
    required int createdAtEpochMs,
    required int privacyEpoch,
    required WalletMutationIntent intent,
    required WalletItemLegRole itemLegRole,
    required String itemPayloadCiphertext,
    required ActivityEventCode activityType,
    required ActivityStateTransition safeDetailCode,
    required DecisionTraceCode decisionTraceCode,
  }) async {
    final evaluation = _policy.evaluate(context);
    if (!evaluation.allowed) {
      return ReviewBlocked(
        evaluation.firstBlockedGateIndex,
        evaluation.firstBlockReason ?? 'Blocked by pre-send gate.',
      );
    }

    final alreadyActive = await _writer.hasActiveLineage(intent.candidateId);
    if (alreadyActive) return const ReviewDuplicate();

    try {
      await _writer.submitAtomically(
        smsEventId: smsEventId,
        candidateState: candidateState,
        encryptedPayload: encryptedPayload,
        revision: revision,
        createdAtEpochMs: createdAtEpochMs,
        privacyEpoch: privacyEpoch,
        intent: intent,
        itemLegRole: itemLegRole,
        itemPayloadCiphertext: itemPayloadCiphertext,
        activityType: activityType,
        safeDetailCode: safeDetailCode,
        decisionTraceCode: decisionTraceCode,
      );
      return const ReviewSubmitted();
    } on StalePrivacyEpochException {
      return const ReviewBlocked(0, 'Stale privacy epoch. Re-confirm before sending.');
    } on UniqueLineageViolationException {
      return const ReviewDuplicate();
    }
  }
}

/// Raised by the data layer when the DB-level unique lineage index rejects the
/// insert (the second concurrent submit loses; no partial row is observable).
final class UniqueLineageViolationException implements Exception {
  const UniqueLineageViolationException();
}
