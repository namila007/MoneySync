import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/wallet_sync/application/wallet_mutation_recovery_service.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

void main() {
  late AppDatabase database;
  late WalletMutationsDao dao;

  setUp(() {
    database = AppDatabase.inMemoryForTesting();
    dao = WalletMutationsDao(database: database);
  });

  tearDown(() => database.close());

  WalletMutationIntent intent({
    String id = 'mutation-1',
    String candidateId = 'candidate-1',
    WalletMutationState state = WalletMutationState.queued,
  }) => WalletMutationIntent(
    id: id,
    candidateId: candidateId,
    operation: WalletMutationOperation.create,
    operationRevision: 1,
    lineageGeneration: 1,
    createLineageKey: 'lineage-key-1',
    transactionFingerprint: 'fingerprint-1',
    payload: const <String, Object?>{'amountMinor': -4500, 'currency': 'LKR'},
    state: state,
  );

  test('upsert then byId round-trips the intent', () async {
    await dao.upsert(intent());
    final loaded = await dao.byId('mutation-1');
    expect(loaded, isNotNull);
    expect(loaded!.operation, WalletMutationOperation.create);
    expect(loaded.candidateId, 'candidate-1');
    expect(loaded.createLineageKey, 'lineage-key-1');
    expect(loaded.transactionFingerprint, 'fingerprint-1');
    expect(loaded.payload, {'amountMinor': -4500, 'currency': 'LKR'});
  });

  test('claimLease wins only once against a live lease', () async {
    await dao.upsert(intent());
    final now = DateTime.now().millisecondsSinceEpoch;

    final first = await dao.claimLease(
      id: 'mutation-1',
      leaseUntilEpochMs: now + 60_000,
      nowEpochMs: now,
    );
    expect(first, isTrue);

    // Second worker cannot claim while the lease is live.
    final second = await dao.claimLease(
      id: 'mutation-1',
      leaseUntilEpochMs: now + 120_000,
      nowEpochMs: now + 1,
    );
    expect(second, isFalse);

    // After expiry a new claim succeeds.
    final expired = await dao.claimLease(
      id: 'mutation-1',
      leaseUntilEpochMs: now + 180_000,
      nowEpochMs: now + 120_000,
    );
    expect(expired, isTrue);
  });

  test('claimsWithLiveLease returns only leased queued/retry rows', () async {
    await dao.upsert(intent(id: 'm1', candidateId: 'candidate-1'));
    await dao.upsert(
      intent(
        id: 'm2',
        candidateId: 'candidate-2',
        state: WalletMutationState.retryScheduled,
      ),
    );
    await dao.upsert(
      intent(
        id: 'm3',
        candidateId: 'candidate-3',
        state: WalletMutationState.succeeded,
      ),
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    await dao.claimLease(
      id: 'm1',
      leaseUntilEpochMs: now + 60_000,
      nowEpochMs: now,
    );
    await dao.claimLease(
      id: 'm2',
      leaseUntilEpochMs: now + 60_000,
      nowEpochMs: now,
    );
    await dao.claimLease(
      id: 'm3',
      leaseUntilEpochMs: now + 60_000,
      nowEpochMs: now,
    );

    final claims = await dao.claimsWithLiveLease(nowEpochMs: now);
    expect(claims.map((i) => i.id).toSet(), {'m1', 'm2'});
  });

  test('transitionTo persists only legal transitions', () async {
    await dao.upsert(intent());
    final loaded = await dao.byId('mutation-1');
    await dao.transitionTo(intent: loaded!, next: WalletMutationState.syncing);

    final after = await dao.byId('mutation-1');
    expect(after!.state, WalletMutationState.syncing);
  });

  test('illegal transition throws and leaves the row unchanged', () async {
    await dao.upsert(intent());
    final loaded = await dao.byId('mutation-1');
    // queued -> reconciling is illegal.
    expect(
      () => dao.transitionTo(
        intent: loaded!,
        next: WalletMutationState.reconciling,
      ),
      throwsA(isA<InvalidStateTransitionFailure>()),
    );
    final after = await dao.byId('mutation-1');
    expect(after!.state, WalletMutationState.queued);
  });

  group('WalletMutationRecoveryService', () {
    test('lands interrupted syncing rows on reconciling', () async {
      await dao.upsert(
        intent(
          id: 'm1',
          candidateId: 'candidate-1',
          state: WalletMutationState.syncing,
        ),
      );
      await dao.upsert(
        intent(
          id: 'm2',
          candidateId: 'candidate-2',
          state: WalletMutationState.syncing,
        ),
      );
      // A live lease means the row is NOT interrupted.
      final now = DateTime.now().millisecondsSinceEpoch;
      await dao.claimLease(
        id: 'm2',
        leaseUntilEpochMs: now + 600_000,
        nowEpochMs: now,
      );

      final service = WalletMutationRecoveryService(
        dao: dao,
        nowEpochMs: () => now + 120_000,
      );
      final recovered = await service.recoverInterrupted();

      expect(recovered, 1);
      final m1 = await dao.byId('m1');
      expect(m1!.state, WalletMutationState.reconciling);
      final m2 = await dao.byId('m2');
      expect(m2!.state, WalletMutationState.syncing);
    });

    test('never resumes syncing -> syncing (structural guarantee)', () async {
      await dao.upsert(intent(id: 'm1', state: WalletMutationState.syncing));
      final now = DateTime.now().millisecondsSinceEpoch;
      final service = WalletMutationRecoveryService(
        dao: dao,
        nowEpochMs: () => now + 1,
      );
      await service.recoverInterrupted();

      final row = await database
          .customSelect(
            'SELECT state FROM wallet_mutations WHERE id = ?',
            variables: [Variable('m1')],
          )
          .getSingle();
      expect(row.read<String>('state'), 'reconciling');
    });
  });
}
