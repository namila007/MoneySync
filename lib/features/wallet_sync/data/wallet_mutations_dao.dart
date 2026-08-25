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

  /// Transitions the candidate row linked to [candidateId] to [newState].
  /// Called after a successful create so the candidate leaves `needsReview`.
  Future<void> transitionCandidateState({
    required String candidateId,
    required String newState,
  }) async {
    await _database.customUpdate(
      'UPDATE transaction_candidates SET state = ? '
      'WHERE candidate_id = ?',
      variables: [Variable(newState), Variable(candidateId)],
      updates: {_database.transactionCandidates},
    );
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

  /// Mutations currently in any of [states] (M5.22 WP-E).
  Future<List<WalletMutationIntent>> byStates(
    List<WalletMutationState> states,
  ) async {
    if (states.isEmpty) return const [];
    final stored = states.map(_storedState).toList();
    final rows = await (_database.select(
      _database.walletMutations,
    )..where((t) => t.state.isIn(stored))).get();
    return rows.map(_fromRow).toList();
  }

  /// Mutations whose retry deadline has passed (M5.22 WP-E).
  Future<List<WalletMutationIntent>> retriesDue({
    required int nowEpochMs,
  }) async {
    final rows =
        await (_database.select(_database.walletMutations)..where(
              (t) =>
                  t.state.equals(
                    _storedState(WalletMutationState.retryScheduled),
                  ) &
                  (t.nextAttemptAtEpochMs.isNull() |
                      t.nextAttemptAtEpochMs.isSmallerOrEqualValue(nowEpochMs)),
            ))
            .get();
    return rows.map(_fromRow).toList();
  }

  /// The `[sw:…]` source marker for [mutationId], or null when absent.
  ///
  /// The marker is the reconciliation key (plan/05:159), but it is not stored
  /// on the mutation row — it lives inside the serialized create body on
  /// `wallet_mutation_item`, so reconciliation has to reach across to find
  /// its own lookup key.
  Future<String?> markerFor(String mutationId) async {
    final rows = await (_database.select(
      _database.walletMutationItems,
    )..where((t) => t.walletMutationId.equals(mutationId))).get();
    for (final row in rows) {
      try {
        final decoded = jsonDecode(row.payloadCiphertext);
        final map = decoded is List && decoded.isNotEmpty
            ? decoded.first
            : decoded;
        final note = (map is Map) ? map['note'] : null;
        if (note is! String) continue;
        final match = RegExp(r'\[sw:([0-9A-Z]+)\]').firstMatch(note);
        if (match != null) return match.group(1);
      } on FormatException {
        continue;
      }
    }
    return null;
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
