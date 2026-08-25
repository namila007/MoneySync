import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

// Covers the M5.22 WP-H outcome table for `_connectWalletAtStartup`: every
// branch must write a distinct activity event, and — critically — only an
// authentication rejection (invalidToken) may remove the stored key. A
// transport/network failure must never destroy a still-valid credential.
void main() {
  group('walletStartupOutcomeFor', () {
    test('catalog ready connects and keeps the key', () {
      final outcome = walletStartupOutcomeFor(
        WalletConnectionCatalogReady(
          WalletCatalog(accounts: [], categories: []),
          DateTime(2026),
        ),
      );

      expect(outcome.activityCode, ActivityEventCode.walletConnected);
      expect(outcome.removeKey, isFalse);
      expect(outcome.isError, isFalse);
    });

    test('catalog offline refreshes and keeps the key', () {
      final outcome = walletStartupOutcomeFor(
        WalletConnectionCatalogOffline(
          WalletCatalog(accounts: [], categories: []),
          DateTime(2026),
        ),
      );

      expect(outcome.activityCode, ActivityEventCode.walletRefreshed);
      expect(outcome.removeKey, isFalse);
      expect(outcome.isError, isFalse);
    });

    test('authentication rejection disconnects and REMOVES the key', () {
      final outcome = walletStartupOutcomeFor(
        const WalletConnectionActionFailure(WalletReadFailure.invalidToken()),
      );

      expect(outcome.activityCode, ActivityEventCode.walletDisconnected);
      expect(outcome.removeKey, isTrue);
      expect(outcome.isError, isTrue);
    });

    test('transport failures refresh and KEEP the key', () {
      for (final failure in const [
        WalletReadFailure.offline(),
        WalletReadFailure.timeout(),
        WalletReadFailure.tls(),
        WalletReadFailure.service(),
        WalletReadFailure.protocol(),
      ]) {
        final outcome = walletStartupOutcomeFor(
          WalletConnectionActionFailure(failure),
        );

        expect(
          outcome.removeKey,
          isFalse,
          reason: '${failure.kind} must not remove the stored key',
        );
        expect(outcome.activityCode, ActivityEventCode.walletRefreshed);
        expect(outcome.isError, isTrue);
      }
    });
  });
}
