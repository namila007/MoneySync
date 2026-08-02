import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/data/keystore_wallet_secret_store.dart';
import 'package:money_sync/features/wallet_connection/data/production_wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

sealed class WalletConnectionViewState {
  const WalletConnectionViewState();
}

final class WalletPrerequisiteUnavailable extends WalletConnectionViewState {
  const WalletPrerequisiteUnavailable();
}

final class WalletDisconnected extends WalletConnectionViewState {
  const WalletDisconnected();
}

final class WalletConnectionLoading extends WalletConnectionViewState {
  const WalletConnectionLoading({this.previous});

  final WalletConnectionViewState? previous;
}

final class WalletConnected extends WalletConnectionViewState {
  WalletConnected({
    required this.catalog,
    required this.refreshedAt,
    required this.isStale,
  });

  final WalletCatalog catalog;
  final DateTime refreshedAt;
  final bool isStale;
}

enum WalletConnectionProblemCode {
  invalidToken,
  initialSync,
  rateLimited,
  offline,
  timeout,
  tls,
  service,
  protocol,
  freshAuthenticationRequired,
}

final class WalletConnectionFailure extends WalletConnectionViewState {
  const WalletConnectionFailure(this.code);

  final WalletConnectionProblemCode code;

  String get userMessage => switch (code) {
    WalletConnectionProblemCode.invalidToken => 'Enter a valid Wallet token.',
    WalletConnectionProblemCode.initialSync => 'Wallet is preparing its data.',
    WalletConnectionProblemCode.rateLimited =>
      'Wallet is rate limited. Try again later.',
    WalletConnectionProblemCode.offline =>
      'Wallet is offline. Cached details may be available.',
    WalletConnectionProblemCode.timeout => 'Wallet connection timed out.',
    WalletConnectionProblemCode.tls =>
      'Wallet connection could not be verified.',
    WalletConnectionProblemCode.service => 'Wallet is temporarily unavailable.',
    WalletConnectionProblemCode.protocol =>
      'Wallet returned an unsupported response.',
    WalletConnectionProblemCode.freshAuthenticationRequired =>
      'Confirm device authentication before replacing the token.',
  };
}

/// [handedOff] means a valid token has left the field and must stay cleared,
/// even if validation or fresh authentication later fails. [blocked] means no
/// action received it, so the field may remain unchanged.
enum WalletTokenSubmitResult { accepted, handedOff, blocked }

/// Riverpod composition stays in presentation; application contracts are pure
/// Dart. Production is composed when database + native security are available;
/// otherwise returns the fail-closed default.
final walletConnectionActionsProvider = Provider<WalletConnectionActions>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider).asData?.value;
  final auth = ref.watch(freshAuthPortProvider).asData?.value;
  final channel = ref.watch(nativeSecurityChannelProvider);
  if (db == null || auth == null) {
    return const WalletPrerequisiteUnavailableActions();
  }
  return ProductionWalletConnectionActions(
    secretStore: KeystoreWalletSecretStore(channel: channel),
    freshAuth: auth,
    cache: DriftWalletCatalogCache(database: db),
  );
});

final walletConnectionControllerProvider =
    NotifierProvider<WalletConnectionController, WalletConnectionViewState>(
      WalletConnectionController.new,
    );

/// Token-free presentation state machine.
class WalletConnectionController extends Notifier<WalletConnectionViewState> {
  var _generation = 0;
  var _hasConnectedToken = false;

  @override
  WalletConnectionViewState build() {
    final actions = ref.watch(walletConnectionActionsProvider);
    if (!actions.isAvailable) {
      return const WalletPrerequisiteUnavailable();
    }
    _restoreFromCache();
    return const WalletDisconnected();
  }

  Future<void> _restoreFromCache() async {
    try {
      final channel = ref.read(nativeSecurityChannelProvider);
      final store = KeystoreWalletSecretStore(channel: channel);
      await store.useSecret((token) async {
        final db = await ref.read(appDatabaseProvider.future);
        final status = await (db.select(
          db.walletConnectionStatus,
        )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
        if (status == null || status.status == 'disconnected') return;

        final cache = DriftWalletCatalogCache(database: db);
        final cached = await cache.read();
        _hasConnectedToken = true;
        state = WalletConnected(
          catalog: cached ?? WalletCatalog(accounts: [], categories: []),
          refreshedAt: status.lastSyncAtEpochMs != null
              ? DateTime.fromMillisecondsSinceEpoch(status.lastSyncAtEpochMs!)
              : DateTime.now(),
          isStale: true,
        );
      });
    } catch (_) {
      // No stored token or error — stay disconnected
    }
  }

  /// True only when [submit] will hand a valid token to the action layer.
  bool get canSubmitToken {
    final actions = ref.read(walletConnectionActionsProvider);
    return actions.isAvailable && state is! WalletConnectionLoading;
  }

  Future<WalletTokenSubmitResult> submit(WalletToken token) {
    final actions = ref.read(walletConnectionActionsProvider);
    if (!canSubmitToken) {
      return Future<WalletTokenSubmitResult>.value(
        WalletTokenSubmitResult.blocked,
      );
    }

    return _run(
      (epoch, replacing) =>
          actions.connect(token, replacing: replacing, lifecycleEpoch: epoch),
      replacing: _hasConnectedToken,
    );
  }

  Future<WalletTokenSubmitResult> refresh() {
    final actions = ref.read(walletConnectionActionsProvider);
    if (!actions.isAvailable || state is WalletConnectionLoading) {
      return Future<WalletTokenSubmitResult>.value(
        WalletTokenSubmitResult.blocked,
      );
    }
    return _run(
      (epoch, _) => actions.refresh(lifecycleEpoch: epoch),
      replacing: false,
    );
  }

  Future<bool> disconnect({required bool confirmed}) async {
    if (!confirmed) return false;

    final actions = ref.read(walletConnectionActionsProvider);
    if (!actions.isAvailable) return false;

    final epoch = ++_generation;
    try {
      await actions.disconnect(lifecycleEpoch: epoch);
    } on Exception {
      if (epoch == _generation) {
        state = const WalletConnectionFailure(
          WalletConnectionProblemCode.service,
        );
      }
      return false;
    }

    if (epoch != _generation) return false;
    _hasConnectedToken = false;
    state = const WalletDisconnected();
    return true;
  }

  Future<WalletTokenSubmitResult> _run(
    Future<WalletConnectionActionResult> Function(int epoch, bool replacing)
    operation, {
    required bool replacing,
  }) async {
    final epoch = ++_generation;
    state = WalletConnectionLoading(previous: state);

    final result = await _resultOrServiceFailure(
      () => operation(epoch, replacing),
    );
    if (epoch != _generation) return WalletTokenSubmitResult.handedOff;

    if (result is WalletConnectionCatalogReady ||
        result is WalletConnectionCatalogOffline) {
      _hasConnectedToken = true;
    }
    state = _stateFor(result);
    return switch (result) {
      WalletConnectionCatalogReady() ||
      WalletConnectionCatalogOffline() => WalletTokenSubmitResult.accepted,
      WalletConnectionActionFailure() ||
      WalletConnectionFreshAuthenticationRequired() ||
      WalletConnectionActionUnavailable() => WalletTokenSubmitResult.handedOff,
    };
  }

  Future<WalletConnectionActionResult> _resultOrServiceFailure(
    Future<WalletConnectionActionResult> Function() operation,
  ) async {
    try {
      return await operation();
    } on Exception {
      return const WalletConnectionActionFailure(WalletReadFailure.service());
    }
  }

  WalletConnectionViewState _stateFor(WalletConnectionActionResult result) =>
      switch (result) {
        WalletConnectionCatalogReady(:final catalog, :final refreshedAt) =>
          WalletConnected(
            catalog: catalog,
            refreshedAt: refreshedAt,
            isStale: false,
          ),
        WalletConnectionCatalogOffline(:final catalog, :final refreshedAt) =>
          WalletConnected(
            catalog: catalog,
            refreshedAt: refreshedAt,
            isStale: true,
          ),
        WalletConnectionActionFailure(:final failure) =>
          WalletConnectionFailure(_problemFor(failure)),
        WalletConnectionFreshAuthenticationRequired() =>
          const WalletConnectionFailure(
            WalletConnectionProblemCode.freshAuthenticationRequired,
          ),
        WalletConnectionActionUnavailable() =>
          const WalletPrerequisiteUnavailable(),
      };

  WalletConnectionProblemCode _problemFor(WalletReadFailure failure) =>
      switch (failure.kind) {
        WalletReadFailureKind.invalidToken =>
          WalletConnectionProblemCode.invalidToken,
        WalletReadFailureKind.initialSyncInProgress =>
          WalletConnectionProblemCode.initialSync,
        WalletReadFailureKind.rateLimited =>
          WalletConnectionProblemCode.rateLimited,
        WalletReadFailureKind.offline => WalletConnectionProblemCode.offline,
        WalletReadFailureKind.timeout => WalletConnectionProblemCode.timeout,
        WalletReadFailureKind.tls => WalletConnectionProblemCode.tls,
        WalletReadFailureKind.service => WalletConnectionProblemCode.service,
        WalletReadFailureKind.protocol => WalletConnectionProblemCode.protocol,
      };
}
