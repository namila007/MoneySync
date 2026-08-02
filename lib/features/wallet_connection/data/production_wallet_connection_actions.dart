import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/data/wallet_catalog_reader.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart'
    hide FreshAuthPort;

/// The single audited production Wallet read transport. [WalletCatalogReader]
/// owns the fixed-origin, GET-only, path-allowlisted, redirect-rejecting Dio
/// configuration — there is no second production/test HTTP path.
final class ProductionWalletConnectionActions
    implements WalletConnectionActions {
  ProductionWalletConnectionActions({
    required this._secretStore,
    required this._freshAuth,
    required this._cache,
    WalletCatalogReader? reader,
  }) : _reader = reader ?? WalletCatalogReader.production();

  final WalletSecretStore _secretStore;
  final FreshAuthPort _freshAuth;
  final WalletCatalogCache _cache;
  final WalletCatalogReader _reader;

  @override
  bool get isAvailable => true;

  @override
  Future<WalletConnectionActionResult> connect(
    WalletToken token, {
    required bool replacing,
    required int lifecycleEpoch,
  }) async {
    if (replacing) {
      final auth = await _freshAuth.authenticate(
        purpose: 'Replace Wallet token',
      );
      if (auth != DeviceAuthOutcome.authenticated) {
        return const WalletConnectionFreshAuthenticationRequired();
      }
    }

    try {
      // A single read proves the token works; only a token that actually
      // reads data is persisted, and the same result is reused for the
      // initial cache write instead of fetching twice.
      final result = await _reader.readCatalog(token);
      if (result is WalletReadFailure) {
        return WalletConnectionActionFailure(result);
      }
      await _secretStore.save(token);
      final catalog = (result as WalletReadSuccess).catalog;
      await _cache.write(catalog);
      return WalletConnectionCatalogReady(catalog, DateTime.now());
    } on Exception {
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    }
  }

  @override
  Future<WalletConnectionActionResult> refresh({
    required int lifecycleEpoch,
  }) async {
    try {
      final result = await _secretStore.useSecret(
        (token) => _reader.readCatalog(token),
      );
      if (result is WalletReadSuccess) {
        await _cache.write(result.catalog);
        return WalletConnectionCatalogReady(result.catalog, DateTime.now());
      }
      if (result is WalletReadFailure) {
        return WalletConnectionActionFailure(result);
      }
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    } on Exception {
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    }
  }

  @override
  Future<void> disconnect({required int lifecycleEpoch}) async {
    await _cache.clear();
    await _secretStore.clear();
  }
}
