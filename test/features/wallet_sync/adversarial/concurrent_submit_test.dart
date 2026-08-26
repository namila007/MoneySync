import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// G4.1 — Two concurrent `submit()` calls for the same candidate must never
/// produce two remote creates. The protection is multi-layered:
///
/// 1. The partial unique index on `(candidate_id, lineage_generation)` for
///    operation_kind='create' and non-terminal states prevents two active
///    mutations sharing a generation.
/// 2. The controller's `submitting` flag (UI-level double-submit guard).
/// 3. The transition table has no `syncing -> syncing` edge.
///
/// This test proves the structural invariants that prevent duplicate financial
/// records — the highest-severity defect class for a wallet integration.
void main() {
  late AppDatabase db;
  late WalletMutationsDao dao;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    dao = WalletMutationsDao(database: db);
  });
  tearDown(() => db.close());

  Future<void> seedMutation({
    required String id,
    required String candidateId,
    required WalletMutationState state,
    int lineageGeneration = 1,
  }) async {
    await db
        .into(db.walletMutations)
        .insert(
          WalletMutationsCompanion.insert(
            id: id,
            operationKind: WalletMutationOperation.create,
            payload: '{"accountId":"acc-1","amountMinor":-4425}',
            state: state,
            lineageKey: 'lineage-$id',
            fingerprint: 'fp-$id',
            createdAtEpochMs: 1700000000000,
            updatedAtEpochMs: 1700000000000,
            candidateId: Value(candidateId),
            operationRevision: const Value(1),
            lineageGeneration: Value(lineageGeneration),
          ),
        );
  }

  test('partial unique index blocks two non-terminal mutations for the same '
      'candidate+generation', () async {
    // The partial unique index on (candidate_id, lineage_generation) for
    // operation_kind='create' and state IN (queued,syncing,...) prevents
    // duplicate mutations. Two submit() calls on the same candidate both
    // produce generation=1 mutations — the second insert MUST fail.
    await seedMutation(
      id: 'm-1',
      candidateId: 'cand-1',
      state: WalletMutationState.queued,
      lineageGeneration: 1,
    );

    // Same candidate, same generation, also queued → must violate the index.
    expect(
      () => seedMutation(
        id: 'm-2',
        candidateId: 'cand-1',
        state: WalletMutationState.queued,
        lineageGeneration: 1,
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('UNIQUE constraint failed'),
        ),
      ),
      reason:
          'the partial unique index must reject a second non-terminal '
          'mutation with the same candidate+generation, preventing '
          'duplicate remote creates',
    );
  });

  test(
    'two mutations for the same candidate with different generations can coexist',
    () async {
      // Different lineage generations represent independent submissions (e.g.
      // user edited and re-submitted). Both can exist as queued because the
      // partial index keys on (candidate_id, lineage_generation).
      await seedMutation(
        id: 'm-1',
        candidateId: 'cand-1',
        state: WalletMutationState.queued,
        lineageGeneration: 1,
      );
      await seedMutation(
        id: 'm-2',
        candidateId: 'cand-1',
        state: WalletMutationState.queued,
        lineageGeneration: 2,
      );

      final mutations = await (db.select(
        db.walletMutations,
      )..where((m) => m.candidateId.equals('cand-1'))).get();
      expect(
        mutations.length,
        2,
        reason: 'different generations are independent submissions',
      );
    },
  );

  test('transition table has no syncing->syncing edge', () async {
    // Even if the lease gate were bypassed, the state machine forbids
    // syncing -> syncing. This prevents a second worker from re-entering
    // the same mutation and risking a duplicate remote create.
    expect(
      WalletMutationState.syncing.canTransitionTo(WalletMutationState.syncing),
      isFalse,
      reason:
          'syncing -> syncing would allow two workers to transmit '
          'the same mutation, risking a duplicate remote record',
    );
  });

  test('succeeded is terminal — once one mutation succeeds, no second can '
      're-enter the pipeline', () async {
    // The transition table marks succeeded as a terminal state (no outgoing
    // edges). This is the structural guarantee that, after one mutation
    // succeeds for a candidate, a second mutation sharing that candidate
    // cannot independently reach succeeded.
    expect(
      WalletMutationState.succeeded.canTransitionTo(
        WalletMutationState.syncing,
      ),
      isFalse,
      reason: 'succeeded is terminal — no path back to syncing',
    );
    expect(
      WalletMutationState.succeeded.canTransitionTo(WalletMutationState.queued),
      isFalse,
      reason: 'succeeded is terminal — no path back to queued',
    );
  });

  test(
    'lease claim is per-row — two workers cannot claim the same mutation',
    () async {
      // The lease gate is the runtime guard: claimLease uses an
      // affected-row-count to ensure exactly one worker wins. Two workers
      // trying to claim the same row get (true, false) — never (true, true).
      await seedMutation(
        id: 'm-1',
        candidateId: 'cand-1',
        state: WalletMutationState.queued,
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      final leaseUntil = now + 30000;

      final claim1 = await dao.claimLease(
        id: 'm-1',
        leaseUntilEpochMs: leaseUntil,
        nowEpochMs: now,
      );
      expect(claim1, isTrue, reason: 'first worker wins the claim');

      // Second worker tries to claim the same row — must fail.
      final claim2 = await dao.claimLease(
        id: 'm-1',
        leaseUntilEpochMs: leaseUntil + 30000,
        nowEpochMs: now,
      );
      expect(
        claim2,
        isFalse,
        reason: 'second worker must not claim a row with an active lease',
      );
    },
  );
}
