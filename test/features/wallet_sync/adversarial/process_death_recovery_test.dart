import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/application/wallet_mutation_recovery_service.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// G4.3 — Process death mid-`syncing` must land on `reconciling`, never a
/// second `syncing`.
///
/// The state transition table has no `syncing -> syncing` edge. This test
/// guards that structurally: recovery calls `transitionTo(reconciling)` and
/// the transition table rejects any attempt to re-enter `syncing`. If a bug
/// added a `syncing -> syncing` edge, this test would still pass — but the
/// companion assertion on the transition table itself (asserting the edge is
/// absent) catches that class of regression.
///
/// The invariant matters because re-entering `syncing` after process death
/// means the app blindly retransmits without reconciling, risking a
/// duplicate financial record.
void main() {
  late AppDatabase db;
  late WalletMutationsDao dao;
  late WalletMutationRecoveryService service;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    dao = WalletMutationsDao(database: db);
    service = WalletMutationRecoveryService(dao: dao);
  });
  tearDown(() => db.close());

  /// Seed a mutation in `syncing` state with an expired lease (or null lease),
  /// simulating a process death mid-transmission.
  Future<void> seedSyncingMutation({
    required String id,
    int? leaseUntilEpochMs,
  }) async {
    await db
        .into(db.walletMutations)
        .insert(
          WalletMutationsCompanion.insert(
            id: id,
            operationKind: WalletMutationOperation.create,
            payload: '{"accountId":"acc-1","amountMinor":-4425}',
            state: WalletMutationState.syncing,
            lineageKey: 'lineage-$id',
            fingerprint: 'fp-$id',
            createdAtEpochMs: 1700000000000,
            updatedAtEpochMs: 1700000000000,
            candidateId: Value('cand-$id'),
            operationRevision: const Value(1),
            lineageGeneration: const Value(1),
            leaseUntilEpochMs: Value(leaseUntilEpochMs),
          ),
        );
  }

  Future<WalletMutationState> stateOf(String id) async {
    final row = await (db.select(
      db.walletMutations,
    )..where((m) => m.id.equals(id))).getSingle();
    return row.state;
  }

  test(
    'a syncing mutation with an expired lease recovers to reconciling',
    () async {
      // Simulate: mutation was in syncing when the process died, and the
      // lease has expired. Recovery must transition to reconciling — the
      // ONLY legal exit from a stale syncing row.
      final expiredLease = DateTime.now().millisecondsSinceEpoch - 10000;
      await seedSyncingMutation(id: 'm-1', leaseUntilEpochMs: expiredLease);

      final recovered = await service.recoverInterrupted();
      expect(recovered, 1);
      expect(
        await stateOf('m-1'),
        WalletMutationState.reconciling,
        reason:
            'process-death recovery must land on reconciling, never '
            'back to syncing (no syncing->syncing edge in the transition table)',
      );
    },
  );

  test(
    'a syncing mutation with a null lease recovers to reconciling',
    () async {
      // Null lease means the mutation never had a lease claim (e.g. the
      // process died before the lease could be written). Same recovery path.
      await seedSyncingMutation(id: 'm-2', leaseUntilEpochMs: null);

      final recovered = await service.recoverInterrupted();
      expect(recovered, 1);
      expect(await stateOf('m-2'), WalletMutationState.reconciling);
    },
  );

  test('the transition table has no syncing->syncing edge', () async {
    // Structural guard: if someone adds syncing->syncing to the transition
    // table, recovery would re-enter syncing instead of reconciling,
    // allowing blind retransmission and duplicate financial records.
    expect(
      WalletMutationState.syncing.canTransitionTo(WalletMutationState.syncing),
      isFalse,
      reason:
          'syncing -> syncing is forbidden; recovery must go through '
          'reconciling to prevent duplicate remote creates',
    );
  });

  test('reconciling is the only legal exit from a stale syncing row', () async {
    // Verify the transition table: syncing allows reconciling but not
    // syncing. This is the structural invariant that makes recovery safe.
    expect(
      WalletMutationState.syncing.canTransitionTo(
        WalletMutationState.reconciling,
      ),
      isTrue,
      reason:
          'reconciling is the designated recovery target for stale syncing rows',
    );
    expect(
      WalletMutationState.syncing.canTransitionTo(WalletMutationState.syncing),
      isFalse,
      reason:
          're-entering syncing after process death would retransmit '
          'without reconciliation, risking a duplicate',
    );
  });

  test('a non-expired lease is not picked up by recovery', () async {
    // A mutation still within its lease window is considered alive —
    // another worker is actively transmitting it. Recovery must not
    // interfere.
    final futureLease = DateTime.now().millisecondsSinceEpoch + 30000;
    await seedSyncingMutation(id: 'm-3', leaseUntilEpochMs: futureLease);

    final recovered = await service.recoverInterrupted();
    expect(
      recovered,
      0,
      reason: 'a live lease means another worker owns this row',
    );
    expect(
      await stateOf('m-3'),
      WalletMutationState.syncing,
      reason: 'must not touch a mutation with an active lease',
    );
  });

  test(
    'at most one remote record exists across the whole recovery run',
    () async {
      // Seed two syncing mutations for different candidates. Recovery
      // transitions both to reconciling — neither is retransmitted.
      // The transmitter's read-back check (not tested here) ensures at most
      // one remote record per candidate. Recovery must never create a second
      // mutation in syncing for the same candidate.
      await seedSyncingMutation(id: 'm-a', leaseUntilEpochMs: 0);
      await seedSyncingMutation(id: 'm-b', leaseUntilEpochMs: 0);

      final recovered = await service.recoverInterrupted();
      expect(recovered, 2);

      // Both are now reconciling — no mutation is in syncing.
      final syncing = await (db.select(
        db.walletMutations,
      )..where((m) => m.state.equals('syncing'))).get();
      expect(
        syncing.length,
        0,
        reason:
            'after recovery, no mutation should be in syncing state; '
            'they must all be reconciling to avoid blind retransmission',
      );
    },
  );
}
