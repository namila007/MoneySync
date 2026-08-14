import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart'
    show StalePrivacyEpochException;
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule rule() => MappingRule(
    id: 'rule-1',
    name: 'R1',
    enabled: true,
    senderMatcher: SenderMatcher(['BANK ALPHA']),
    walletAccountId: 'account-1',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: 0,
    ruleVersion: 1,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  PreSendContext passingContext({bool capabilityCanCreate = true}) =>
      PreSendContext(
        candidateId: 'candidate-1',
        amountMinor: -4500,
        currencyCode: 'LKR',
        recordDateUtc: DateTime.utc(2026, 7, 18),
        direction: TransactionDirection.debit,
        paymentType: 'debit_card',
        senderNormalized: 'BANK ALPHA',
        confidenceBasisPoints: 9500,
        privacyEpochMatches: true,
        consentCurrent: true,
        connectionConnected: true,
        eligibleTargetAccount: true,
        targetAccountEligibility: WalletAccountEligibility.eligible,
        mappingResolution: MappingResolved(rule()),
        capabilityCanCreate: capabilityCanCreate,
        hasActiveLineage: false,
        hasOwnedRecordLink: false,
      );

  WalletMutationIntent intent() => WalletMutationIntent(
    id: 'mutation-1',
    candidateId: 'candidate-1',
    operation: WalletMutationOperation.create,
    operationRevision: 1,
    lineageGeneration: 1,
    createLineageKey: 'lineage-key-1',
    transactionFingerprint: 'fingerprint-1',
    payload: const <String, Object?>{'amountMinor': -4500},
    state: WalletMutationState.queued,
  );

  test('submits when the gate chain fully passes', () async {
    final writer = _FakeReviewOutboxWriter();
    final useCase = ReviewTransactionUseCase(
      writer: writer,
      policy: const WalletCreateEligibilityPolicy(),
    );

    final result = await useCase.submit(
      context: passingContext(),
      smsEventId: 1,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: now,
      privacyEpoch: 0,
      intent: intent(),
      itemLegRole: WalletItemLegRole.primary,
      itemPayloadCiphertext: '{}',
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );

    expect(result, isA<ReviewSubmitted>());
    expect(writer.submits, 1);
  });

  test('reports the blocking gate and never writes', () async {
    final writer = _FakeReviewOutboxWriter();
    final useCase = ReviewTransactionUseCase(
      writer: writer,
      policy: const WalletCreateEligibilityPolicy(),
    );

    final result = await useCase.submit(
      context: passingContext(capabilityCanCreate: false),
      smsEventId: 1,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: now,
      privacyEpoch: 0,
      intent: intent(),
      itemLegRole: WalletItemLegRole.primary,
      itemPayloadCiphertext: '{}',
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );

    expect(result, isA<ReviewBlocked>());
    expect((result as ReviewBlocked).gateIndex, 7); // CapabilityGate
    expect(writer.submits, 0);
  });

  test('rejects a duplicate active lineage before writing', () async {
    final writer = _FakeReviewOutboxWriter(hasActiveLineageValue: true);
    final useCase = ReviewTransactionUseCase(
      writer: writer,
      policy: const WalletCreateEligibilityPolicy(),
    );

    final result = await useCase.submit(
      context: passingContext(),
      smsEventId: 1,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: now,
      privacyEpoch: 0,
      intent: intent(),
      itemLegRole: WalletItemLegRole.primary,
      itemPayloadCiphertext: '{}',
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );

    expect(result, isA<ReviewDuplicate>());
    expect(writer.submits, 0);
  });

  test('maps a stale privacy epoch to a blocked result', () async {
    final writer = _FakeReviewOutboxWriter(
      error: const StalePrivacyEpochException(),
    );
    final useCase = ReviewTransactionUseCase(
      writer: writer,
      policy: const WalletCreateEligibilityPolicy(),
    );

    final result = await useCase.submit(
      context: passingContext(),
      smsEventId: 1,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: now,
      privacyEpoch: 0,
      intent: intent(),
      itemLegRole: WalletItemLegRole.primary,
      itemPayloadCiphertext: '{}',
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );

    expect(result, isA<ReviewBlocked>());
    expect((result as ReviewBlocked).reason, contains('privacy epoch'));
  });

  test('maps a unique-lineage violation to a duplicate result', () async {
    final writer = _FakeReviewOutboxWriter(
      error: const UniqueLineageViolationException(),
    );
    final useCase = ReviewTransactionUseCase(
      writer: writer,
      policy: const WalletCreateEligibilityPolicy(),
    );

    final result = await useCase.submit(
      context: passingContext(),
      smsEventId: 1,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: now,
      privacyEpoch: 0,
      intent: intent(),
      itemLegRole: WalletItemLegRole.primary,
      itemPayloadCiphertext: '{}',
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );

    expect(result, isA<ReviewDuplicate>());
  });
}

final class _FakeReviewOutboxWriter implements ReviewOutboxWriter {
  _FakeReviewOutboxWriter({this.hasActiveLineageValue = false, this.error});

  bool hasActiveLineageValue;
  Object? error;
  int submits = 0;

  @override
  Future<bool> hasActiveLineage(String candidateId) async =>
      hasActiveLineageValue;

  @override
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
  }) async {
    submits++;
    if (error case final e?) throw e;
  }
}
