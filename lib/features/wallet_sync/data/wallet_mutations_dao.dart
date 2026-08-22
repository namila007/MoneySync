import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// Maps [WalletMutationIntent] onto the widened `wallet_mutations` table
/// (M5.1/M5.5). Reuses the existing `WalletMutationState` transition table —
/// no new state-machine logic. Foreground-only for M5 (no WorkManager).
final class WalletMutationsDao {
  WalletMutationsDao({required this._database});

  final AppDatabase _database;

  /// Inserts (or overwrites) one mutation row from an intent snapshot.
  Future<void> upsert(WalletMutationIntent intent) async {
    await _database
        .into(_database.walletMutations)
        .insertOnConflictUpdate(
          WalletMutationsCompanion.insert(
            id: intent.id,
            operationKind: intent.operation,
            payload: jsonEncode(intent.payload),
            state: intent.state,
            lineageKey: intent.createLineageKey,
            fingerprint: intent.transactionFingerprint,
            createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            candidateId: Value(intent.candidateId),
            operationRevision: Value(intent.operationRevision),
            lineageGeneration: Value(intent.lineageGeneration),
          ),
        );
  }

  /// Optimistic lease claim: updates `lease_until` in place for the row only
  /// if no live lease exists, returning whether this worker won the claim.
  /// Checked via affected-row-count — no external lock manager (M5.5).
  Future<bool> claimLease({
    required String id,
    required int leaseUntilEpochMs,
    required int nowEpochMs,
  }) async {
    final rows = await _database.customUpdate(
      'UPDATE wallet_mutations SET lease_until_epoch_ms = ?, '
      'updated_at_epoch_ms = ? '
      'WHERE id = ? AND (lease_until_epoch_ms IS NULL OR '
      'lease_until_epoch_ms < ?)',
      variables: [
        Variable(leaseUntilEpochMs),
        Variable(nowEpochMs),
        Variable(id),
        Variable(nowEpochMs),
      ],
      updates: {_database.walletMutations},
    );
    return rows == 1;
  }

  /// State transition persisted only when the existing transition table
  /// allows it. [intent] carries the current state; [next] is the target.
  Future<WalletMutationIntent> transitionTo({
    required WalletMutationIntent intent,
    required WalletMutationState next,
  }) async {
    final transitioned = intent.transitionTo(next);
    await _database.customUpdate(
      'UPDATE wallet_mutations SET state = ?, updated_at_epoch_ms = ? '
      'WHERE id = ?',
      variables: [
        Variable(_storedState(transitioned.state)),
        Variable(DateTime.now().millisecondsSinceEpoch),
        Variable(intent.id),
      ],
      updates: {_database.walletMutations},
    );
    return transitioned;
  }

  /// Marks a row retry-scheduled with its next-attempt deadline, atomically
  /// with the state transition (backoff computed by the caller).
  Future<WalletMutationIntent> scheduleRetry({
    required WalletMutationIntent intent,
    required int nextAttemptAtEpochMs,
    required int attemptCount,
  }) async {
    final transitioned = intent.transitionTo(
      WalletMutationState.retryScheduled,
    );
    await _database.customUpdate(
      'UPDATE wallet_mutations SET state = ?, attempt_count = ?, '
      'next_attempt_at_epoch_ms = ?, updated_at_epoch_ms = ? WHERE id = ?',
      variables: [
        Variable(_storedState(transitioned.state)),
        Variable(attemptCount),
        Variable(nextAttemptAtEpochMs),
        Variable(DateTime.now().millisecondsSinceEpoch),
        Variable(intent.id),
      ],
      updates: {_database.walletMutations},
    );
    return transitioned;
  }

  /// The mutation row for [id], or null.
  Future<WalletMutationIntent?> byId(String id) async {
    final rows = await (_database.select(
      _database.walletMutations,
    )..where((t) => t.id.equals(id))).get();
    if (rows.isEmpty) return null;
    return _fromRow(rows.single);
  }

  /// Rows currently claimed by a live lease (`queued` or `retry_scheduled`
  /// with a non-expired lease), for the foreground worker to process.
  Future<List<WalletMutationIntent>> claimsWithLiveLease({
    required int nowEpochMs,
    int limit = 20,
  }) async {
    final rows =
        await (_database.select(_database.walletMutations)
              ..where(
                (t) =>
                    (t.state.equals(_storedState(WalletMutationState.queued)) |
                        t.state.equals(
                          _storedState(WalletMutationState.retryScheduled),
                        )) &
                    t.leaseUntilEpochMs.isBiggerOrEqualValue(nowEpochMs),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.leaseUntilEpochMs)])
              ..limit(limit))
            .get();
    return rows.map(_fromRow).toList();
  }

  /// Rows that were mid-transmission when a process died: `syncing` with an
  /// expired lease. These must land on `reconciling`, never straight back to
  /// `syncing` (enforced structurally by the transition table).
  Future<List<WalletMutationIntent>> syncingWithExpiredLease({
    required int nowEpochMs,
  }) async {
    final rows =
        await (_database.select(_database.walletMutations)..where(
              (t) =>
                  t.state.equals(_storedState(WalletMutationState.syncing)) &
                  (t.leaseUntilEpochMs.isNull() |
                      t.leaseUntilEpochMs.isSmallerThanValue(nowEpochMs)),
            ))
            .get();
    return rows.map(_fromRow).toList();
  }

  static String _storedState(WalletMutationState state) =>
      const WalletMutationStateConverter().toSql(state);

  WalletMutationIntent _fromRow(WalletMutation row) {
    final decoded = jsonDecode(row.payload);
    return WalletMutationIntent(
      id: row.id,
      candidateId: row.candidateId ?? '',
      operation: row.operationKind,
      operationRevision: row.operationRevision ?? 1,
      lineageGeneration: row.lineageGeneration ?? 1,
      createLineageKey: row.lineageKey,
      transactionFingerprint: row.fingerprint,
      payload: decoded is Map<String, Object?>
          ? decoded
          : const <String, Object?>{},
      state: row.state,
    );
  }
}
