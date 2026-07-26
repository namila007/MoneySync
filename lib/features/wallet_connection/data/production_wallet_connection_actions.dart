import 'package:dio/dio.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart' hide FreshAuthPort;

final class ProductionWalletConnectionActions implements WalletConnectionActions {
  ProductionWalletConnectionActions({
    required WalletSecretStore secretStore,
    required FreshAuthPort freshAuth,
    required WalletCatalogCache cache,
    Dio? dio,
  })  : _secretStore = secretStore,
      _freshAuth = freshAuth,
      _cache = cache,
      _api = WalletApiDataSource(dio: dio ?? Dio());

  final WalletSecretStore _secretStore;
  final FreshAuthPort _freshAuth;
  final WalletCatalogCache _cache;
  final WalletApiDataSource _api;

  @override
  bool get isAvailable => true;

  @override
  Future<WalletConnectionActionResult> connect(
    WalletToken token, {
    required bool replacing,
    required int lifecycleEpoch,
  }) async {
    if (replacing) {
      final auth = await _freshAuth.authenticate(purpose: 'Replace Wallet token');
      if (auth != DeviceAuthOutcome.authenticated) {
        return const WalletConnectionFreshAuthenticationRequired();
      }
    }

    try {
      final testResult = await _api.testConnection(token);
      if (testResult != null) {
        return WalletConnectionActionFailure(testResult);
      }
      await _secretStore.save(token);
      final catalog = await _api.fetchCatalog(token);
      if (catalog is WalletReadSuccess) {
        await _cache.write(catalog.catalog);
        return WalletConnectionCatalogReady(catalog.catalog, DateTime.now());
      }
      if (catalog is WalletReadFailure) {
        return WalletConnectionActionFailure(catalog);
      }
      return WalletConnectionCatalogReady(
        WalletCatalog(accounts: [], categories: []),
        DateTime.now(),
      );
    } catch (_) {
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    }
  }

  @override
  Future<WalletConnectionActionResult> refresh({required int lifecycleEpoch}) async {
    try {
      final result = await _secretStore.useSecret((token) async {
        return await _api.fetchCatalog(token);
      });
      if (result is WalletReadSuccess) {
        await _cache.write(result.catalog);
        return WalletConnectionCatalogReady(result.catalog, DateTime.now());
      }
      if (result is WalletReadFailure) {
        return WalletConnectionActionFailure(result);
      }
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    } catch (_) {
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    }
  }

  @override
  Future<void> disconnect({required int lifecycleEpoch}) async {
    await _cache.clear();
    await _secretStore.clear();
  }
}
