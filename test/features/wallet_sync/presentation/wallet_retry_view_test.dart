import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_retry_view.dart';

void main() {
  group('RetryView', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> insertRetry(AppDatabase database, {String id = 'm1'}) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: id,
              operationKind: WalletMutationOperation.create,
              payload: '{"amountMinor":2500,"currencyCode":"LKR"}',
              state: WalletMutationState.retryScheduled,
              lineageKey: 'lineage-$id',
              fingerprint: 'fp-$id',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: 2000000,
            ),
          );
    }

    testWidgets('shows empty state when no retry mutations', (tester) async {
      final db = createDb();
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return db;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/retry',
              routes: [
                GoRoute(
                  path: '/settings/wallet/retry',
                  builder: (_, _) => const RetryView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No failed transactions to retry.'), findsOneWidget);

      // Flush Drift stream cleanup timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('renders retry mutations in the list', (tester) async {
      final db = createDb();
      addTearDown(db.close);
      await insertRetry(db);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return db;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/retry',
              routes: [
                GoRoute(
                  path: '/settings/wallet/retry',
                  builder: (_, _) => const RetryView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CheckboxListTile), findsOneWidget);

      // Flush Drift stream cleanup timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('Retry All button is always visible', (tester) async {
      final db = createDb();
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return db;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/retry',
              routes: [
                GoRoute(
                  path: '/settings/wallet/retry',
                  builder: (_, _) => const RetryView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry All'), findsOneWidget);

      // Flush Drift stream cleanup timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('live stream shows new retry mutations without invalidation', (
      tester,
    ) async {
      final db = createDb();
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return db;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/retry',
              routes: [
                GoRoute(
                  path: '/settings/wallet/retry',
                  builder: (_, _) => const RetryView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially empty.
      expect(find.text('No failed transactions to retry.'), findsOneWidget);

      // Insert a retry mutation directly (simulates a failed create).
      await insertRetry(db, id: 'm-live');

      // Let the stream propagate.
      await tester.pump();
      await tester.pump();

      // The new mutation should appear automatically.
      expect(find.text('No failed transactions to retry.'), findsNothing);
      expect(find.byType(CheckboxListTile), findsOneWidget);

      // Flush Drift stream cleanup timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
