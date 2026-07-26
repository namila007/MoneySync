import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/security/device_authenticator.dart';

enum ForegroundLockState { unlocked, locked, authenticating, lockedOut }

final foregroundLockControllerProvider =
    NotifierProvider<ForegroundLockNotifier, ForegroundLockState>(
      ForegroundLockNotifier.new,
    );

final class ForegroundLockNotifier extends Notifier<ForegroundLockState> {
  @override
  ForegroundLockState build() {
    return ForegroundLockState.locked;
  }

  Future<bool> unlock({required FreshAuthPort authenticator}) async {
    final log = Logger('lock');
    log.info('Unlock requested, current state=$state');
    if (state == ForegroundLockState.unlocked) return true;
    if (state == ForegroundLockState.authenticating) return false;

    state = ForegroundLockState.authenticating;
    final outcome = await authenticator.authenticate(
      purpose: 'Unlock MoneySync',
    );
    log.info('Auth outcome=$outcome');

    final success = outcome == DeviceAuthOutcome.authenticated;
    state = switch (outcome) {
      DeviceAuthOutcome.authenticated => ForegroundLockState.unlocked,
      DeviceAuthOutcome.lockedOut => ForegroundLockState.lockedOut,
      _ => ForegroundLockState.locked,
    };
    log.info('Lock state after auth=$state');
    return success;
  }

  void lock() {
    Logger('lock').info('Lock requested');
    state = ForegroundLockState.locked;
  }

  void onAppPaused() {
    Logger('lock').info('App paused, locking');
    state = ForegroundLockState.locked;
  }
}
