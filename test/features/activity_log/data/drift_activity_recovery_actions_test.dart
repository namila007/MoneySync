import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/data/drift_activity_recovery_actions.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// M5.14 gap 5: production recovery actions move the REAL mutation row.
void main() {
  late AppDatabase db;
  late WalletMutationsDao dao;
  late DriftActivityRecoveryActions actions;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    dao = WalletMutationsDao(database: db);
    actions = DriftActivityRecoveryActions(dao: dao);
  });

  tearDown(() => db.close());

  Future<void> insert({
    required String id,
    required WalletMutationState state,
  }) async {
    await db
        .into(db.walletMutations)
        .insert(
          WalletMutationsCompanion.insert(
            id: id,
            operationKind: WalletMutationOperation.create,
            payload: '{}',
            state: state,
            lineageKey: 'lineage-$id',
            fingerprint: 'fingerprint-$id',
            createdAtEpochMs: 1_700_000_000_000,
            updatedAtEpochMs: 1_700_000_000_000,
            candidateId: Value('candidate-$id'),
            operationRevision: const Value(1),
            lineageGeneration: const Value(1),
          ),
        );
  }

  Future<WalletMutationState> stateOf(String id) async => (await (db.select(
    db.walletMutations,
  )..where((t) => t.id.equals(id))).getSingle()).state;

  test('retryNow expedites a retry-scheduled mutation to syncing', () async {
    await insert(id: 'm-1', state: WalletMutationState.retryScheduled);
    await actions.retryNow('m-1');
    expect(await stateOf('m-1'), WalletMutationState.syncing);
  });

  test('retryNow is a no-op for a queued or missing mutation', () async {
    await insert(id: 'm-2', state: WalletMutationState.queued);
    await actions.retryNow('m-2');
    expect(await stateOf('m-2'), WalletMutationState.queued);
    await actions.retryNow('missing'); // must not throw
  });

  test(
    'verifyInWallet moves an unknown-delivery mutation to reconciling',
    () async {
      await insert(id: 'm-3', state: WalletMutationState.unknownDelivery);
      await actions.verifyInWallet('m-3');
      expect(await stateOf('m-3'), WalletMutationState.reconciling);
    },
  );

  test('verifyInWallet is a no-op for a non-unknown mutation', () async {
    await insert(id: 'm-4', state: WalletMutationState.succeeded);
    await actions.verifyInWallet('m-4');
    expect(await stateOf('m-4'), WalletMutationState.succeeded);
    await actions.verifyInWallet('missing'); // must not throw
  });
}
