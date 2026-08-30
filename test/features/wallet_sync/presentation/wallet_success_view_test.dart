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

    Future<void> flushDrift(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('shows empty state when no succeeded mutations', (
      tester,
    ) async {
      final database = createDb();
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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
      await flushDrift(tester);
    });

    testWidgets('renders succeeded mutations in the list', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(database);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('expense'), findsOneWidget);
      expect(find.textContaining('succeeded'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('formats amount with commas for large values', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(
        database,
        payload:
            '{"amountMinor":123456700,"currencyCode":"LKR","kind":"income"}',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.textContaining('1,234,567.00'), findsOneWidget);
      expect(find.textContaining('income'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('negative-stored amount never renders with a leading minus', (
      tester,
    ) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(
        database,
        payload: '{"amountMinor":-5000,"currencyCode":"LKR","kind":"refund"}',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.textContaining('50.00'), findsOneWidget);
      expect(find.textContaining('-50.00'), findsNothing);
      expect(find.textContaining('refund'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('handles malformed payload gracefully', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(database, payload: 'not-json');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('handles payload with missing fields gracefully', (
      tester,
    ) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(database, payload: '{}');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows AppBar with "Succeeded" title', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(database);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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
      await flushDrift(tester);
    });

    testWidgets('renders multiple succeeded mutations', (tester) async {
      final database = createDb();
      addTearDown(database.close);
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

      expect(find.textContaining('expense'), findsOneWidget);
      expect(find.textContaining('income'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
      await flushDrift(tester);
    });

    testWidgets('formats time correctly', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(database, updatedAtMs: 2000000);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.byType(ListTile), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('handles non-Map JSON payload gracefully', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertSucceeded(database, payload: '[1,2,3]');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
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

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets(
      'live stream shows new succeeded mutations without invalidation',
      (tester) async {
        final database = createDb();
        addTearDown(database.close);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWith((ref) async {
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

        await insertSucceeded(database, id: 'm-live');

        await tester.pump();
        await tester.pump();

        expect(find.text('No succeeded transactions.'), findsNothing);
        expect(find.textContaining('LKR'), findsOneWidget);
        await flushDrift(tester);
      },
    );
  });
}
