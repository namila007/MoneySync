import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/dashboard/presentation/home_page.dart';

const _importMarker = 'HISTORY-IMPORT-DESTINATION';

void main() {
  testWidgets('scan flow back returns to Home, not the configuration menu', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async {
          final db = AppDatabase.inMemoryForTesting();
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/settings/history-import',
          builder: (context, state) => Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text(_importMarker)),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scan messages'), findsOneWidget);
    await tester.tap(find.text('Scan messages'));
    await tester.pumpAndSettle();

    expect(find.text(_importMarker), findsOneWidget);
    expect(find.text('Scan messages'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Scan messages'), findsOneWidget);
  });
}
