import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/core/money/currency.dart';
import 'package:money_sync/core/money/money.dart';
import 'package:money_sync/core/time/source_date_evidence.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/auto_create_or_defer.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

const _capsWithAutoSync = AppCapabilities.of(<AppCapability>{
  AppCapability.smsPermission,
  AppCapability.walletCreate,
  AppCapability.automaticSync,
});

void main() {
  const now = 1_700_000_000_000;

  MappingRule _rule({
    required String id,
    MappingSyncMode syncMode = MappingSyncMode.review,
    int? minConfidenceBasisPoints,
  }) => MappingRule(
    id: id,
    name: 'Rule $id',
    enabled: true,
    senderMatcher: SenderMatcher(['SAMPATH BANK']),
    walletAccountId: 'wallet-$id',
    paymentType: 'debit_card',
    syncMode: syncMode,
    priority: 0,
    minConfidenceBasisPoints: minConfidenceBasisPoints,
    ruleVersion: 1,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  PreSendContext _passingContext({
    MappingResolution? resolution,
    int confidenceBasisPoints = 9500,
  }) => PreSendContext(
    candidateId: 'candidate-1',
    amountMinor: -150000,
    currencyCode: 'LKR',
    recordDateUtc: DateTime.now().toUtc(),
    direction: TransactionDirection.debit,
    paymentType: 'debit_card',
    senderNormalized: 'SAMPATH BANK',
    confidenceBasisPoints: confidenceBasisPoints,
    privacyEpochMatches: true,
    consentCurrent: true,
    connectionConnected: true,
    eligibleTargetAccount: true,
    targetAccountEligibility: WalletAccountEligibility.eligible,
    mappingResolution: resolution ?? const MappingUnmatched(),
    capabilityCanCreate: true,
    hasActiveLineage: false,
    hasOwnedRecordLink: false,
  );

  group('AutoCreateOrDefer', () {
    group('deferral paths', () {
      test(
        'auto-create toggle off -> DeferredToReview, no writer call',
        () async {
          final writer = _SpyWriter();
          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: false,
            resolveRules: (_) async => [
              _rule(id: 'r1', syncMode: MappingSyncMode.automatic),
            ],
            buildPreSendContext: (_) async => _passingContext(
              resolution: MappingResolved(
                _rule(id: 'r1', syncMode: MappingSyncMode.automatic),
              ),
            ),
          );

          final result = await autoCreate(
            _candidate(),
            senderNormalized: 'SAMPATH BANK',
          );

          expect(result, isA<DeferredToReview>());
          expect((result as DeferredToReview).reason, 'auto_create_disabled');
          expect(writer.calls, isEmpty);
        },
      );

      test('capability off -> DeferredToReview, no writer call', () async {
        final writer = _SpyWriter();
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: const AppCapabilities.m0(),
          autoCreateEnabled: true,
          resolveRules: (_) async => [
            _rule(id: 'r1', syncMode: MappingSyncMode.automatic),
          ],
          buildPreSendContext: (_) async => _passingContext(
            resolution: MappingResolved(
              _rule(id: 'r1', syncMode: MappingSyncMode.automatic),
            ),
          ),
        );

        final result = await autoCreate(
          _candidate(),
          senderNormalized: 'SAMPATH BANK',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, 'auto_create_disabled');
        expect(writer.calls, isEmpty);
      });

      test('unmatched rule -> DeferredToReview, no writer call', () async {
        final writer = _SpyWriter();
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [],
          buildPreSendContext: (_) async =>
              _passingContext(resolution: const MappingUnmatched()),
        );

        final result = await autoCreate(
          _candidate(),
          senderNormalized: 'SAMPATH BANK',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, contains('unmatched'));
        expect(writer.calls, isEmpty);
      });

      test('ambiguous rule -> DeferredToReview, no writer call', () async {
        final writer = _SpyWriter();
        final r1 = _rule(id: 'r1', syncMode: MappingSyncMode.automatic);
        final r2 = _rule(id: 'r2', syncMode: MappingSyncMode.automatic);
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [r1, r2],
          buildPreSendContext: (_) async =>
              _passingContext(resolution: MappingAmbiguous([r1, r2])),
        );

        final result = await autoCreate(
          _candidate(),
          senderNormalized: 'SAMPATH BANK',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, contains('ambiguous'));
        expect(writer.calls, isEmpty);
      });

      test('manual-mode rule -> DeferredToReview, no writer call', () async {
        final writer = _SpyWriter();
        final rule = _rule(id: 'r1', syncMode: MappingSyncMode.manual);
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [rule],
          buildPreSendContext: (_) async =>
              _passingContext(resolution: MappingResolved(rule)),
        );

        final result = await autoCreate(
          _candidate(),
          senderNormalized: 'SAMPATH BANK',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, 'rule_not_automatic');
        expect(writer.calls, isEmpty);
      });

      test(
        'below confidence floor -> DeferredToReview, no writer call',
        () async {
          final writer = _SpyWriter();
          final rule = _rule(
            id: 'r1',
            syncMode: MappingSyncMode.automatic,
            minConfidenceBasisPoints: 9000,
          );
          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: true,
            resolveRules: (_) async => [rule],
            buildPreSendContext: (_) async => _passingContext(
              resolution: MappingResolved(rule),
              confidenceBasisPoints: 7000,
            ),
          );

          final result = await autoCreate(
            _lowConfidenceCandidate(),
            senderNormalized: 'SAMPATH BANK',
          );

          expect(result, isA<DeferredToReview>());
          expect(writer.calls, isEmpty);
        },
      );

      test(
        'gate blocked (wallet disconnected) -> DeferredToReview, no writer call',
        () async {
          final writer = _SpyWriter();
          final rule = _rule(id: 'r1', syncMode: MappingSyncMode.automatic);
          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: true,
            resolveRules: (_) async => [rule],
            buildPreSendContext: (_) async => PreSendContext(
              candidateId: 'candidate-1',
              amountMinor: -150000,
              currencyCode: 'LKR',
              recordDateUtc: DateTime.now().toUtc(),
              direction: TransactionDirection.debit,
              paymentType: 'debit_card',
              senderNormalized: 'SAMPATH BANK',
              confidenceBasisPoints: 9500,
              privacyEpochMatches: true,
              consentCurrent: true,
              connectionConnected: false,
              eligibleTargetAccount: true,
              targetAccountEligibility: WalletAccountEligibility.eligible,
              mappingResolution: MappingResolved(rule),
              capabilityCanCreate: true,
              hasActiveLineage: false,
              hasOwnedRecordLink: false,
            ),
          );

          final result = await autoCreate(
            _candidate(),
            senderNormalized: 'SAMPATH BANK',
          );

          expect(result, isA<DeferredToReview>());
          expect(
            (result as DeferredToReview).reason,
            contains('Wallet is not connected'),
          );
          expect(writer.calls, isEmpty);
        },
      );

      test(
        'writer throws UniqueLineageViolationException -> DeferredToReview',
        () async {
          final writer = _SpyWriter(
            throwOnSubmit: const UniqueLineageViolationException(),
          );
          final rule = _rule(id: 'r1', syncMode: MappingSyncMode.automatic);
          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: true,
            resolveRules: (_) async => [rule],
            buildPreSendContext: (_) async =>
                _passingContext(resolution: MappingResolved(rule)),
          );

          final result = await autoCreate(
            _candidate(),
            senderNormalized: 'SAMPATH BANK',
          );

          expect(result, isA<DeferredToReview>());
          expect(writer.calls.length, 1);
        },
      );
    });

    group('success path', () {
      test('matched automatic rule, confidence at/above floor, all gates pass '
          '-> AutoCreated, one writer call, one activity event', () async {
        final writer = _SpyWriter();
        final rule = _rule(
          id: 'r1',
          syncMode: MappingSyncMode.automatic,
          minConfidenceBasisPoints: 9000,
        );
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [rule],
          buildPreSendContext: (_) async => _passingContext(
            resolution: MappingResolved(rule),
            confidenceBasisPoints: 9500,
          ),
        );

        final result = await autoCreate(
          _candidate(),
          senderNormalized: 'SAMPATH BANK',
        );

        expect(result, isA<AutoCreated>());
        final created = result as AutoCreated;
        expect(created.ruleName, 'Rule r1');
        expect(created.mutationId, isNotEmpty);
        expect(writer.calls.length, 1);
        expect(writer.lastActivityType, ActivityEventCode.walletRecordQueued);
        expect(writer.lastDetailMessage, contains('Rule r1'));
      });
    });
  });
}

TransactionCandidate _candidate() => TransactionCandidate(
  id: 'candidate-1',
  sourceMessageKey: 'key-1',
  kind: TransactionKind.expense,
  direction: TransactionDirection.debit,
  lifecycle: FinancialLifecycle.posted,
  originalAmount: Money(
    minorUnits: -150000,
    currency: Currency(code: 'LKR', decimalDigits: 2),
  ),
  transactionAtUtc: DateTime.now().toUtc(),
  confidence: CandidateConfidence(basisPoints: 9500),
  reviewReasons: const {},
  provenance: CandidateProvenance(
    parserRuleId: 'rule-1',
    parserRuleVersion: '1.0',
    captureCanonicalizationVersion: 2,
    sourceDateEvidence: SourceDateEvidence(
      instantUtc: DateTime.now().toUtc(),
      source: DateEvidenceSource.receivedAtUtc,
      originalValue: 'synthetic',
      parsingContext: SourceTimeZoneContext.utc,
    ),
  ),
  counterParty: 'Test Merchant',
);

TransactionCandidate _lowConfidenceCandidate() => TransactionCandidate(
  id: 'candidate-1',
  sourceMessageKey: 'key-1',
  kind: TransactionKind.expense,
  direction: TransactionDirection.debit,
  lifecycle: FinancialLifecycle.posted,
  originalAmount: Money(
    minorUnits: -150000,
    currency: Currency(code: 'LKR', decimalDigits: 2),
  ),
  transactionAtUtc: DateTime.now().toUtc(),
  confidence: CandidateConfidence(basisPoints: 7000),
  reviewReasons: const {},
  provenance: CandidateProvenance(
    parserRuleId: 'rule-1',
    parserRuleVersion: '1.0',
    captureCanonicalizationVersion: 2,
    sourceDateEvidence: SourceDateEvidence(
      instantUtc: DateTime.now().toUtc(),
      source: DateEvidenceSource.receivedAtUtc,
      originalValue: 'synthetic',
      parsingContext: SourceTimeZoneContext.utc,
    ),
  ),
  counterParty: 'Test Merchant',
);

class _SpyWriter implements ReviewOutboxWriter {
  _SpyWriter({this.throwOnSubmit});

  final Exception? throwOnSubmit;
  final List<int> calls = [];
  ActivityEventCode? lastActivityType;
  String? lastDetailMessage;

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
    String? detailMessage,
  }) async {
    calls.add(smsEventId);
    lastActivityType = activityType;
    lastDetailMessage = detailMessage;
    if (throwOnSubmit != null) throw throwOnSubmit!;
  }

  @override
  Future<bool> hasActiveLineage(String candidateId) async => false;
}
