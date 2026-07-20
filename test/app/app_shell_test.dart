import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/app_config.dart';

void main() {
  testWidgets(
    'shell exposes five accessible destinations and returns from Settings',
    (tester) async {
      await tester.pumpWidget(MoneySyncApp(config: AppConfig.playManual()));

      final semantics = tester.ensureSemantics();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Mappings'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
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

      for (final destination in <String>[
        'Inbox',
        'Mappings',
        'Activity',
        'Settings',
      ]) {
        await tester.tap(
          find.widgetWithText(NavigationDestination, destination),
        );
        await tester.pumpAndSettle();
        expect(find.text(destination), findsWidgets);

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

    await tester.pumpWidget(MoneySyncApp(config: AppConfig.playManual()));

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

    await tester.pumpWidget(MoneySyncApp(config: AppConfig.playManual()));

    BuildContext shellContext() => tester.element(find.byType(AppShell));
    expect(Theme.of(shellContext()).brightness, Brightness.light);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    await tester.pumpWidget(MoneySyncApp(config: AppConfig.playManual()));

    expect(Theme.of(shellContext()).brightness, Brightness.dark);
  });
}
