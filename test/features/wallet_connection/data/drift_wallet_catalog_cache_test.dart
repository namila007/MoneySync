import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

void main() {
  group('DriftWalletCatalogCache', () {
    late AppDatabase database;
    late DriftWalletCatalogCache cache;

    final sampleCatalog = WalletCatalog(
      accounts: const [
        WalletAccount(
          id: 'acc-1',
          name: 'Everyday',
          currencyCode: 'LKR',
          isArchived: false,
          isBankSynced: false,
          isWritable: true,
        ),
        WalletAccount(
          id: 'acc-2',
          name: 'Savings',
          currencyCode: 'LKR',
          isArchived: true,
          isBankSynced: true,
          isWritable: false,
        ),
      ],
      categories: const [
        WalletCategory(
          id: 'cat-1',
          name: 'Food',
          groupId: 'food_group',
          groupName: 'Food & Drink',
        ),
        WalletCategory(
          id: 'cat-2',
          name: 'Transport',
          groupId: 'transport_group',
          groupName: 'Transport',
        ),
      ],
    );

    setUp(() {
      database = AppDatabase.inMemoryForTesting();
      cache = DriftWalletCatalogCache(database: database);
    });

    tearDown(() => database.close());

    test('read returns null when cache is empty', () async {
      final result = await cache.read();
      expect(result, isNull);
    });

    test('write persists accounts and categories', () async {
      await cache.write(sampleCatalog);

      final result = await cache.read();
      expect(result, isNotNull);

      final catalog = result!;
      expect(catalog.accounts.length, 2);
      expect(catalog.categories.length, 2);

      expect(catalog.accounts[0].id, 'acc-1');
      expect(catalog.accounts[0].name, 'Everyday');
      expect(catalog.accounts[1].id, 'acc-2');
      expect(catalog.accounts[1].name, 'Savings');

      expect(catalog.categories[0].id, 'cat-1');
      expect(catalog.categories[0].name, 'Food');
      expect(catalog.categories[1].id, 'cat-2');
      expect(catalog.categories[1].name, 'Transport');
    });

    test('write updates wallet_connection_status to connected', () async {
      await cache.write(sampleCatalog);

      final status = await (database.select(
        database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(status.status, 'connected');
    });

    test('clear removes all cached data', () async {
      await cache.write(sampleCatalog);
      await cache.clear();

      final result = await cache.read();
      expect(result, isNull);
    });

    test('clear updates wallet_connection_status to disconnected', () async {
      await cache.write(sampleCatalog);
      await cache.clear();

      final status = await (database.select(
        database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(status.status, 'disconnected');
    });

    test('write replaces stale data completely', () async {
      await cache.write(sampleCatalog);

      final newCatalog = WalletCatalog(
        accounts: const [
          WalletAccount(
            id: 'acc-3',
            name: 'Business',
            currencyCode: 'LKR',
            isArchived: false,
            isBankSynced: false,
            isWritable: true,
          ),
        ],
        categories: const [
          WalletCategory(
            id: 'cat-3',
            name: 'Office',
            groupId: 'office_group',
            groupName: 'Office',
          ),
        ],
      );

      await cache.write(newCatalog);

      final result = await cache.read();
      expect(result, isNotNull);
      final catalog = result!;

      expect(catalog.accounts.length, 1);
      expect(catalog.accounts[0].id, 'acc-3');
      expect(catalog.categories.length, 1);
      expect(catalog.categories[0].id, 'cat-3');
    });

    test('read returns accounts when only accounts were written', () async {
      final partialCatalog = WalletCatalog(
        accounts: sampleCatalog.accounts,
        categories: const [],
      );

      await cache.write(partialCatalog);

      final result = await cache.read();
      expect(result, isNotNull);
      expect(result!.accounts.length, 2);
      expect(result.categories.length, 0);
    });

    test('read returns categories when only categories were written', () async {
      final partialCatalog = WalletCatalog(
        accounts: const [],
        categories: sampleCatalog.categories,
      );

      await cache.write(partialCatalog);

      final result = await cache.read();
      expect(result, isNotNull);
      expect(result!.accounts.length, 0);
      expect(result.categories.length, 2);
    });

    test(
      'wallet_connection_status starts as disconnected on fresh DB',
      () async {
        final status = await (database.select(
          database.walletConnectionStatus,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(status.status, 'disconnected');
      },
    );

    test('write is idempotent — can write same catalog twice', () async {
      await cache.write(sampleCatalog);
      await cache.write(sampleCatalog);

      final result = await cache.read();
      expect(result, isNotNull);
      expect(result!.accounts.length, 2);
      expect(result.categories.length, 2);
    });

    test('accounts are immutable after read', () async {
      await cache.write(sampleCatalog);

      final result = await cache.read();
      expect(
        () => result!.accounts.add(
          const WalletAccount(
            id: 'new',
            name: 'New',
            currencyCode: 'LKR',
            isArchived: false,
            isBankSynced: false,
            isWritable: true,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('categories are immutable after read', () async {
      await cache.write(sampleCatalog);

      final result = await cache.read();
      expect(
        () => result!.categories.add(
          const WalletCategory(
            id: 'new',
            name: 'New',
            groupId: 'new_group',
            groupName: 'New Group',
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
