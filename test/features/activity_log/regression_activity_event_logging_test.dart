import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';

/// M5.22: Lock in activity-log corrections so they cannot silently regress.
/// - The activity log (`activity_events`) is user-facing.
/// - A log-scraping listener that copied allowlisted `Logger.root` records into
///   the table was DELETED — it was why "Database health check: ready (code=null)"
///   dominated users' activity logs.
/// - The review submit used to write `walletRecordCreated` at submit time, before
///   anything was transmitted. It now writes `walletRecordQueued`.
/// - `walletRecordCreated` is written by `WalletMutationTransmitter` only after
///   the API confirms the record.
/// - `walletRecordFailed` is written on any non-confirmed outcome.
void main() {
  Future<(AppDatabase, ProviderContainer)> build({
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
            privacyEpoch: 0,
          ),
        );
    await (db.update(
      db.appSettings,
    )..where((r) => r.singletonId.equals(1))).write(
      AppSettingsCompanion(
        disclosureAccepted: const Value(true),
        onboardingCompleted: const Value(true),
      ),
    );
    await db
        .into(db.capabilityLedger)
        .insert(
          CapabilityLedgerCompanion.insert(
            id: 'create-evidence',
            capability: 'create',
            status: 'pass',
            observedOn: DateTime.now().toUtc().toIso8601String(),
            reviewDate: DateTime.now().toUtc().toIso8601String(),
          ),
        );

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

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async {
          ref.onDispose(db.close);
          return db;
        }),
        walletCatalogProvider.overrideWith((ref) async => catalog),
        mappingRuleListProvider.overrideWith((ref) async => [rule]),
        walletRepositoryProvider.overrideWithValue(
          WalletRepository(dataSource: dataSource ?? FakeWalletApiDataSource()),
        ),
      ],
    );
    return (db, container);
  }

  test(
    'developer logger message produces NO activity row (regression guard for deleted scraper)',
    () async {
      final (db, container) = await build();
      addTearDown(container.dispose);

      // Ensure hierarchical logging is disabled to verify root logger emits
      hierarchicalLoggingEnabled = false;
      Logger.root.level = Level.ALL;

      // Emit a developer-style log message that should NOT appear in activity log
      Logger('startup').info('Database health check: ready (code=null)');

      // The activity_events table must remain empty
      final events = await db.select(db.activityEvents).get();
      expect(
        events,
        isEmpty,
        reason:
            'Developer log messages must not pollute the activity log; the '
            'scraper that copied Logger.root records was deleted.',
      );
    },
  );

  test(
    'save for later (deferred submit) writes walletRecordQueued and NOT walletRecordCreated',
    () async {
      final (db, container) = await build();
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -450000,
        accountId: 'account-1',
        categoryId: 'cat-1',
      );

      // Submit with deferred: true (save for later)
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
        deferred: true,
      );

      final events = await db.select(db.activityEvents).get();

      // Must have walletRecordQueued...
      expect(
        events.map((e) => e.eventType),
        contains(ActivityEventCode.walletRecordQueued),
        reason: 'save for later must queue the record',
      );

      // ...but NOT walletRecordCreated
      expect(
        events.map((e) => e.eventType),
        isNot(contains(ActivityEventCode.walletRecordCreated)),
        reason:
            'walletRecordCreated is written only after API confirms; save for '
            'later has no confirmation yet',
      );
    },
  );

  test('confirmed create writes walletRecordCreated', () async {
    final source = _SuccessfulCreateDataSource();
    final (db, container) = await build(dataSource: source);
    addTearDown(container.dispose);

    final controller = container.read(
      reviewTransactionControllerProvider(1).notifier,
    );
    controller.update(
      amountMinor: -450000,
      accountId: 'account-1',
      categoryId: 'cat-1',
    );

    // Submit without deferred (create now)
    await controller.submit(
      encryptedPayload: '{"kind":"expense"}',
      senderNormalized: 'BANK ALPHA',
      revision: 1,
    );

    final events = await db.select(db.activityEvents).get();

    // The sequence should be: queued (at submit), then created (after API confirms)
    expect(
      events.map((e) => e.eventType),
      contains(ActivityEventCode.walletRecordCreated),
      reason: 'confirmed create must write walletRecordCreated',
    );
  });

  test(
    'create whose transmission fails writes walletRecordFailed and NO walletRecordCreated',
    () async {
      final (db, container) = await build(
        dataSource: _FailingCreateDataSource(),
      );
      addTearDown(container.dispose);

      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -450000,
        accountId: 'account-1',
        categoryId: 'cat-1',
      );

      // Submit without deferred
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final events = await db.select(db.activityEvents).get();

      // Must have walletRecordFailed...
      expect(
        events.map((e) => e.eventType),
        contains(ActivityEventCode.walletRecordFailed),
        reason: 'failed create must write walletRecordFailed',
      );

      // ...but NOT walletRecordCreated
      expect(
        events.map((e) => e.eventType),
        isNot(contains(ActivityEventCode.walletRecordCreated)),
        reason:
            'walletRecordCreated must never be written when transmission fails',
      );
    },
  );
}

/// A data source that succeeds and returns a record that can be read back
/// (confirming the create).
class _SuccessfulCreateDataSource implements WalletApiDataSource {
  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async => const WalletCreateAllSucceeded(recordId: 'remote-record-1');

  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    if (id != 'remote-record-1') return null;
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

/// A data source that fails on create
class _FailingCreateDataSource implements WalletApiDataSource {
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
