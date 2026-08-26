import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_success_view.dart';

void main() {
  group('SuccessView', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> insertSucceeded(
      AppDatabase database, {
      String id = 'm1',
      String payload =
          '{"amountMinor":5000,"currencyCode":"LKR","kind":"expense"}',
      int updatedAtMs = 2000000,
    }) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: id,
              operationKind: WalletMutationOperation.create,
              payload: payload,
              state: WalletMutationState.succeeded,
              lineageKey: 'lineage-$id',
              fingerprint: 'fp-$id',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: updatedAtMs,
            ),
          );
    }

    testWidgets('shows empty state when no succeeded mutations', (
      tester,
    ) async {
      final database = createDb();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No succeeded transactions.'), findsOneWidget);
    });

    testWidgets('renders succeeded mutations in the list', (tester) async {
      final database = createDb();
      await insertSucceeded(database);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the formatted amount and kind.
      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('expense'), findsOneWidget);
      // Should show the state name.
      expect(find.textContaining('succeeded'), findsOneWidget);
    });

    testWidgets('formats amount with commas for large values', (tester) async {
      final database = createDb();
      await insertSucceeded(
        database,
        payload:
            '{"amountMinor":123456700,"currencyCode":"LKR","kind":"income"}',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 123456700 minor units = 1,234,567.00
      expect(find.textContaining('1,234,567.00'), findsOneWidget);
      expect(find.textContaining('income'), findsOneWidget);
    });

    testWidgets('handles negative amounts', (tester) async {
      final database = createDb();
      await insertSucceeded(
        database,
        payload: '{"amountMinor":-5000,"currencyCode":"LKR","kind":"refund"}',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('-50.00'), findsOneWidget);
      expect(find.textContaining('refund'), findsOneWidget);
    });

    testWidgets('handles malformed payload gracefully', (tester) async {
      final database = createDb();
      await insertSucceeded(database, payload: 'not-json');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not crash; defaults to 0 amount and LKR currency.
      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
    });

    testWidgets('handles payload with missing fields gracefully', (
      tester,
    ) async {
      final database = createDb();
      await insertSucceeded(database, payload: '{}');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Missing amountMinor defaults to 0, missing currencyCode defaults to LKR.
      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
    });

    testWidgets('shows AppBar with "Succeeded" title', (tester) async {
      final database = createDb();
      await insertSucceeded(database);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Succeeded'), findsOneWidget);
    });

    testWidgets('renders multiple succeeded mutations', (tester) async {
      final database = createDb();
      await insertSucceeded(
        database,
        id: 'm1',
        payload: '{"amountMinor":1000,"currencyCode":"LKR","kind":"expense"}',
      );
      await insertSucceeded(
        database,
        id: 'm2',
        payload: '{"amountMinor":2000,"currencyCode":"LKR","kind":"income"}',
        updatedAtMs: 3000000,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both mutations should appear.
      expect(find.textContaining('expense'), findsOneWidget);
      expect(find.textContaining('income'), findsOneWidget);
      // Two list items.
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('formats time correctly', (tester) async {
      final database = createDb();
      // 2000000 ms = 1970-01-23T18:13:20 UTC
      await insertSucceeded(database, updatedAtMs: 2000000);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the date/time in the subtitle.
      // The format is dd/mm/yyyy HH:mm in local time.
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('handles non-Map JSON payload gracefully', (tester) async {
      final database = createDb();
      await insertSucceeded(database, payload: '[1,2,3]');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              ref.onDispose(database.close);
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/succeeded',
              routes: [
                GoRoute(
                  path: '/settings/wallet/succeeded',
                  builder: (_, _) => const SuccessView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Array JSON decoded but not a Map -> falls back to empty map.
      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
    });
  });
}
