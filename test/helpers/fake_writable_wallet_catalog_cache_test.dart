import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

import 'fake_writable_wallet_catalog_cache.dart';

void main() {
  group('FakeWritableWalletCatalogCache (M5.2 posture)', () {
    test('writable manual account is eligible', () async {
      final cache = FakeWritableWalletCatalogCache();
      final catalog = await cache.read();
      expect(catalog, isNotNull);

      final manual = catalog!.accounts.firstWhere(
        (a) => a.id == 'manual-lkr-1',
      );
      expect(manual.isWritable, isTrue);
      expect(manual.eligibility, WalletAccountEligibility.eligible);
    });

    test(
      'bank-synced account stays blocked even when flagged writable',
      () async {
        final cache = FakeWritableWalletCatalogCache();
        final catalog = await cache.read();

        final bank = catalog!.accounts.firstWhere((a) => a.id == 'bank-lkr-1');
        expect(bank.eligibility, WalletAccountEligibility.bankSynced);
      },
    );

    test('cache read is repeatable (stable catalog)', () async {
      final cache = FakeWritableWalletCatalogCache();
      expect(await cache.read(), same(await cache.read()));
    });
  });
}
