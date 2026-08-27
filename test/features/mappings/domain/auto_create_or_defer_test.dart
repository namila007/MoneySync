import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
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

  MappingRule makeRule({
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

  PreSendContext passingContext({
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
              makeRule(id: 'r1', syncMode: MappingSyncMode.automatic),
            ],
            buildPreSendContext: (_) async => passingContext(
              resolution: MappingResolved(
                makeRule(id: 'r1', syncMode: MappingSyncMode.automatic),
              ),
            ),
          );

          final result = await autoCreate(
            makeCandidate(),
            senderNormalized: 'SAMPATH BANK',
            smsEventId: 42,
            candidatePayload: '{}',
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
            makeRule(id: 'r1', syncMode: MappingSyncMode.automatic),
          ],
          buildPreSendContext: (_) async => passingContext(
            resolution: MappingResolved(
              makeRule(id: 'r1', syncMode: MappingSyncMode.automatic),
            ),
          ),
        );

        final result = await autoCreate(
          makeCandidate(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 43,
          candidatePayload: '{}',
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
              passingContext(resolution: const MappingUnmatched()),
        );

        final result = await autoCreate(
          makeCandidate(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 44,
          candidatePayload: '{}',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, contains('unmatched'));
        expect(writer.calls, isEmpty);
      });

      test('ambiguous rule -> DeferredToReview, no writer call', () async {
        final writer = _SpyWriter();
        final r1 = makeRule(id: 'r1', syncMode: MappingSyncMode.automatic);
        final r2 = makeRule(id: 'r2', syncMode: MappingSyncMode.automatic);
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [r1, r2],
          buildPreSendContext: (_) async =>
              passingContext(resolution: MappingAmbiguous([r1, r2])),
        );

        final result = await autoCreate(
          makeCandidate(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 45,
          candidatePayload: '{}',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, contains('ambiguous'));
        expect(writer.calls, isEmpty);
      });

      test('manual-mode rule -> DeferredToReview, no writer call', () async {
        final writer = _SpyWriter();
        final rule = makeRule(id: 'r1', syncMode: MappingSyncMode.manual);
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [rule],
          buildPreSendContext: (_) async =>
              passingContext(resolution: MappingResolved(rule)),
        );

        final result = await autoCreate(
          makeCandidate(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 46,
          candidatePayload: '{}',
        );

        expect(result, isA<DeferredToReview>());
        expect((result as DeferredToReview).reason, 'rule_not_automatic');
        expect(writer.calls, isEmpty);
      });

      test(
        'below confidence floor -> DeferredToReview, no writer call',
        () async {
          final writer = _SpyWriter();
          final rule = makeRule(
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
            buildPreSendContext: (_) async => passingContext(
              resolution: MappingResolved(rule),
              confidenceBasisPoints: 7000,
            ),
          );

          final result = await autoCreate(
            makeLowConfidenceCandidate(),
            senderNormalized: 'SAMPATH BANK',
            smsEventId: 47,
            candidatePayload: '{}',
          );

          expect(result, isA<DeferredToReview>());
          expect(writer.calls, isEmpty);
        },
      );

      test('gate blocked (wallet disconnected) -> DeferredToReview', () async {
        final writer = _SpyWriter();
        final rule = makeRule(id: 'r1', syncMode: MappingSyncMode.automatic);
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
          makeCandidate(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 48,
          candidatePayload: '{}',
        );

        expect(result, isA<DeferredToReview>());
        expect(
          (result as DeferredToReview).reason,
          contains('Wallet is not connected'),
        );
        expect(writer.calls, isEmpty);
      });

      test(
        'writer throws UniqueLineageViolationException -> DeferredToReview',
        () async {
          final writer = _SpyWriter(
            throwOnSubmit: const UniqueLineageViolationException(),
          );
          final rule = makeRule(id: 'r1', syncMode: MappingSyncMode.automatic);
          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: true,
            resolveRules: (_) async => [rule],
            buildPreSendContext: (_) async =>
                passingContext(resolution: MappingResolved(rule)),
          );

          final result = await autoCreate(
            makeCandidate(),
            senderNormalized: 'SAMPATH BANK',
            smsEventId: 49,
            candidatePayload: '{}',
          );

          expect(result, isA<DeferredToReview>());
          expect(writer.calls.length, 1);
        },
      );
    });

    group('success path', () {
      test(
        'matched automatic rule -> AutoCreated, real smsEventId and payload',
        () async {
          final writer = _SpyWriter();
          final rule = makeRule(
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
            buildPreSendContext: (_) async => passingContext(
              resolution: MappingResolved(rule),
              confidenceBasisPoints: 9500,
            ),
          );

          final result = await autoCreate(
            makeCandidate(),
            senderNormalized: 'SAMPATH BANK',
            smsEventId: 50,
            candidatePayload: '{"test":true}',
          );

          expect(result, isA<AutoCreated>());
          final created = result as AutoCreated;
          expect(created.ruleName, 'Rule r1');
          expect(created.mutationId, isNotEmpty);
          expect(writer.calls.length, 1);
          expect(writer.calls.first, 50);
          expect(writer.lastEncryptedPayload, '{"test":true}');
          expect(writer.lastItemPayloadCiphertext, '{"test":true}');
          expect(writer.lastActivityType, ActivityEventCode.walletRecordQueued);
          expect(writer.lastDetailMessage, contains('Rule r1'));
        },
      );
    });

    group('Bug 1 fix: distinct smsEventIds produce separate rows', () {
      test('two auto-creates with different smsEventIds produce distinct '
          'calls with separate IDs and payloads', () async {
        final writer = _SpyWriter();
        final rule = makeRule(id: 'r1', syncMode: MappingSyncMode.automatic);
        final autoCreate = AutoCreateOrDefer(
          eligibilityPolicy: const WalletCreateEligibilityPolicy(),
          outboxWriter: writer,
          capabilities: _capsWithAutoSync,
          autoCreateEnabled: true,
          resolveRules: (_) async => [rule],
          buildPreSendContext: (_) async =>
              passingContext(resolution: MappingResolved(rule)),
        );

        final result1 = await autoCreate(
          makeCandidate(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 100,
          candidatePayload: '{"amount":-150000}',
        );
        final result2 = await autoCreate(
          makeCandidate2(),
          senderNormalized: 'SAMPATH BANK',
          smsEventId: 200,
          candidatePayload: '{"amount":-250000}',
        );

        expect(result1, isA<AutoCreated>());
        expect(result2, isA<AutoCreated>());

        expect(writer.calls.length, 2);
        expect(writer.calls[0], 100);
        expect(writer.calls[1], 200);
        expect(writer.calls[0], isNot(writer.calls[1]));
        expect(writer.lastEncryptedPayload, '{"amount":-250000}');
        expect(writer.lastItemPayloadCiphertext, '{"amount":-250000}');
      });
    });

    group(
      'end-to-end: real sender + real eligibility produces AutoCreated',
      () {
        test('real sender string matches rule, eligible account from catalog '
            '-> AutoCreated (not DeferredToReview)', () async {
          final writer = _SpyWriter();
          final rule = makeRule(
            id: 'r1',
            syncMode: MappingSyncMode.automatic,
            minConfidenceBasisPoints: 9000,
          );
          // Simulate catalog lookup: account from the matched rule.
          final catalogAccount = WalletAccount(
            id: 'wallet-r1',
            name: 'Sampath Vishwa',
            currencyCode: 'LKR',
            isArchived: false,
            isBankSynced: false,
            isWritable: true,
          );
          expect(catalogAccount.eligibility, WalletAccountEligibility.eligible);

          final resolver = MappingRuleResolver(rules: [rule]);
          final candidate = makeCandidate();
          final realSender = 'SAMPATH BANK';
          final resolution = resolver.resolve(
            MappingResolutionInput(
              senderNormalized: realSender,
              confidenceBasisPoints: candidate.confidence.basisPoints,
              merchantNormalized: candidate.counterParty ?? '',
              direction: candidate.direction,
            ),
          );
          expect(resolution, isA<MappingResolved>());

          // Compute eligibility the same way the fixed controllers do.
          WalletAccount? targetAccount;
          if (resolution case MappingResolved(:final rule)) {
            if (rule.walletAccountId == catalogAccount.id) {
              targetAccount = catalogAccount;
            }
          }

          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: true,
            resolveRules: (_) async => [rule],
            buildPreSendContext: (_) async => PreSendContext(
              candidateId: 'candidate-1',
              amountMinor: candidate.originalAmount.minorUnits,
              currencyCode: candidate.originalAmount.currency.code,
              recordDateUtc: candidate.transactionAtUtc,
              direction: candidate.direction,
              paymentType: 'debit_card',
              senderNormalized: realSender,
              confidenceBasisPoints: candidate.confidence.basisPoints,
              privacyEpochMatches: true,
              consentCurrent: true,
              connectionConnected: true,
              eligibleTargetAccount:
                  targetAccount != null &&
                  targetAccount.isWritable &&
                  targetAccount.eligibility ==
                      WalletAccountEligibility.eligible,
              targetAccountEligibility:
                  targetAccount?.eligibility ??
                  WalletAccountEligibility.missingRequiredFields,
              mappingResolution: resolution,
              capabilityCanCreate: true,
              hasActiveLineage: false,
              hasOwnedRecordLink: false,
            ),
          );

          final outcome = await autoCreate(
            candidate,
            senderNormalized: realSender,
            smsEventId: 51,
            candidatePayload: '{"test":true}',
          );

          expect(outcome, isA<AutoCreated>());
          expect((outcome as AutoCreated).ruleName, 'Rule r1');
          expect(writer.calls.length, 1);
        });

        test('ineligible account from catalog -> DeferredToReview '
            '(gate 4 blocks)', () async {
          final writer = _SpyWriter();
          final rule = makeRule(id: 'r1', syncMode: MappingSyncMode.automatic);
          // Account exists but is archived -> not eligible.
          final catalogAccount = WalletAccount(
            id: 'wallet-r1',
            name: 'Old Account',
            currencyCode: 'LKR',
            isArchived: true,
            isBankSynced: false,
            isWritable: true,
          );
          expect(catalogAccount.eligibility, WalletAccountEligibility.archived);

          final resolver = MappingRuleResolver(rules: [rule]);
          final candidate = makeCandidate();
          final realSender = 'SAMPATH BANK';
          final resolution = resolver.resolve(
            MappingResolutionInput(
              senderNormalized: realSender,
              confidenceBasisPoints: candidate.confidence.basisPoints,
              merchantNormalized: candidate.counterParty ?? '',
              direction: candidate.direction,
            ),
          );

          WalletAccount? targetAccount;
          if (resolution case MappingResolved(:final rule)) {
            if (rule.walletAccountId == catalogAccount.id) {
              targetAccount = catalogAccount;
            }
          }

          final autoCreate = AutoCreateOrDefer(
            eligibilityPolicy: const WalletCreateEligibilityPolicy(),
            outboxWriter: writer,
            capabilities: _capsWithAutoSync,
            autoCreateEnabled: true,
            resolveRules: (_) async => [rule],
            buildPreSendContext: (_) async => PreSendContext(
              candidateId: 'candidate-1',
              amountMinor: candidate.originalAmount.minorUnits,
              currencyCode: candidate.originalAmount.currency.code,
              recordDateUtc: candidate.transactionAtUtc,
              direction: candidate.direction,
              paymentType: 'debit_card',
              senderNormalized: realSender,
              confidenceBasisPoints: candidate.confidence.basisPoints,
              privacyEpochMatches: true,
              consentCurrent: true,
              connectionConnected: true,
              eligibleTargetAccount:
                  targetAccount != null &&
                  targetAccount.isWritable &&
                  targetAccount.eligibility ==
                      WalletAccountEligibility.eligible,
              targetAccountEligibility:
                  targetAccount?.eligibility ??
                  WalletAccountEligibility.missingRequiredFields,
              mappingResolution: resolution,
              capabilityCanCreate: true,
              hasActiveLineage: false,
              hasOwnedRecordLink: false,
            ),
          );

          final outcome = await autoCreate(
            candidate,
            senderNormalized: realSender,
            smsEventId: 52,
            candidatePayload: '{}',
          );

          expect(outcome, isA<DeferredToReview>());
          expect(writer.calls, isEmpty);
        });
      },
    );
  });

  group('logging', () {
    test('logs error when outbox write fails with generic exception', () async {
      final writer = _SpyWriter(throwOnSubmit: Exception('db write failed'));
      final rule = makeRule(id: 'r1', syncMode: MappingSyncMode.automatic);
      final autoCreate = AutoCreateOrDefer(
        eligibilityPolicy: const WalletCreateEligibilityPolicy(),
        outboxWriter: writer,
        capabilities: _capsWithAutoSync,
        autoCreateEnabled: true,
        resolveRules: (_) async => [rule],
        buildPreSendContext: (_) async =>
            passingContext(resolution: MappingResolved(rule)),
      );

      final captured = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(captured.add);
      addTearDown(sub.cancel);

      final result = await autoCreate(
        makeCandidate(),
        senderNormalized: 'SAMPATH BANK',
        smsEventId: 60,
        candidatePayload: '{}',
      );

      expect(result, isA<DeferredToReview>());
      expect((result as DeferredToReview).reason, 'write_failed');

      expect(
        captured.any(
          (r) =>
              r.level == Level.SEVERE &&
              r.loggerName == 'mappings.auto_create' &&
              r.message == 'Write failed',
        ),
        isTrue,
      );
    });
  });
}

TransactionCandidate makeCandidate({
  String id = 'candidate-1',
  String sourceMessageKey = 'key-1',
  int minorUnits = -150000,
  int basisPoints = 9500,
  String counterParty = 'Test Merchant',
}) => TransactionCandidate(
  id: id,
  sourceMessageKey: sourceMessageKey,
  kind: TransactionKind.expense,
  direction: TransactionDirection.debit,
  lifecycle: FinancialLifecycle.posted,
  originalAmount: Money(
    minorUnits: minorUnits,
    currency: Currency(code: 'LKR', decimalDigits: 2),
  ),
  transactionAtUtc: DateTime.now().toUtc(),
  confidence: CandidateConfidence(basisPoints: basisPoints),
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
  counterParty: counterParty,
);

TransactionCandidate makeCandidate2() => makeCandidate(
  id: 'candidate-2',
  sourceMessageKey: 'key-2',
  minorUnits: -250000,
  counterParty: 'Other Merchant',
);

TransactionCandidate makeLowConfidenceCandidate() =>
    makeCandidate(basisPoints: 7000);

class _SpyWriter implements ReviewOutboxWriter {
  _SpyWriter({this.throwOnSubmit});

  final Exception? throwOnSubmit;
  final List<int> calls = [];
  ActivityEventCode? lastActivityType;
  String? lastDetailMessage;
  String? lastEncryptedPayload;
  String? lastItemPayloadCiphertext;

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
    lastEncryptedPayload = encryptedPayload;
    lastItemPayloadCiphertext = itemPayloadCiphertext;
    if (throwOnSubmit != null) throw throwOnSubmit!;
  }

  @override
  Future<bool> hasActiveLineage(String candidateId) async => false;
}
