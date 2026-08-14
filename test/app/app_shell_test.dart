import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';

Widget _appWithOnboardingComplete() {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.playManual()),
      onboardingStateProvider.overrideWith(
        () => _CompletedOnboardingNotifier(),
      ),
      // These are navigation tests: without this the Activity tab waits on a
      // database that never opens under flutter_test and pumpAndSettle spins.
      activityLogRepositoryProvider.overrideWith(
        (ref) async => const _EmptyActivityLog(),
      ),
      // Home summary watches the database future; give it an in-memory DB.
      appDatabaseProvider.overrideWith((ref) async {
        final db = AppDatabase.inMemoryForTesting();
        ref.onDispose(db.close);
        return db;
      }),
    ],
    child: const MoneySyncApp(),
  );
}

final class _EmptyActivityLog implements ActivityLogRepository {
  const _EmptyActivityLog();

  @override
  Future<List<ActivityLogEntry>> recent({int limit = 200}) async => const [];
}

final class _CompletedOnboardingNotifier extends OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState(
    currentStep: OnboardingStep.disclosure,
    disclosureRevision: 1,
    isComplete: true,
    onboardingRevision: 2,
  );
}

void main() {
  testWidgets(
    'Settings app-bar action opens from Activity and returns to Activity',
    (tester) async {
      await tester.pumpWidget(_appWithOnboardingComplete());

      await tester.tap(find.widgetWithText(NavigationDestination, 'Activity'));
      await tester.pumpAndSettle();
      expect(find.text('Activity'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('open-settings')));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Activity'), findsWidgets);
    },
  );

  testWidgets(
    'shell exposes four accessible destinations and returns from Settings',
    (tester) async {
      await tester.pumpWidget(_appWithOnboardingComplete());

      final semantics = tester.ensureSemantics();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Mappings'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.byKey(const ValueKey('open-settings')), findsOneWidget);
      expect(find.bySemanticsLabel('Primary navigation'), findsOneWidget);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.darkTheme?.useMaterial3, isTrue);

      for (final destination in find.byType(NavigationDestination).evaluate()) {
        expect(
          tester
              .getSize(
                find.byElementPredicate((element) => element == destination),
              )
              .height,
          greaterThanOrEqualTo(48),
        );
      }

      for (final destination in <String>['Inbox', 'Mappings', 'Activity']) {
        await tester.tap(
          find.widgetWithText(NavigationDestination, destination),
        );
        await tester.pumpAndSettle();
        expect(find.text(destination), findsWidgets);
        expect(find.byKey(const ValueKey('open-settings')), findsOneWidget);

        await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsWidgets);
      }

      await tester.tap(find.byKey(const ValueKey('open-settings')));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsWidgets);
      semantics.dispose();
    },
  );

  testWidgets('large text preserves a visible primary navigation bar', (
    tester,
  ) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );

    await tester.pumpWidget(_appWithOnboardingComplete());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system brightness renders both configured themes', (
    tester,
  ) async {
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
    );

    await tester.pumpWidget(_appWithOnboardingComplete());

    BuildContext shellContext() => tester.element(find.byType(AppShell));
    expect(Theme.of(shellContext()).brightness, Brightness.light);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    await tester.pumpWidget(_appWithOnboardingComplete());

    expect(Theme.of(shellContext()).brightness, Brightness.dark);
  });
}
