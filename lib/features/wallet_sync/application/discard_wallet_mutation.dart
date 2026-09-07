import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

final _log = Logger('wallet.discard');

/// States whose remote outcome is not yet known — discarding one could strand
/// a possibly-created remote record with no reconciliation path, so we refuse.
const _inFlightStates = {
  WalletMutationState.syncing,
  WalletMutationState.reconciling,
  WalletMutationState.unknownDelivery,
  WalletMutationState.unknownUpdate,
  WalletMutationState.unknownDelete,
};

/// The user-facing "delete this record" action for a wallet-sync list row
/// (retry / waiting / succeeded).
///
/// Soft-deletes via [WalletMutationsDao.discard] so the row — and the partial
/// unique index that blocks a duplicate `create` for the same lineage — stays
/// in place: a discarded `succeeded` create still prevents a re-import from
/// creating a second Wallet record. Refuses in-flight states. Writes one
/// [ActivityEventCode.walletRecordDiscarded] event.
final class DiscardWalletMutation {
  DiscardWalletMutation({required AppDatabase database})
    : _database = database,
      _dao = WalletMutationsDao(database: database);

  final AppDatabase _database;
  final WalletMutationsDao _dao;

  /// Throws [WalletMutationInFlightFailure] when the mutation is still being
  /// sent or reconciled. Silent no-op when the row is absent or already
  /// discarded.
  Future<void> call({required String mutationId}) async {
    final state = await _dao.stateOf(mutationId);
    if (state == null) return;
    if (_inFlightStates.contains(state)) {
      throw const WalletMutationInFlightFailure();
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final changed = await _dao.discard(id: mutationId, nowEpochMs: now);
    if (changed == 0) return;

    try {
      await _database.insertActivity(
        activityType: ActivityEventCode.walletRecordDiscarded,
        safeDetailCode: ActivityStateTransition.logEvent,
        occurredAtEpochMs: now,
        privacyEpoch: await _currentPrivacyEpoch(),
        detailMessage: 'Deleted a ${state.name} sync record',
      );
    } on Exception catch (e, st) {
      _log.error('Discard succeeded but the activity event failed', e, st);
    }
  }

  Future<int> _currentPrivacyEpoch() async {
    final row = await (_database.select(
      _database.appSettings,
    )..where((s) => s.singletonId.equals(1))).getSingleOrNull();
    return row?.privacyEpoch ?? 0;
  }
}
