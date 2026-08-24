import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/waiting_item_detail_page.dart';

void main() {
  group('WaitingItemDetailPage', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> insertQueued(AppDatabase database) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: 'm-detail-1',
              operationKind: WalletMutationOperation.create,
              payload:
                  '{"amountMinor":7500,"currencyCode":"LKR","kind":"expense",'
                  '"direction":"debit","paymentType":"debit_card",'
                  '"accountId":"acc-1","categoryId":"cat-1",'
                  '"counterParty":"Test Shop"}',
              state: WalletMutationState.queued,
              lineageKey: 'lineage-detail-1',
              fingerprint: 'fp-detail-1',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: 1000000,
            ),
          );
    }

    testWidgets('renders detail rows for a queued mutation', (tester) async {
      final db = createDb();
      await insertQueued(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: MaterialApp(
            home: WaitingItemDetailPage(mutationId: 'm-detail-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amount'), findsOneWidget);
      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.text('Kind'), findsOneWidget);
      expect(find.text('expense'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('debit'), findsOneWidget);
      expect(find.text('Payment type'), findsOneWidget);
      expect(find.text('debit_card'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('acc-1'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('cat-1'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Test Shop'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
      expect(find.text('queued'), findsOneWidget);
    });

    testWidgets('shows Approve button', (tester) async {
      final db = createDb();
      await insertQueued(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: MaterialApp(
            home: WaitingItemDetailPage(mutationId: 'm-detail-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows not-found message for missing mutation', (tester) async {
      final db = createDb();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: MaterialApp(
            home: WaitingItemDetailPage(mutationId: 'nonexistent'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mutation not found.'), findsOneWidget);
    });
  });
}
