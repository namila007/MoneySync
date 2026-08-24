import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_waiting_view.dart';

void main() {
  group('WaitingView', () {
    AppDatabase createDb() => AppDatabase.inMemoryForTesting();

    Future<void> insertQueued(AppDatabase database, {String id = 'm1'}) async {
      await database
          .into(database.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: id,
              operationKind: WalletMutationOperation.create,
              payload: '{"amountMinor":5000,"currencyCode":"LKR"}',
              state: WalletMutationState.queued,
              lineageKey: 'lineage-$id',
              fingerprint: 'fp-$id',
              createdAtEpochMs: 1000000,
              updatedAtEpochMs: 1000000,
            ),
          );
    }

    testWidgets('shows empty state when no queued mutations', (tester) async {
      late final AppDatabase database;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              database = createDb();
              ref.onDispose(database.close);
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
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No pending transactions.'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('renders queued mutations in the list', (tester) async {
      final database = createDb();
      await insertQueued(database);

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

      expect(find.textContaining('LKR'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox toggles selection and shows Approve action', (
      tester,
    ) async {
      final database = createDb();
      await insertQueued(database);

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

      expect(find.textContaining('Approve'), findsNothing);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.textContaining('Approve (1)'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });
  });
}
