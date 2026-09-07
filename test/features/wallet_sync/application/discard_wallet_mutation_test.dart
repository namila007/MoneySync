import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/wallet_sync/application/discard_wallet_mutation.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

void main() {
  late AppDatabase db;
  late WalletMutationsDao dao;
  late DiscardWalletMutation discard;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    dao = WalletMutationsDao(database: db);
    discard = DiscardWalletMutation(database: db);
  });

  tearDown(() => db.close());

  WalletMutationIntent intent(String id, WalletMutationState state) =>
      WalletMutationIntent(
        id: id,
        candidateId: 'c-$id',
        operation: WalletMutationOperation.create,
        operationRevision: 1,
        lineageGeneration: 1,
        createLineageKey: 'lk-$id',
        transactionFingerprint: 'fp-$id',
        payload: const {'amountMinor': 1000},
        state: state,
      );

  Future<int> activityCount() async =>
      (await db.select(db.activityEvents).get()).length;

  Future<int?> discardedAt(String id) async => (await (db.select(
    db.walletMutations,
  )..where((m) => m.id.equals(id))).getSingle()).discardedAtEpochMs;

  test('discards a retry-scheduled row and logs one activity event', () async {
    await dao.upsert(intent('m1', WalletMutationState.retryScheduled));

    await discard(mutationId: 'm1');

    expect(await discardedAt('m1'), isNotNull);
    expect(await activityCount(), 1);
    final event = (await db.select(db.activityEvents).get()).single;
    expect(event.eventType, ActivityEventCode.walletRecordDiscarded);
  });

  test(
    'discards a succeeded row (row + lineage guard stay in place)',
    () async {
      await dao.upsert(intent('m2', WalletMutationState.succeeded));

      await discard(mutationId: 'm2');

      final row = await (db.select(
        db.walletMutations,
      )..where((m) => m.id.equals('m2'))).getSingle();
      expect(row.discardedAtEpochMs, isNotNull);
      expect(row.state, WalletMutationState.succeeded);
    },
  );

  test('refuses an in-flight (syncing) row', () async {
    await dao.upsert(intent('m3', WalletMutationState.syncing));

    await expectLater(
      discard(mutationId: 'm3'),
      throwsA(isA<WalletMutationInFlightFailure>()),
    );
    expect(await discardedAt('m3'), isNull);
    expect(await activityCount(), 0);
  });

  test('refuses a reconciling row', () async {
    await dao.upsert(intent('m4', WalletMutationState.reconciling));
    await expectLater(
      discard(mutationId: 'm4'),
      throwsA(isA<WalletMutationInFlightFailure>()),
    );
  });

  test('silent no-op for an unknown id', () async {
    await discard(mutationId: 'ghost');
    expect(await activityCount(), 0);
  });

  test('already-discarded row writes no second activity event', () async {
    await dao.upsert(intent('m5', WalletMutationState.retryScheduled));
    await discard(mutationId: 'm5');
    await discard(mutationId: 'm5');
    expect(await activityCount(), 1);
  });
}
