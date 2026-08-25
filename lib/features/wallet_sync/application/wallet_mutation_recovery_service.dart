import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
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
  }) : _nowEpochMs =
           nowEpochMs ?? (() => DateTime.now().millisecondsSinceEpoch);

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

  /// Resolves mutations whose outcome is unknown, by asking Wallet whether the
  /// record actually exists (M5.22 WP-E).
  ///
  /// [recoverInterrupted] parks interrupted rows on `reconciling`, but nothing
  /// ever settled them, so they stayed there indefinitely. This is the other
  /// half.
  ///
  /// The invariant this exists to honour (plan/05, §Idempotency and
  /// reconciliation): *"Retry POST only after the API can conclusively prove
  /// the original create did not succeed; one negative or lagging read is not
  /// proof."* So the walk is reconcile-first, and a lookup that fails or is
  /// inconclusive leaves the row exactly where it is rather than guessing —
  /// guessing risks a duplicate financial record.
  ///
  /// State walk per [WalletMutationStateTransitions]:
  /// `unknown* -> reconciling`, then `reconciling -> succeeded | retryScheduled`.
  ///
  /// Returns the number of mutations conclusively settled as `succeeded`.
  Future<int> reconcilePending({
    required Future<List<WalletRecordRead>> Function(WalletReconciliationQuery)
    findByMarker,
  }) async {
    // An unknown outcome has exactly one legal exit, and it is not a retry.
    for (final intent in await _dao.byStates(const [
      WalletMutationState.unknownDelivery,
      WalletMutationState.unknownUpdate,
      WalletMutationState.unknownDelete,
    ])) {
      try {
        await _dao.transitionTo(
          intent: intent,
          next: WalletMutationState.reconciling,
        );
        log.info('state_transition: reconciling');
      } on Exception catch (e, s) {
        log.error('Could not move an unknown mutation to reconciling', e, s);
      }
    }

    var settled = 0;
    for (final intent in await _dao.byStates(const [
      WalletMutationState.reconciling,
    ])) {
      final marker = await _dao.markerFor(intent.id);
      if (marker == null) {
        // Without the marker there is no way to ask the question, so the row
        // is held for manual verification rather than retried blindly.
        log.error(
          'Reconciliation skipped: no source marker | '
          'SafeErrorCode: MARKER_MISSING',
        );
        continue;
      }

      try {
        final matches = await findByMarker(
          WalletReconciliationQuery(
            marker: marker,
            accountId: (intent.payload['accountId'] as String?) ?? '',
            amountMinor: (intent.payload['amountMinor'] as int?) ?? 0,
          ),
        );

        if (matches.length == 1) {
          await _dao.transitionTo(
            intent: intent,
            next: WalletMutationState.succeeded,
          );
          if (intent.candidateId.isNotEmpty) {
            await _dao.transitionCandidateState(
              candidateId: intent.candidateId,
              newState: 'retainedLocal',
            );
          }
          settled++;
          log.info(
            'Reconciled to an existing record | state_transition: succeeded',
          );
        } else if (matches.isEmpty) {
          // The create is now proven not to have landed, so resending is safe
          // — this is the ONLY path that schedules a retry.
          await _dao.scheduleRetry(
            intent: intent,
            attemptCount: 1,
            nextAttemptAtEpochMs: _nowEpochMs(),
          );
          log.info('Create proven absent | state_transition: retryScheduled');
        } else {
          // More than one match means the marker is ambiguous. Never guess
          // which record is ours — hold it for a human.
          log.error(
            'Reconciliation ambiguous: ${matches.length} records share the '
            'marker | SafeErrorCode: MARKER_AMBIGUOUS',
          );
        }
      } on Exception catch (e, s) {
        // A failed lookup is not evidence of absence. Leave the row on
        // `reconciling` and try again next start.
        log.error('Reconciliation lookup failed; holding the mutation', e, s);
      }
    }
    return settled;
  }
}
