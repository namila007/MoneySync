import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/waiting_item_detail_page.dart';

void main() {
  group('WaitingItemDetailPage', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> insertQueued(
      AppDatabase database, {
      String id = 'm-detail-1',
      String? candidateId,
      WalletMutationState state = WalletMutationState.queued,
    }) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: id,
              operationKind: WalletMutationOperation.create,
              payload:
                  '{"amountMinor":7500,"currencyCode":"LKR","kind":"expense",'
                  '"direction":"debit","paymentType":"debit_card",'
                  '"accountId":"acc-1","categoryId":"cat-1",'
                  '"counterParty":"Test Shop"}',
              state: state,
              lineageKey: 'lineage-$id',
              fingerprint: 'fp-$id',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: 1000000,
              candidateId: Value(candidateId),
            ),
          );
    }

    /// Seeds an sms_event + a needsReview candidate whose stable UUID is
    /// [candidateId], so a reject can be pointed back at it.
    Future<void> insertReviewedCandidate(
      AppDatabase database,
      String candidateId,
    ) async {
      final eventId = await database
          .into(database.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'source-$candidateId',
              senderKey: 'BANK ALPHA',
              ingestionSource: 'manual_paste',
              receivedAtEpochMs: 1000000,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
            ),
          );
      await database
          .into(database.transactionCandidates)
          .insert(
            TransactionCandidatesCompanion.insert(
              smsEventId: eventId,
              state: CandidateRecordState.retainedLocal,
              encryptedPayload: '{}',
              revision: 1,
              createdAtEpochMs: 1000000,
              candidateId: Value(candidateId),
            ),
          );
    }

    Widget wrap(AppDatabase db, String mutationId, {WalletRepository? repo}) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            ref.onDispose(db.close);
            return db;
          }),
          if (repo != null) walletRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(home: WaitingItemDetailPage(mutationId: mutationId)),
      );
    }

    testWidgets('renders editable fields for a queued mutation', (
      tester,
    ) async {
      final db = createDb();
      await insertQueued(db);

      await tester.pumpWidget(wrap(db, 'm-detail-1'));
      await tester.pumpAndSettle();

      final amountField = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(amountField.controller?.text, '75.00');
      expect(find.text('expense'), findsOneWidget); // Kind dropdown value
      expect(find.text('debit'), findsOneWidget); // Direction dropdown value
      expect(find.text('Debit card'), findsOneWidget); // Payment type

      // The detail rows sit below the fold of the edit form, and a ListView
      // only builds what is visible — scroll them into view before asserting.
      // Drag the form itself — scrollUntilVisible cannot pick a Scrollable
      // here because the dropdowns contribute their own.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('State'), findsOneWidget);
      expect(find.text('queued'), findsOneWidget);
    });

    testWidgets('shows Approve and Reject for a queued mutation', (
      tester,
    ) async {
      final db = createDb();
      await insertQueued(db);

      await tester.pumpWidget(wrap(db, 'm-detail-1'));
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('does not offer Reject for a non-queued mutation', (
      tester,
    ) async {
      final db = createDb();
      await insertQueued(
        db,
        id: 'm-detail-2',
        state: WalletMutationState.unknownDelivery,
      );

      await tester.pumpWidget(wrap(db, 'm-detail-2'));
      await tester.pumpAndSettle();

      expect(find.text('Reject'), findsNothing);
      expect(find.text('Approve'), findsOneWidget);
    });

    testWidgets('shows not-found message for missing mutation', (tester) async {
      final db = createDb();

      await tester.pumpWidget(wrap(db, 'nonexistent'));
      await tester.pumpAndSettle();

      expect(find.text('Mutation not found.'), findsOneWidget);
    });

    testWidgets(
      'reject transitions the mutation to supersededBeforeSend and the '
      'candidate back to needsReview',
      (tester) async {
        final db = createDb();
        await insertQueued(db, candidateId: 'candidate-1');
        await insertReviewedCandidate(db, 'candidate-1');

        await tester.pumpWidget(wrap(db, 'm-detail-1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reject'));
        await tester.pumpAndSettle();

        final mutation = await (db.select(
          db.walletMutations,
        )..where((m) => m.id.equals('m-detail-1'))).getSingle();
        expect(mutation.state, WalletMutationState.supersededBeforeSend);

        final candidate = await (db.select(
          db.transactionCandidates,
        )..where((c) => c.candidateId.equals('candidate-1'))).getSingle();
        expect(candidate.state, CandidateRecordState.needsReview);
      },
    );

    testWidgets('an edited amount reaches the create snapshot with the '
        'correct sign', (tester) async {
      final db = createDb();
      await insertQueued(db, candidateId: 'cand-detail-1');
      final dataSource = FakeWalletApiDataSource();
      final repo = WalletRepository(dataSource: dataSource);

      await tester.pumpWidget(wrap(db, 'm-detail-1', repo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '120.50');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      expect(dataSource.lastCreatePayload, isNotNull);
      // Direction is unchanged (debit), so the edited magnitude must come
      // back out negative — the M5.22 WP-M sign convention.
      expect(dataSource.lastCreatePayload!.amountMinor, -12050);
    });

    testWidgets('displays labels as chips (M6.11)', (tester) async {
      final db = createDb();
      await db
          .into(db.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: 'm-labels-1',
              operationKind: WalletMutationOperation.create,
              payload:
                  '{"amountMinor":5000,"currencyCode":"LKR","kind":"expense",'
                  '"direction":"debit","paymentType":"debit_card",'
                  '"accountId":"acc-1","categoryId":"cat-1",'
                  '"counterParty":"Test","labelIds":["label-1","label-2"]}',
              state: WalletMutationState.queued,
              lineageKey: 'lineage-m-labels-1',
              fingerprint: 'fp-m-labels-1',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: 1000000,
            ),
          );

      await tester.pumpWidget(wrap(db, 'm-labels-1'));
      await tester.pumpAndSettle();

      // Scroll to bring label section into view
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Labels row should be visible with chips (not comma-joined string)
      expect(find.text('Labels'), findsOneWidget);
      expect(find.byType(Chip), findsWidgets);
    });
  });
}
