import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';
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
    // M5.22 WP-K: "Create now" now transmits, so the controller needs a Wallet
    // repository. Defaults to the fake, which confirms success.
    WalletApiDataSource? dataSource,
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
        walletRepositoryProvider.overrideWithValue(
          WalletRepository(dataSource: dataSource ?? FakeWalletApiDataSource()),
        ),
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

  // M5.22 WP-K. "Create now" used to write `succeeded` straight to the
  // database without ever calling the Wallet API: the UI reported success,
  // the Success tile incremented, and nothing was transmitted. These two
  // tests pin the corrected contract from both sides.
  group('create-now transmission (M5.22 WP-K)', () {
    test('transmits and only then records succeeded', () async {
      final source = _RecordingDataSource();
      final (db, container) = await build(
        disclosureAccepted: true,
        onboardingCompleted: true,
        catalog: _writableCatalog(),
        dataSource: source,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(amountMinor: -450000, accountId: 'account-1');
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      // The record actually went to the API...
      expect(source.createCalls, 1);
      // ...and was read back before any terminal state was written (WP-N).
      expect(source.readBackCalls, 1);
      // ...and only that confirmation justifies the terminal state.
      final mutations = await db.select(db.walletMutations).get();
      expect(mutations.single.state, WalletMutationState.succeeded);
    });

    // M5.22 WP-N. A 200 from the API is not proof the record is in Wallet.
    // plan/05:167 holds an unconfirmed create as unknownDelivery with
    // automatic retries stopped — resending could duplicate a record that
    // actually exists.
    test(
      'holds unknownDelivery when nothing can be proven either way',
      () async {
        // Read-back empty AND the marker lookup fails: no evidence in either
        // direction, so the mutation must be held rather than retried.
        final (db, container) = await build(
          disclosureAccepted: true,
          onboardingCompleted: true,
          catalog: _writableCatalog(),
          dataSource: _UnverifiableDataSource(reconcileThrows: true),
        );
        addTearDown(container.dispose);

        final controller = container.read(
          reviewTransactionControllerProvider(1).notifier,
        );
        controller.update(amountMinor: -450000, accountId: 'account-1');
        await controller.submit(
          encryptedPayload: '{"kind":"expense"}',
          senderNormalized: 'BANK ALPHA',
          revision: 1,
        );

        final mutations = await db.select(db.walletMutations).get();
        expect(
          mutations.single.state,
          WalletMutationState.unknownDelivery,
          reason: 'an unconfirmed create must be held for reconciliation',
        );
        expect(
          mutations.single.state,
          isNot(WalletMutationState.retryScheduled),
          reason: 'never auto-retry a create that may already have landed',
        );

        // The user gets an audit trail, not just a log line.
        final events = await db.select(db.activityEvents).get();
        expect(
          events.map((e) => e.eventType),
          contains(ActivityEventCode.walletRecordFailed),
        );
      },
    );

    // Owner decision 2026-08-25: reconcile straight away rather than waiting
    // for the next app start. The rules must match startup reconciliation —
    // only a conclusive answer may settle the mutation.
    test(
      'an immediate reconcile that finds the record settles succeeded',
      () async {
        final source = _UnverifiableDataSource(
          reconcileMatches: [
            WalletRecordRead(
              id: 'remote-ghost',
              amountMinor: -450000,
              currencyCode: 'LKR',
            ),
          ],
        );
        final (db, container) = await build(
          disclosureAccepted: true,
          onboardingCompleted: true,
          catalog: _writableCatalog(),
          dataSource: source,
        );
        addTearDown(container.dispose);

        final controller = container.read(
          reviewTransactionControllerProvider(1).notifier,
        );
        controller.update(amountMinor: -450000, accountId: 'account-1');
        await controller.submit(
          encryptedPayload: '{"kind":"expense"}',
          senderNormalized: 'BANK ALPHA',
          revision: 1,
        );

        expect(source.reconcileCalls, 1);
        final mutations = await db.select(db.walletMutations).get();
        expect(mutations.single.state, WalletMutationState.succeeded);
      },
    );

    test('an immediate reconcile proving absence schedules a retry', () async {
      final source = _UnverifiableDataSource(reconcileMatches: const []);
      final (db, container) = await build(
        disclosureAccepted: true,
        onboardingCompleted: true,
        catalog: _writableCatalog(),
        dataSource: source,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(amountMinor: -450000, accountId: 'account-1');
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      expect(
        mutations.single.state,
        WalletMutationState.retryScheduled,
        reason: 'proven absent is the only case where resending is safe',
      );
    });

    test('an ambiguous immediate reconcile holds unknownDelivery', () async {
      WalletRecordRead rec(String id) =>
          WalletRecordRead(id: id, amountMinor: -450000, currencyCode: 'LKR');
      final source = _UnverifiableDataSource(
        reconcileMatches: [rec('a'), rec('b')],
      );
      final (db, container) = await build(
        disclosureAccepted: true,
        onboardingCompleted: true,
        catalog: _writableCatalog(),
        dataSource: source,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(amountMinor: -450000, accountId: 'account-1');
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      expect(
        mutations.single.state,
        WalletMutationState.unknownDelivery,
        reason: 'two markers match — never guess which record is ours',
      );
    });

    test('never writes succeeded when transmission fails', () async {
      final (db, container) = await build(
        disclosureAccepted: true,
        onboardingCompleted: true,
        catalog: _writableCatalog(),
        dataSource: _FailingDataSource(),
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(amountMinor: -450000, accountId: 'account-1');
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      expect(
        mutations.single.state,
        isNot(WalletMutationState.succeeded),
        reason: 'a record that never reached Wallet must not read as created',
      );
      // The user is told the truth rather than shown a false success.
      final result = container
          .read(reviewTransactionControllerProvider(1))
          .result;
      expect(result, isA<ReviewBlocked>());
    });
  });

  // M5.22 WP-L. Every create carries the `money_sync` label (created on
  // demand when absent), on top of whatever the user picked. A label that
  // cannot be resolved must never block the create.
  group('default labels (M5.22 WP-L)', () {
    test('submitted create includes the money_sync label id', () async {
      final source = _LabelAwareDataSource(
        labelIds: {'money_sync': 'label-money-sync'},
      );
      final (_, container) = await build(
        disclosureAccepted: true,
        onboardingCompleted: true,
        catalog: _writableCatalog(),
        dataSource: source,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -450000,
        accountId: 'account-1',
        labelIds: const ['user-picked'],
      );
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      expect(source.lastPayload!.labelIds, contains('label-money-sync'));
      expect(source.lastPayload!.labelIds, contains('user-picked'));
    });

    test('a null ensureLabel does not block the create', () async {
      final source = _LabelAwareDataSource(labelIds: {'money_sync': null});
      final (db, container) = await build(
        disclosureAccepted: true,
        onboardingCompleted: true,
        catalog: _writableCatalog(),
        dataSource: source,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(amountMinor: -450000, accountId: 'account-1');
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final result = container
          .read(reviewTransactionControllerProvider(1))
          .result;
      expect(result, isA<ReviewSubmitted>());
      expect(source.lastPayload!.labelIds, isEmpty);
      final mutations = await db.select(db.walletMutations).get();
      expect(mutations.single.state, WalletMutationState.succeeded);
    });
  });
}

WalletCatalog _writableCatalog() => WalletCatalog(
  accounts: const [
    WalletAccount(
      id: 'account-1',
      name: 'Test account',
      currencyCode: 'LKR',
      isArchived: false,
      isBankSynced: false,
      isWritable: true,
    ),
  ],
  categories: const [],
);

class _RecordingDataSource implements WalletApiDataSource {
  int createCalls = 0;
  int readBackCalls = 0;

  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async {
    createCalls++;
    return const WalletCreateAllSucceeded(recordId: 'remote-1');
  }

  // M5.22 WP-N: the record exists once created, so the read-back confirms it.
  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    readBackCalls++;
    if (id != 'remote-1') return null;
    return WalletRecordRead(
      id: id,
      amountMinor: -450000,
      currencyCode: 'LKR',
      recordDateUtc: DateTime.utc(2026, 7, 18),
    );
  }

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async => const [];

  @override
  Future<WalletUsageStats> getUsageStats() async => const WalletUsageStats(
    recordCount: 0,
    requestCount: 0,
    rateLimitRemaining: null,
  );

  @override
  Future<String?> ensureLabel(String name) async => 'label-$name';
}

/// Captures the create payload and lets tests control label resolution
/// (M5.22 WP-L). A missing map entry falls back to a synthetic id; an
/// explicit `null` entry models a label that could not be created.
class _LabelAwareDataSource implements WalletApiDataSource {
  _LabelAwareDataSource({this.labelIds = const {}});

  final Map<String, String?> labelIds;
  TransactionCandidateSnapshot? lastPayload;

  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async {
    lastPayload = payload;
    return const WalletCreateAllSucceeded(recordId: 'remote-1');
  }

  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    if (id != 'remote-1') return null;
    return WalletRecordRead(
      id: id,
      amountMinor: -450000,
      currencyCode: 'LKR',
      recordDateUtc: DateTime.utc(2026, 7, 18),
    );
  }

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async => const [];

  @override
  Future<WalletUsageStats> getUsageStats() async => const WalletUsageStats(
    recordCount: 0,
    requestCount: 0,
    rateLimitRemaining: null,
  );

  @override
  Future<String?> ensureLabel(String name) async =>
      labelIds.containsKey(name) ? labelIds[name] : 'label-$name';
}

/// Reports a successful create, but the record can never be read back —
/// the ambiguous case WP-N exists for. [reconcileMatches] controls what the
/// immediate marker lookup finds.
class _UnverifiableDataSource implements WalletApiDataSource {
  _UnverifiableDataSource({
    this.reconcileMatches = const [],
    this.reconcileThrows = false,
  });

  final List<WalletRecordRead> reconcileMatches;
  final bool reconcileThrows;
  int reconcileCalls = 0;

  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async => const WalletCreateAllSucceeded(recordId: 'remote-ghost');

  @override
  Future<WalletRecordRead?> getRecord(String id) async => null;

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async {
    reconcileCalls++;
    if (reconcileThrows) throw Exception('reconciliation lookup failed');
    return reconcileMatches;
  }

  @override
  Future<WalletUsageStats> getUsageStats() async => const WalletUsageStats(
    recordCount: 0,
    requestCount: 0,
    rateLimitRemaining: null,
  );

  @override
  Future<String?> ensureLabel(String name) async => 'label-$name';
}

class _FailingDataSource implements WalletApiDataSource {
  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async =>
      throw const WalletApiDataSourceException(RetryablePreTransmission());

  @override
  Future<WalletRecordRead?> getRecord(String id) async => null;

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async => const [];

  @override
  Future<WalletUsageStats> getUsageStats() async => const WalletUsageStats(
    recordCount: 0,
    requestCount: 0,
    rateLimitRemaining: null,
  );

  @override
  Future<String?> ensureLabel(String name) async => 'label-$name';
}
