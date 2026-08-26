import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';

/// Regression: the mutation row's `payload` column must carry counterParty,
/// note (with `[sw:...]` marker), and labelIds after submit. Before the fix,
/// `intent.payload` only held the structural fields (accountId, amountMinor,
/// etc.) and the enriched values existed only on the outbound request body.
void main() {
  group('persisted mutation payload contains enriched fields', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase.inMemoryForTesting();
      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'source-regression',
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

      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            ref.onDispose(db.close);
            return db;
          }),
          walletCatalogProvider.overrideWith((ref) async => catalog),
          mappingRuleListProvider.overrideWith((ref) async => const []),
          walletRepositoryProvider.overrideWithValue(
            WalletRepository(dataSource: FakeWalletApiDataSource()),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('persisted payload contains counterParty', () async {
      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -66666,
        accountId: 'account-1',
        categoryId: 'cat-1',
        counterParty: 'cp',
      );
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      expect(mutations, hasLength(1));
      final payload =
          jsonDecode(mutations.single.payload) as Map<String, Object?>;
      expect(payload['counterParty'], 'cp');
    });

    test('persisted payload contains note with [sw:...] marker', () async {
      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -66666,
        accountId: 'account-1',
        categoryId: 'cat-1',
        note: 'helloo',
      );
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      final payload =
          jsonDecode(mutations.single.payload) as Map<String, Object?>;
      final note = payload['note'] as String?;
      expect(note, isNotNull);
      expect(note, matches(RegExp(r'^\[sw:[A-Z0-9]+\] helloo$')));
    });

    test('persisted payload contains labelIds', () async {
      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -66666,
        accountId: 'account-1',
        categoryId: 'cat-1',
        labelIds: const ['user-label'],
      );
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      final payload =
          jsonDecode(mutations.single.payload) as Map<String, Object?>;
      final labelIds = payload['labelIds'] as List<dynamic>?;
      expect(labelIds, isNotNull);
      // FakeWalletApiDataSource.ensureLabel returns 'label-${_labels.length+1}'
      // for the first call (money_sync), so the resolved default is 'label-1'.
      expect(labelIds, contains('label-1'));
      expect(labelIds, contains('user-label'));
    });

    test('persisted payload has all three enriched fields together', () async {
      final controller = container.read(
        reviewTransactionControllerProvider(1).notifier,
      );
      controller.update(
        amountMinor: -66666,
        accountId: 'account-1',
        categoryId: 'cat-1',
        counterParty: 'cp',
        note: 'helloo',
        labelIds: const ['money_sync'],
      );
      await controller.submit(
        encryptedPayload: '{"kind":"expense"}',
        senderNormalized: 'BANK ALPHA',
        revision: 1,
      );

      final mutations = await db.select(db.walletMutations).get();
      final payload =
          jsonDecode(mutations.single.payload) as Map<String, Object?>;

      expect(payload['counterParty'], 'cp');
      final note = payload['note'] as String?;
      expect(note, isNotNull);
      expect(note, contains('[sw:'));
      expect(note, contains('helloo'));
      final labelIds = payload['labelIds'] as List<dynamic>?;
      expect(labelIds, isNotNull);
      expect(labelIds, isNotEmpty);
    });
  });
}
