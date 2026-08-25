import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/success_item_detail_page.dart';

void main() {
  group('SuccessItemDetailPage', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> insertSucceeded(
      AppDatabase database, {
      String counterParty = 'Test Shop',
    }) async {
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
                  '"counterParty":"$counterParty",'
                  '"note":"[sw:AB12CD34] some note"}',
              state: WalletMutationState.succeeded,
              lineageKey: 'lineage-detail-1',
              fingerprint: 'fp-detail-1',
              createdAtEpochMs: 1699963200000,
              updatedAtEpochMs: 1699963200000,
            ),
          );
    }

    final catalog = WalletCatalog(
      accounts: [
        const WalletAccount(
          id: 'acc-1',
          name: 'Cash Wallet',
          currencyCode: 'LKR',
          isArchived: false,
          isBankSynced: false,
          isWritable: true,
        ),
      ],
      categories: [
        const WalletCategory(
          id: 'cat-1',
          name: 'Groceries',
          groupId: 'group-1',
          groupName: 'Food',
        ),
      ],
    );

    testWidgets('shows a plain-language summary above the detail rows', (
      tester,
    ) async {
      final db = createDb();
      await insertSucceeded(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(db.close);
              return db;
            }),
            walletCatalogProvider.overrideWith((ref) async => catalog),
          ],
          child: const MaterialApp(
            home: SuccessItemDetailPage(mutationId: 'm-detail-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Added to Wallet'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // Amount appears once in the summary and once in the detail row.
      expect(find.textContaining('LKR 75.00'), findsNWidgets(2));
      expect(find.text('Test Shop · Food › Groceries'), findsOneWidget);
      expect(find.text('Added to Cash Wallet on 14 Nov 2023'), findsOneWidget);

      // Detail rows are still present below the summary.
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Cash Wallet'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Food › Groceries'), findsOneWidget);
    });

    testWidgets('falls back to category alone when there is no counterparty', (
      tester,
    ) async {
      final db = createDb();
      await insertSucceeded(db, counterParty: '');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(db.close);
              return db;
            }),
            walletCatalogProvider.overrideWith((ref) async => catalog),
          ],
          child: const MaterialApp(
            home: SuccessItemDetailPage(mutationId: 'm-detail-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food › Groceries'), findsNWidgets(2));
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
            walletCatalogProvider.overrideWith((ref) async => catalog),
          ],
          child: const MaterialApp(
            home: SuccessItemDetailPage(mutationId: 'nonexistent'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mutation not found.'), findsOneWidget);
    });
  });
}
