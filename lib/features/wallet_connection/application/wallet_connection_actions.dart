import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

/// Pure-Dart boundary for the Wallet connection lifecycle.
///
/// Implementations own secret staging, fresh authentication, cancellation, and
/// cache persistence. Results must contain only safe metadata, never a token.
///
/// Every lifecycle command receives a monotonically increasing [lifecycleEpoch].
/// An implementation must fence secret/cache commits to its current epoch.
/// [disconnect] must first invalidate/cancel all work through that epoch, then
/// clear staged and stored credentials. A late connection completion may never
/// promote or restore a credential after a later disconnect epoch.
abstract interface class WalletConnectionActions {
  bool get isAvailable;

  Future<WalletConnectionActionResult> connect(
    WalletToken token, {
    required bool replacing,
    required int lifecycleEpoch,
  });

  Future<WalletConnectionActionResult> refresh({required int lifecycleEpoch});

  /// Cancels all pending Wallet work before clearing the stored credential.
  Future<void> disconnect({required int lifecycleEpoch});
}

sealed class WalletConnectionActionResult {
  const WalletConnectionActionResult();
}

final class WalletConnectionCatalogReady extends WalletConnectionActionResult {
  const WalletConnectionCatalogReady(this.catalog, this.refreshedAt);

  final WalletCatalog catalog;
  final DateTime refreshedAt;
}

final class WalletConnectionCatalogOffline
    extends WalletConnectionActionResult {
  const WalletConnectionCatalogOffline(this.catalog, this.refreshedAt);

  final WalletCatalog catalog;
  final DateTime refreshedAt;
}

final class WalletConnectionActionFailure extends WalletConnectionActionResult {
  const WalletConnectionActionFailure(this.failure);

  final WalletReadFailure failure;
}

final class WalletConnectionFreshAuthenticationRequired
    extends WalletConnectionActionResult {
  const WalletConnectionFreshAuthenticationRequired();
}

final class WalletConnectionActionUnavailable
    extends WalletConnectionActionResult {
  const WalletConnectionActionUnavailable();
}

/// Fail-closed production default. It never performs I/O or resolves a fake.
final class WalletPrerequisiteUnavailableActions
    implements WalletConnectionActions {
  const WalletPrerequisiteUnavailableActions();

  @override
  bool get isAvailable => false;

  @override
  Future<WalletConnectionActionResult> connect(
    WalletToken token, {
    required bool replacing,
    required int lifecycleEpoch,
  }) async => const WalletConnectionActionUnavailable();

  @override
  Future<void> disconnect({required int lifecycleEpoch}) async {}

  @override
  Future<WalletConnectionActionResult> refresh({
    required int lifecycleEpoch,
  }) async => const WalletConnectionActionUnavailable();
}
