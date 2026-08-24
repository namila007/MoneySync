import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// M5.14 gap 2: the review controller must assemble PreSendContext from REAL
/// state (privacy epoch, consent, capability ledger, active lineage, owned
/// record link), not hardcoded passes.
void main() {
  Future<(AppDatabase, ProviderContainer)> build({
    int eventPrivacyEpoch = 0,
    int settingsPrivacyEpoch = 0,
    bool disclosureAccepted = false,
    bool onboardingCompleted = false,
    List<CapabilityLedgerCompanion> capabilities = const [],
    List<WalletMutationsCompanion> mutations = const [],
    List<WalletRecordLinksCompanion> links = const [],
    WalletCatalog? catalog,
    List<MappingRule> rules = const [],
  }) async {
    final db = AppDatabase.inMemoryForTesting();
    await db
        .into(db.smsEvents)
        .insert(
          SmsEventsCompanion.insert(
            sourceKey: 'source-gate',
            senderKey: 'BANK ALPHA',
            ingestionSource: 'manual_paste',
            receivedAtEpochMs: 1_700_000_000_000,
            status: SmsEventStatus.review,
            privacyEpoch: eventPrivacyEpoch,
          ),
        );
    if (disclosureAccepted || onboardingCompleted) {
      await (db.update(
        db.appSettings,
      )..where((r) => r.singletonId.equals(1))).write(
        AppSettingsCompanion(
          disclosureAccepted: Value(disclosureAccepted),
          onboardingCompleted: Value(onboardingCompleted),
        ),
      );
    }
    for (final capability in capabilities) {
      await db.into(db.capabilityLedger).insert(capability);
    }
    for (final mutation in mutations) {
      await db.into(db.walletMutations).insert(mutation);
    }
    for (final link in links) {
      await db.into(db.walletRecordLinks).insert(link);
    }
    await (db.update(db.appSettings)..where((r) => r.singletonId.equals(1)))
        .write(AppSettingsCompanion(privacyEpoch: Value(settingsPrivacyEpoch)));

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async {
          ref.onDispose(db.close);
          return db;
        }),
        walletCatalogProvider.overrideWith((ref) async => catalog),
        mappingRuleListProvider.overrideWith((ref) async => rules),
      ],
    );
    return (db, container);
  }

  test(
    'privacy epoch gate reads real event vs settings epoch (M5.14 gap 2)',
    () async {
      // Event captured at epoch 0, settings advanced to 1 -> gate 1 must block.
      final (_, container) = await build(
        eventPrivacyEpoch: 0,
        settingsPrivacyEpoch: 1,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      await controller.evaluate(
        encryptedPayload: '{}',
        senderNormalized: 'BANK ALPHA',
      );

      final evaluation = container
          .read(reviewTransactionControllerProvider(1))
          .evaluation!;
      expect(evaluation.firstBlockedGateIndex, 0);
      expect(evaluation.firstBlockReason, contains('privacy epoch'));
    },
  );

  test(
    'consent gate reads disclosure + onboarding from app settings (gap 2)',
    () async {
      // Matching epoch, no disclosure -> gate 2 blocks.
      final (_, container) = await build(
        eventPrivacyEpoch: 0,
        settingsPrivacyEpoch: 0,
        disclosureAccepted: false,
        onboardingCompleted: false,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      await controller.evaluate(
        encryptedPayload: '{}',
        senderNormalized: 'BANK ALPHA',
      );

      final evaluation = container
          .read(reviewTransactionControllerProvider(1))
          .evaluation!;
      expect(evaluation.firstBlockedGateIndex, 1);
    },
  );

  test(
    'capability gate reads the capability ledger (empty -> passes) (gap 2)',
    () async {
      final (_, container) = await build(
        eventPrivacyEpoch: 0,
        settingsPrivacyEpoch: 0,
        disclosureAccepted: true,
        onboardingCompleted: true,
        // Empty ledger: no create evidence -> gate 8 passes (fail-open).
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      await controller.evaluate(
        encryptedPayload: '{}',
        senderNormalized: 'BANK ALPHA',
      );

      final evaluation = container
          .read(reviewTransactionControllerProvider(1))
          .evaluation!;
      expect(evaluation.outcomes.length, 8);
      expect(evaluation.outcomes[7], isA<GatePass>());
    },
  );

  test('lineage + record link gates read real outbox state (gap 2)', () async {
    final (_, container) = await build(
      eventPrivacyEpoch: 0,
      settingsPrivacyEpoch: 0,
      disclosureAccepted: true,
      onboardingCompleted: true,
      mutations: [
        WalletMutationsCompanion.insert(
          id: 'mutation-active',
          operationKind: WalletMutationOperation.create,
          payload: '{}',
          state: WalletMutationState.queued,
          lineageKey: 'lineage-1',
          fingerprint: 'fingerprint-1',
          createdAtEpochMs: 1_700_000_000_000,
          updatedAtEpochMs: 1_700_000_000_000,
          candidateId: const Value('candidate-1'),
          operationRevision: const Value(1),
          lineageGeneration: const Value(1),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      reviewTransactionControllerProvider(1).notifier,
    );
    await controller.evaluate(
      encryptedPayload: '{}',
      senderNormalized: 'BANK ALPHA',
    );

    // Active lineage for candidate-1 -> gate 7 (index 6) blocks.
    final evaluation = container
        .read(reviewTransactionControllerProvider(1))
        .evaluation!;
    expect(evaluation.outcomes[6], isA<GateBlock>());
  });

  test('submit with all gates passing writes one mutation with the serialized '
      'payload (M5.14 gap 2 + gap 3)', () async {
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
    final rule = MappingRule(
      id: 'rule-1',
      name: 'R1',
      enabled: true,
      senderMatcher: SenderMatcher(['BANK ALPHA']),
      walletAccountId: 'account-1',
      paymentType: 'debit_card',
      syncMode: MappingSyncMode.automatic,
      priority: 0,
      ruleVersion: 1,
      createdAtEpochMs: 1_700_000_000_000,
      updatedAtEpochMs: 1_700_000_000_000,
    );
    final (db, container) = await build(
      eventPrivacyEpoch: 0,
      settingsPrivacyEpoch: 0,
      disclosureAccepted: true,
      onboardingCompleted: true,
      capabilities: [
        CapabilityLedgerCompanion.insert(
          id: 'create-evidence',
          capability: 'create',
          status: 'pass',
          observedOn: DateTime.now().toUtc().toIso8601String(),
          reviewDate: DateTime.now().toUtc().toIso8601String(),
        ),
        CapabilityLedgerCompanion.insert(
          id: 'reconcile-evidence',
          capability: 'reconciliation',
          status: 'pass',
          observedOn: DateTime.now().toUtc().toIso8601String(),
          reviewDate: DateTime.now().toUtc().toIso8601String(),
        ),
      ],
      catalog: catalog,
      rules: [rule],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      reviewTransactionControllerProvider(1).notifier,
    );
    controller.update(
      amountMinor: -450000,
      accountId: 'account-1',
      counterParty: 'CAFE',
      dateUtc: DateTime.utc(2026, 7, 18),
    );
    await controller.submit(
      encryptedPayload: '{"kind":"expense"}',
      senderNormalized: 'BANK ALPHA',
      revision: 1,
    );

    final result = container
        .read(reviewTransactionControllerProvider(1))
        .result;
    expect(result, isA<ReviewSubmitted>());

    // One queued mutation for candidate-1, payload ciphertext serialized.
    final mutations = await db.select(db.walletMutations).get();
    expect(mutations, hasLength(1));
    expect(mutations.single.candidateId, 'candidate-1');
    expect(mutations.single.state, WalletMutationState.succeeded);

    // The item payload is the serializer output (amount decimal string,
    // allowlisted fields), not a hand-built map.
    final items = await db.select(db.walletMutationItems).get();
    expect(items, hasLength(1));
    expect(items.single.payloadCiphertext, contains('"amount"'));
    expect(items.single.payloadCiphertext, isNot(contains('bodyRedacted')));
  });
}
