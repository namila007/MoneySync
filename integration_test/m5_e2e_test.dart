import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

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

/// M5.13 E2E: connect → import → parse → map → review → create-once against
/// the fake Wallet server. Asserts exactly one queued mutation for one
/// candidate, and that a second identical import creates no second mutation.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('connect-import-parse-map-review-create-once (M5.13)', (
    tester,
  ) async {
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
      interpret: ({required rawBody, required sender, required receivedAtUtc}) async =>
          InterpretMessage(registry: RulePackRegistry(packs: []))
              .call(
                rawBody: rawBody,
                sender: sender,
                receivedAtUtc: receivedAtUtc,
              ),
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

    // ---- review -> create-once -----------------------------------------
    final event = await db.select(db.smsEvents).getSingle();
    final context = PreSendContext(
      candidateId: 'candidate-${event.id}',
      amountMinor: -450000,
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

    final first = await useCase.submit(
      context: context,
      smsEventId: event.id,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: 1_700_000_000_000,
      privacyEpoch: 0,
      intent: WalletMutationIntent(
        id: 'mutation-${event.id}-1',
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
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );
    expect(first, isA<ReviewSubmitted>());

    // ---- double-submit on the same candidate is rejected ---------------
    final second = await useCase.submit(
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
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );
    expect(second, isA<ReviewDuplicate>());

    // Exactly one queued mutation survives.
    final mutations = await db.select(db.walletMutations).get();
    expect(mutations, hasLength(1));
    expect(mutations.single.state, WalletMutationState.queued);
  });
}
