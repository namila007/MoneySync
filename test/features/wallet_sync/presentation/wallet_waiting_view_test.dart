import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_waiting_view.dart';

void main() {
  group('WaitingView', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> flushDrift(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    }

    Future<void> insertQueued(
      AppDatabase database, {
      String id = 'm1',
      String payload =
          '{"amountMinor":5000,"currencyCode":"LKR","kind":"expense"}',
    }) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: id,
              operationKind: WalletMutationOperation.create,
              payload: payload,
              state: WalletMutationState.queued,
              lineageKey: 'lineage-$id',
              fingerprint: 'fp-$id',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: 1000000,
            ),
          );
    }

    Future<void> insertSyncing(
      AppDatabase database, {
      String id = 'm-sync',
    }) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: id,
              operationKind: WalletMutationOperation.create,
              payload:
                  '{"amountMinor":3000,"currencyCode":"LKR","kind":"income"}',
              state: WalletMutationState.syncing,
              lineageKey: 'lineage-$id',
              fingerprint: 'fp-$id',
              createdAtEpochMs: 500000,
              updatedAtEpochMs: 500000,
            ),
          );
    }

    Widget makeApp(AppDatabase database) {
      addTearDown(database.close);
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            return database;
          }),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/settings/wallet/waiting',
            routes: [
              GoRoute(
                path: '/settings/wallet/waiting',
                builder: (_, _) => const WaitingView(),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('shows empty state when no queued mutations', (tester) async {
      final database = createDb();
      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.text('No pending transactions.'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      await flushDrift(tester);
    });

    testWidgets('renders queued mutations in the list', (tester) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('renders syncing mutations in the list', (tester) async {
      final database = createDb();
      await insertSyncing(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('syncing'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('checkbox toggles selection and shows Approve action', (
      tester,
    ) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('Approve'), findsNothing);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.textContaining('Approve (1)'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('checkbox toggle off hides Approve action', (tester) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(find.textContaining('Approve (1)'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(find.textContaining('Approve'), findsNothing);
      await flushDrift(tester);
    });

    testWidgets('Clear button resets selection', (tester) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(find.textContaining('Approve (1)'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Approve'), findsNothing);
      await flushDrift(tester);
    });

    testWidgets('multiple mutations can be selected', (tester) async {
      final database = createDb();
      await insertQueued(database, id: 'm1');
      await insertQueued(database, id: 'm2');
      await insertQueued(database, id: 'm3');

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsNWidgets(3));

      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pumpAndSettle();

      expect(find.textContaining('Approve (2)'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows AppBar with "Waiting" title', (tester) async {
      final database = createDb();
      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.text('Waiting'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('formats amount correctly', (tester) async {
      final database = createDb();
      await insertQueued(
        database,
        payload:
            '{"amountMinor":1234500,"currencyCode":"LKR","kind":"expense"}',
      );

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('12,345.00'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('action bar is reachable (M5.22)', (tester) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final approveBtn = find.textContaining('Approve');
      expect(approveBtn, findsOneWidget);
      expect(approveBtn, findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows amount with default currency LKR', (tester) async {
      final database = createDb();
      await insertQueued(database, payload: '{"amountMinor":1000}');

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('LKR'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows default kind when missing from payload', (tester) async {
      final database = createDb();
      await insertQueued(database, payload: '{"amountMinor":1000}');

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('expense'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('handles malformed JSON payload gracefully', (tester) async {
      final database = createDb();
      await insertQueued(database, payload: 'not-json');

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows created time in subtitle', (tester) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('list items show chevron_right icon', (tester) async {
      final database = createDb();
      await insertQueued(database);

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows loading state when mutations are loading', (
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
            waitingMutationsProvider.overrideWith(
              (ref) => const Stream<List<WalletMutation>>.empty(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/waiting',
              routes: [
                GoRoute(
                  path: '/settings/wallet/waiting',
                  builder: (_, _) => const WaitingView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('shows error state when mutations fail to load', (
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
            waitingMutationsProvider.overrideWith(
              (ref) => Stream<List<WalletMutation>>.error(
                Exception('DB failure'),
                StackTrace.empty,
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/waiting',
              routes: [
                GoRoute(
                  path: '/settings/wallet/waiting',
                  builder: (_, _) => const WaitingView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('approve selected mutations shows snackbar result', (
      tester,
    ) async {
      final database = createDb();
      addTearDown(database.close);
      await insertQueued(database, id: 'm1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return database;
            }),
            walletRepositoryProvider.overrideWithValue(
              WalletRepository(dataSource: FakeWalletApiDataSource()),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/waiting',
              routes: [
                GoRoute(
                  path: '/settings/wallet/waiting',
                  builder: (_, _) => const WaitingView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Approve'));
      await tester.pumpAndSettle();

      expect(find.textContaining('succeeded'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('handles non-Map JSON payload gracefully', (tester) async {
      final database = createDb();
      await insertQueued(database, payload: '[1,2,3]');

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.textContaining('0.00'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('negative-stored amount never renders with a leading minus', (
      tester,
    ) async {
      final database = createDb();
      await insertQueued(
        database,
        payload: '{"amountMinor":-5000,"currencyCode":"LKR","kind":"refund"}',
      );

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.textContaining('50.00'), findsOneWidget);
      expect(find.textContaining('-50.00'), findsNothing);
      expect(find.textContaining('refund'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('trailing icon button navigates to detail', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertQueued(database, id: 'm-detail');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/waiting',
              routes: [
                GoRoute(
                  path: '/settings/wallet/waiting',
                  builder: (_, _) => const WaitingView(),
                ),
                GoRoute(
                  path: '/settings/wallet/waiting/:id',
                  builder: (_, state) => Scaffold(
                    body: Text('Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('Detail: m-detail'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('list tile tap navigates to detail', (tester) async {
      final database = createDb();
      addTearDown(database.close);
      await insertQueued(database, id: 'm-tap');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return database;
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/waiting',
              routes: [
                GoRoute(
                  path: '/settings/wallet/waiting',
                  builder: (_, _) => const WaitingView(),
                ),
                GoRoute(
                  path: '/settings/wallet/waiting/:id',
                  builder: (_, state) => Scaffold(
                    body: Text('Detail: ${state.pathParameters['id']}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.text('Detail: m-tap'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('approve with failing repository shows failure in snackbar', (
      tester,
    ) async {
      final database = createDb();
      addTearDown(database.close);
      await insertQueued(database, id: 'm-fail');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              return database;
            }),
            walletRepositoryProvider.overrideWithValue(
              WalletRepository(
                dataSource: FakeWalletApiDataSource(
                  error: const WalletApiDataSourceException(
                    PermanentClientFailure(),
                  ),
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/settings/wallet/waiting',
              routes: [
                GoRoute(
                  path: '/settings/wallet/waiting',
                  builder: (_, _) => const WaitingView(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Approve'));
      await tester.pumpAndSettle();

      expect(find.textContaining('succeeded'), findsOneWidget);
      expect(find.textContaining('failed'), findsOneWidget);
      await flushDrift(tester);
    });

    testWidgets('live stream shows new mutations without invalidation', (
      tester,
    ) async {
      final database = createDb();

      await tester.pumpWidget(makeApp(database));
      await tester.pumpAndSettle();

      expect(find.text('No pending transactions.'), findsOneWidget);

      await insertQueued(database, id: 'm-live');

      await tester.pump();
      await tester.pump();

      expect(find.text('No pending transactions.'), findsNothing);
      expect(find.textContaining('LKR'), findsOneWidget);
      await flushDrift(tester);
    });
  });
}
