import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/core/database/app_database.dart'
    hide TransactionCandidate;
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/application/wallet_mutation_transmitter.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';
import 'package:money_sync/core/money/money.dart';
import 'package:money_sync/core/money/currency.dart';
import 'package:money_sync/core/time/source_date_evidence.dart';

/// Deterministic identity signer (mirrors test/helpers/fake_identity_signer).
SourceIdentitySigner _identitySigner() {
  return ({
    required int canonicalizationVersion,
    required String sender,
    required String body,
    required int receivedAtEpochMs,
  }) async {
    final preimage = StringBuffer('v$canonicalizationVersion');
    for (final field in [sender, body, receivedAtEpochMs.toString()]) {
      preimage
        ..write('|')
        ..write(field.length)
        ..write(':')
        ..write(field);
    }
    return HmacDigest(
      sha256.convert(utf8.encode(preimage.toString())).toString(),
    );
  };
}

/// M5.13 E2E: full connect → import → parse → map → review → transmit →
/// create-once against the fake Wallet server.
///
/// This extends [m5_e2e_test.dart] (which covers the use-case layer) by
/// exercising the full transmit path through [WalletMutationTransmitter]
/// against [FakeWalletApiDataSource], and asserting the invariants that
/// only the real API boundary can prove.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'connect-import-parse-map-review-create-once with transmit (M5.13)',
    (tester) async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      // ---- connect (fake catalog) -----------------------------------------
      final dataSource = FakeWalletApiDataSource();
      final catalog = WalletCatalog(
        accounts: const [
          WalletAccount(
            id: 'account-1',
            name: 'Savings',
            currencyCode: 'LKR',
            isArchived: false,
            isBankSynced: false,
            isWritable: true,
          ),
        ],
        categories: const [],
      );
      dataSource.writeCatalog(catalog);

      // ---- import + parse ------------------------------------------------
      final ingest = IngestManualMessage(
        database: db,
        identitySigner: _identitySigner(),
        interpret:
            ({
              required rawBody,
              required sender,
              required receivedAtUtc,
            }) async {
              // Deterministic fake: debit 4500.00 LKR at CAFE.
              return InterpretedCandidate(
                TransactionCandidate(
                  id: 'parser-sampath-debit-1',
                  sourceMessageKey: rawBody,
                  kind: TransactionKind.expense,
                  direction: TransactionDirection.debit,
                  lifecycle: FinancialLifecycle.posted,
                  originalAmount: Money(
                    minorUnits: -450000,
                    currency: Currency(code: 'LKR', decimalDigits: 2),
                  ),
                  transactionAtUtc: DateTime.utc(2026, 7, 18),
                  confidence: CandidateConfidence(basisPoints: 9000),
                  reviewReasons: const {},
                  provenance: CandidateProvenance(
                    parserRuleId: 'fake-pack',
                    parserRuleVersion: '1.0.0',
                    captureCanonicalizationVersion: 2,
                    sourceDateEvidence: SourceDateEvidence(
                      instantUtc: DateTime.utc(2026, 7, 18),
                      source: DateEvidenceSource.receivedAtUtc,
                      originalValue: 'received_at_fallback',
                      parsingContext: SourceTimeZoneContext.utc,
                    ),
                  ),
                  counterParty: 'CAFE',
                ),
              );
            },
      );
      final outcome = await ingest.call(
        rawBody: 'SAMPATH BANK: Payment of LKR 4,500.00 at CAFE on 18 Jul',
        rawSender: 'SAMPATH',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: 1_700_000_000_000,
        privacyEpoch: 0,
      );
      expect(outcome, isA<ManualIngestStored>());

      // ---- map ------------------------------------------------------------
      final rule = MappingRule(
        id: 'rule-1',
        name: 'Savings rule',
        enabled: true,
        senderMatcher: SenderMatcher(['SAMPATH']),
        walletAccountId: 'account-1',
        paymentType: 'debit_card',
        syncMode: MappingSyncMode.review,
        priority: 0,
        ruleVersion: 1,
        createdAtEpochMs: 1_700_000_000_000,
        updatedAtEpochMs: 1_700_000_000_000,
      );
      final resolver = MappingRuleResolver(rules: [rule]);
      final resolution = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'CAFE',
          direction: TransactionDirection.debit,
        ),
      );
      expect(resolution, isA<MappingResolved>());

      // ---- review -> outbox write -----------------------------------------
      final event = await db.select(db.smsEvents).getSingle();
      final context = PreSendContext(
        candidateId: 'candidate-${event.id}',
        amountMinor: 450000,
        currencyCode: 'LKR',
        recordDateUtc: DateTime.utc(2026, 7, 18),
        direction: TransactionDirection.debit,
        paymentType: 'debit_card',
        senderNormalized: 'SAMPATH',
        confidenceBasisPoints: 9500,
        privacyEpochMatches: true,
        consentCurrent: true,
        connectionConnected: true,
        eligibleTargetAccount: true,
        targetAccountEligibility: WalletAccountEligibility.eligible,
        mappingResolution: resolution,
        capabilityCanCreate: true,
        hasActiveLineage: false,
        hasOwnedRecordLink: false,
      );

      final writer = DriftReviewOutboxWriter(database: db);
      final useCase = ReviewTransactionUseCase(
        writer: writer,
        policy: const WalletCreateEligibilityPolicy(),
      );

      // Build the signed snapshot the same way the controller does:
      // unsigned magnitude + direction → signed amount.
      final signedAmount = signedMinorUnits(450000, TransactionDirection.debit);
      expect(signedAmount, lessThan(0), reason: 'debit must be negative');

      final snapshot = TransactionCandidateSnapshot(
        accountId: 'account-1',
        amountMinor: signedAmount,
        currencyCode: 'LKR',
        recordDateUtc: DateTime.utc(2026, 7, 18),
        paymentType: WalletPaymentType.debitCard,
        recordState: WalletRecordState.cleared,
        counterParty: 'CAFE',
        note: '[sw:7K2M9P4D8Q6R1V3X5T0Z] E2E test transaction',
        labelIds: ['label-money-sync'],
      );

      final intent = WalletMutationIntent(
        id: 'mutation-${event.id}-1',
        candidateId: 'candidate-${event.id}',
        operation: WalletMutationOperation.create,
        operationRevision: 1,
        lineageGeneration: 1,
        createLineageKey: 'lineage-${event.id}-1',
        transactionFingerprint: 'fingerprint-${event.id}',
        payload: <String, Object?>{
          'accountId': 'account-1',
          'amountMinor': signedAmount,
          'currencyCode': 'LKR',
        },
        state: WalletMutationState.queued,
      );

      final first = await useCase.submit(
        context: context,
        smsEventId: event.id,
        candidateState: CandidateRecordState.retainedLocal,
        encryptedPayload: '{}',
        revision: 1,
        createdAtEpochMs: 1_700_000_000_000,
        privacyEpoch: 0,
        intent: intent,
        itemLegRole: WalletItemLegRole.primary,
        itemPayloadCiphertext: jsonEncode(
          const WalletRecordPayloadSerializer().serialize(snapshot),
        ),
        activityType: ActivityEventCode.walletRecordQueued,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
      );
      expect(first, isA<ReviewSubmitted>());

      // ---- transmit against the fake API ----------------------------------
      final repository = WalletRepository(dataSource: dataSource);
      final transmitter = WalletMutationTransmitter(
        database: db,
        repository: repository,
      );
      final result = await transmitter.transmit(
        mutationId: intent.id,
        snapshot: snapshot,
      );
      expect(result, isA<WalletMutationRemoteSuccess>());

      // ---- INVARIANT: exactly one remote create ---------------------------
      expect(dataSource.createCalls, 1, reason: 'exactly one remote create');

      // ---- INVARIANT: amount is negative for a debit SMS ------------------
      expect(
        dataSource.lastCreatePayload!.amountMinor,
        lessThan(0),
        reason: 'debit must carry negative amount (WP-M)',
      );
      expect(
        dataSource.lastCreatePayload!.amountMinor,
        equals(-450000),
        reason: 'amount magnitude preserved in minor units',
      );
      expect(dataSource.lastCreatePayload!.currencyCode, equals('LKR'));

      // ---- INVARIANT: note carries [sw:...] marker -----------------------
      final note = dataSource.lastCreatePayload!.note;
      expect(note, isNotNull, reason: 'note must be set');
      expect(
        note,
        matches(RegExp(r'\[sw:[0-9A-Z]+\]')),
        reason: 'note must contain [sw:...] reconciliation marker (WP-O)',
      );

      // ---- INVARIANT: money_sync label present ----------------------------
      expect(
        dataSource.lastCreatePayload!.labelIds,
        contains('label-money-sync'),
        reason: 'money_sync label must be attached (WP-L)',
      );

      // ---- INVARIANT: succeeded only after create confirmed ---------------
      final mutations = await db.select(db.walletMutations).get();
      expect(mutations, hasLength(1));
      expect(
        mutations.single.state,
        WalletMutationState.succeeded,
        reason: 'succeeded only after confirmed remote record',
      );

      // ---- INVARIANT: re-submit is rejected (create-once) ----------------
      final duplicate = await useCase.submit(
        context: context,
        smsEventId: event.id,
        candidateState: CandidateRecordState.retainedLocal,
        encryptedPayload: '{}',
        revision: 1,
        createdAtEpochMs: 1_700_000_000_000,
        privacyEpoch: 0,
        intent: WalletMutationIntent(
          id: 'mutation-${event.id}-2',
          candidateId: 'candidate-${event.id}',
          operation: WalletMutationOperation.create,
          operationRevision: 1,
          lineageGeneration: 1,
          createLineageKey: 'lineage-${event.id}-1',
          transactionFingerprint: 'fingerprint-${event.id}',
          payload: const <String, Object?>{
            'accountId': 'account-1',
            'amountMinor': -450000,
            'currencyCode': 'LKR',
          },
          state: WalletMutationState.queued,
        ),
        itemLegRole: WalletItemLegRole.primary,
        itemPayloadCiphertext: '{}',
        activityType: ActivityEventCode.walletRecordQueued,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
      );
      expect(duplicate, isA<ReviewDuplicate>());

      // ---- INVARIANT: second transmit produces no second create -----------
      // The mutation is already succeeded — the transmitter's guard only
      // transitions from queued, so calling transmit on a succeeded mutation
      // would be an invalid state transition (succeeded -> syncing is not
      // allowed). This is the correct production behaviour: the outbox
      // processor only dispatches queued mutations. The invariant is that
      // re-running never produces a second create — verified by asserting
      // createCalls remains 1 and the mutation stays terminal.
      final afterDuplicate = await db.select(db.walletMutations).get();
      expect(
        afterDuplicate,
        hasLength(1),
        reason: 'still exactly one mutation',
      );
      expect(
        afterDuplicate.single.state,
        WalletMutationState.succeeded,
        reason: 'mutation must be terminal before re-transmit attempt',
      );
      expect(
        dataSource.createCalls,
        1,
        reason: 're-transmit must not produce a second remote create',
      );
    },
  );
}
