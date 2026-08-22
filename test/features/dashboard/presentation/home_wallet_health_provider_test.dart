import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/dashboard/presentation/home_wallet_health.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// M5.14 gap 4: the home "Latest Wallet transaction" card reads amount +
/// currency from the linked create mutation's payload, not a hardcoded
/// LKR 0.00.
void main() {
  test(
    'home health reads amount + currency from the linked mutation payload',
    () async {
      final db = AppDatabase.inMemoryForTesting();

      final eventId = await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'source-link',
              senderKey: 'BANK ALPHA',
              ingestionSource: 'manual_paste',
              receivedAtEpochMs: 1_700_000_000_000,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
            ),
          );
      await db
          .into(db.transactionCandidates)
          .insert(
            TransactionCandidatesCompanion.insert(
              smsEventId: eventId,
              state: CandidateRecordState.retainedLocal,
              encryptedPayload: '{}',
              revision: 1,
              createdAtEpochMs: 1_700_000_000_000,
              candidateId: const Value('candidate-1'),
            ),
          );
      await db
          .into(db.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: 'mutation-1',
              operationKind: WalletMutationOperation.create,
              payload:
                  '{"accountId":"account-1","amountMinor":-123456,'
                  '"currencyCode":"LKR"}',
              state: WalletMutationState.succeeded,
              lineageKey: 'lineage-1',
              fingerprint: 'fingerprint-1',
              createdAtEpochMs: 1_700_000_000_000,
              updatedAtEpochMs: 1_700_000_000_000,
              candidateId: const Value('candidate-1'),
              operationRevision: const Value(1),
              lineageGeneration: const Value(1),
            ),
          );
      await db
          .into(db.walletRecordLinks)
          .insert(
            WalletRecordLinksCompanion.insert(
              id: 'link-1',
              appId: 'app-link-1',
              remoteId: const Value('remote-1'),
              createdAtEpochMs: 1_700_000_000_000,
              candidateId: const Value('candidate-1'),
            ),
          );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );
      addTearDown(container.dispose);

      final health = await _firstHealth(container);

      expect(health.latestRecord, isNotNull);
      expect(health.latestRecord!.amountMinor, -123456);
      expect(health.latestRecord!.currencyCode, 'LKR');
      expect(health.latestRecord!.remoteId, 'remote-1');
    },
  );

  test(
    'home health degrades to LKR 0.00 when the payload has no amount',
    () async {
      final db = AppDatabase.inMemoryForTesting();

      final eventId = await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'source-null',
              senderKey: 'BANK BETA',
              ingestionSource: 'manual_paste',
              receivedAtEpochMs: 1_700_000_000_000,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
            ),
          );
      await db
          .into(db.transactionCandidates)
          .insert(
            TransactionCandidatesCompanion.insert(
              smsEventId: eventId,
              state: CandidateRecordState.retainedLocal,
              encryptedPayload: '{}',
              revision: 1,
              createdAtEpochMs: 1_700_000_000_000,
              candidateId: const Value('candidate-2'),
            ),
          );
      await db
          .into(db.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: 'mutation-2',
              operationKind: WalletMutationOperation.create,
              payload: '{"accountId":"account-1"}',
              state: WalletMutationState.succeeded,
              lineageKey: 'lineage-2',
              fingerprint: 'fingerprint-2',
              createdAtEpochMs: 1_700_000_000_000,
              updatedAtEpochMs: 1_700_000_000_000,
              candidateId: const Value('candidate-2'),
              operationRevision: const Value(1),
              lineageGeneration: const Value(1),
            ),
          );
      await db
          .into(db.walletRecordLinks)
          .insert(
            WalletRecordLinksCompanion.insert(
              id: 'link-2',
              appId: 'app-link-2',
              createdAtEpochMs: 1_700_000_000_000,
              candidateId: const Value('candidate-2'),
            ),
          );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );
      addTearDown(container.dispose);

      final health = await _firstHealth(container);

      expect(health.latestRecord, isNotNull);
      expect(health.latestRecord!.amountMinor, 0);
      expect(health.latestRecord!.currencyCode, 'LKR');
    },
  );
}

/// Holds a subscription to the autoDispose provider so it stays alive until
/// the first emission, then returns that first value.
Future<HomeWalletHealth> _firstHealth(ProviderContainer container) async {
  final completer = Completer<HomeWalletHealth>();
  final sub = container.listen<AsyncValue<HomeWalletHealth>>(
    homeWalletHealthProvider,
    (_, next) {
      if (next.hasValue && !completer.isCompleted) {
        completer.complete(next.requireValue);
      }
    },
  );
  final value = await completer.future;
  sub.close();
  return value;
}
