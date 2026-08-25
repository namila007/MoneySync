import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/application/wallet_mutation_recovery_service.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// M5.22 WP-E. Reconciliation is the go/no-go gate for writes (plan/05:167):
/// "Retry POST only after the API can conclusively prove the original create
/// did not succeed; one negative or lagging read is not proof."
///
/// These exist to stop a future change turning an ambiguous or failed lookup
/// into a retry — that would duplicate a real financial record.
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

  const marker = 'ABCDEFGH1234JKMNPQRS';

  Future<void> seed({
    required WalletMutationState state,
    String id = 'm-1',
    String? note = '[sw:$marker] coffee',
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
            candidateId: Value('cand-$id'),
            operationRevision: const Value(1),
            lineageGeneration: const Value(1),
          ),
        );
    if (note != null) {
      await db
          .into(db.walletMutationItems)
          .insert(
            WalletMutationItemsCompanion.insert(
              walletMutationId: id,
              itemIndex: 0,
              legRole: WalletItemLegRole.primary,
              payloadCiphertext: '[{"note":"$note"}]',
              state: state,
            ),
          );
    }
  }

  Future<WalletMutationState> stateOf(String id) async {
    final row = await (db.select(
      db.walletMutations,
    )..where((m) => m.id.equals(id))).getSingle();
    return row.state;
  }

  WalletRecordRead record(String id) =>
      WalletRecordRead(id: id, amountMinor: -4425, currencyCode: 'LKR');

  test(
    'an unknown outcome routes through reconciling, never straight to retry',
    () async {
      await seed(state: WalletMutationState.unknownDelivery);
      await service.reconcilePending(
        findByMarker: (_) async => [record('r-1')],
      );
      expect(await stateOf('m-1'), WalletMutationState.succeeded);
    },
  );

  test('a found record settles as succeeded', () async {
    await seed(state: WalletMutationState.reconciling);
    final settled = await service.reconcilePending(
      findByMarker: (_) async => [record('r-1')],
    );
    expect(settled, 1);
    expect(await stateOf('m-1'), WalletMutationState.succeeded);
  });

  test(
    'a record proven absent is the ONLY case that schedules a retry',
    () async {
      await seed(state: WalletMutationState.reconciling);
      await service.reconcilePending(findByMarker: (_) async => const []);
      expect(await stateOf('m-1'), WalletMutationState.retryScheduled);
    },
  );

  test('a failed lookup holds the mutation and never retries', () async {
    await seed(state: WalletMutationState.reconciling);
    await service.reconcilePending(
      findByMarker: (_) async => throw Exception('network down'),
    );
    expect(
      await stateOf('m-1'),
      WalletMutationState.reconciling,
      reason: 'a failed read is not proof of absence',
    );
  });

  test('an ambiguous marker holds the mutation rather than guessing', () async {
    await seed(state: WalletMutationState.reconciling);
    await service.reconcilePending(
      findByMarker: (_) async => [record('r-1'), record('r-2')],
    );
    expect(
      await stateOf('m-1'),
      WalletMutationState.reconciling,
      reason: 'two records share the marker — picking one could mislink money',
    );
  });

  test('a missing marker holds the mutation for manual verification', () async {
    await seed(state: WalletMutationState.reconciling, note: null);
    await service.reconcilePending(findByMarker: (_) async => const []);
    expect(
      await stateOf('m-1'),
      WalletMutationState.reconciling,
      reason: 'without the key we cannot ask, so we must not retry',
    );
  });

  test(
    'markerFor extracts the marker from the serialized create body',
    () async {
      await seed(state: WalletMutationState.reconciling);
      expect(await dao.markerFor('m-1'), marker);
    },
  );
}
