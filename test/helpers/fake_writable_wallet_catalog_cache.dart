import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// Shared writable-account fixture for eligibility-gate tests (M5.2/M5.8).
///
/// The real `WalletCatalogReader` stays fail-closed (`isWritable: false`)
/// until the live write-eligibility spike confirms the OpenAPI field that
/// signals a bank-synced/non-writable account (plan/05 §Account selection
/// constraints). Until that spike closes, every downstream account-eligibility
/// gate test is written against this fixture — never against the real reader.
final class FakeWritableWalletCatalogCache implements WalletCatalogCache {
  FakeWritableWalletCatalogCache({WalletCatalog? seed})
    : _seed =
          seed ??
          WalletCatalog(
            accounts: const [
              WalletAccount(
                id: 'manual-lkr-1',
                name: 'Manual LKR',
                currencyCode: 'LKR',
                isArchived: false,
                isBankSynced: false,
                isWritable: true,
              ),
              WalletAccount(
                id: 'bank-lkr-1',
                name: 'Bank Synced LKR',
                currencyCode: 'LKR',
                isArchived: false,
                isBankSynced: true,
                isWritable: true,
              ),
            ],
            categories: const [],
          );

  final WalletCatalog _seed;

  @override
  Future<WalletCatalog?> read() async => _seed;

  @override
  Future<void> write(WalletCatalog catalog) async {}

  @override
  Future<void> clear() async {}
}
