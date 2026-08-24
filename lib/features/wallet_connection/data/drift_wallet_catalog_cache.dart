import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

final class DriftWalletCatalogCache implements WalletCatalogCache {
  DriftWalletCatalogCache({required this._database});

  final AppDatabase _database;

  @override
  Future<WalletCatalog?> read() async {
    final accounts = await _database.select(_database.walletAccountCache).get();
    final categories = await _database
        .select(_database.walletCategoryCache)
        .get();
    final labels = await _database.select(_database.walletLabelCache).get();
    if (accounts.isEmpty && categories.isEmpty) return null;
    return WalletCatalog(
      accounts: accounts
          .map(
            (a) => WalletAccount(
              id: a.id,
              name: a.name,
              currencyCode: a.currencyCode,
              isArchived: a.isArchived,
              isBankSynced: a.isBankSynced,
              isWritable: a.isWritable,
            ),
          )
          .toList(),
      categories: categories
          .map(
            (c) => WalletCategory(
              id: c.id,
              name: c.name,
              groupId: c.groupId,
              groupName: c.groupName,
              parentId: c.parentId,
            ),
          )
          .toList(),
      labels: labels.map((l) => WalletLabel(id: l.id, name: l.name)).toList(),
    );
  }

  /// Reactive stream of the catalog cache. Emits on every Drift write to
  /// `walletAccountCache`, `walletCategoryCache`, or `walletLabelCache`.
  Stream<WalletCatalog?> watch() async* {
    final accountRows = _database.select(_database.walletAccountCache);
    final categoryRows = _database.select(_database.walletCategoryCache);
    final labelRows = _database.select(_database.walletLabelCache);

    // Merge table watches into a single catalog emission.
    await for (final _ in accountRows.watch()) {
      final categories = await categoryRows.get();
      final accounts = await accountRows.get();
      final labels = await labelRows.get();
      if (accounts.isEmpty && categories.isEmpty) {
        yield null;
      } else {
        yield WalletCatalog(
          accounts: accounts
              .map(
                (a) => WalletAccount(
                  id: a.id,
                  name: a.name,
                  currencyCode: a.currencyCode,
                  isArchived: a.isArchived,
                  isBankSynced: a.isBankSynced,
                  isWritable: a.isWritable,
                ),
              )
              .toList(),
          categories: categories
              .map(
                (c) => WalletCategory(
                  id: c.id,
                  name: c.name,
                  groupId: c.groupId,
                  groupName: c.groupName,
                  parentId: c.parentId,
                ),
              )
              .toList(),
          labels: labels
              .map((l) => WalletLabel(id: l.id, name: l.name))
              .toList(),
        );
      }
    }
  }

  @override
  Future<void> write(WalletCatalog catalog) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      await _database.delete(_database.walletAccountCache).go();
      await _database.delete(_database.walletCategoryCache).go();
      await _database.delete(_database.walletLabelCache).go();

      for (final account in catalog.accounts) {
        await _database
            .into(_database.walletAccountCache)
            .insert(
              WalletAccountCacheCompanion.insert(
                id: account.id,
                name: account.name,
                currencyCode: account.currencyCode,
                isArchived: account.isArchived,
                isBankSynced: account.isBankSynced,
                isWritable: account.isWritable,
                eligibilityReason: account.eligibility.name,
                refreshedAtEpochMs: now,
              ),
            );
      }
      for (final category in catalog.categories) {
        await _database
            .into(_database.walletCategoryCache)
            .insert(
              WalletCategoryCacheCompanion.insert(
                id: category.id,
                name: category.name,
                groupId: Value(category.groupId),
                groupName: Value(category.groupName),
                parentId: Value(category.parentId),
                refreshedAtEpochMs: now,
              ),
            );
      }
      for (final label in catalog.labels) {
        await _database
            .into(_database.walletLabelCache)
            .insert(
              WalletLabelCacheCompanion.insert(
                id: label.id,
                name: label.name,
                refreshedAtEpochMs: now,
              ),
            );
      }
      await (_database.update(_database.walletConnectionStatus)
            ..where((row) => row.singletonId.equals(1)))
          .write(WalletConnectionStatusCompanion(status: Value('connected')));
    });
  }

  @override
  Future<void> clear() async {
    await _database.transaction(() async {
      await _database.delete(_database.walletAccountCache).go();
      await _database.delete(_database.walletCategoryCache).go();
      await _database.delete(_database.walletLabelCache).go();
      await (_database.update(
        _database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).write(
        WalletConnectionStatusCompanion(status: Value('disconnected')),
      );
    });
  }
}
