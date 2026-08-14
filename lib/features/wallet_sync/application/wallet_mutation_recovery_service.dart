import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

final log = Logger('wallet.mutation.recovery');

/// Process-death recovery for the outbox (M5.5).
///
/// On app start, scans for rows that were mid-transmission when the process
/// died — `syncing` with an expired (or absent) lease — and transitions them
/// to `reconciling`, never straight back to `syncing`. This is enforced
/// structurally: `canTransitionTo` has no `syncing -> syncing` edge.
///
/// Foreground-only for M5 (no WorkManager); revisit when background sync is
/// re-enabled in a later milestone.
final class WalletMutationRecoveryService {
  WalletMutationRecoveryService({
    required this._dao,
    int Function()? nowEpochMs,
  }) : _nowEpochMs = nowEpochMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final WalletMutationsDao _dao;
  final int Function() _nowEpochMs;

  /// Returns the number of mutations landed on `reconciling`.
  Future<int> recoverInterrupted() async {
    final now = _nowEpochMs();
    final interrupted = await _dao.syncingWithExpiredLease(nowEpochMs: now);
    var recovered = 0;
    for (final intent in interrupted) {
      try {
        await _dao.transitionTo(
          intent: intent,
          next: WalletMutationState.reconciling,
        );
        recovered++;
        log.info(
          'Recovered interrupted mutation ${intent.id} '
          'state_transition: syncing->reconciling',
        );
      } catch (e, s) {
        log.error('Recovery failed for mutation ${intent.id}', e, s);
      }
    }
    return recovered;
  }
}
