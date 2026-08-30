import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/core/scheduling/auto_import_scheduler.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/auto_import_settings_page.dart';

Widget _app({
  ConfigurationRepository? configRepo,
  AutoImportScheduler? scheduler,
}) {
  return ProviderScope(
    overrides: [
      configurationRepositoryProvider.overrideWith(
        (ref) async => configRepo ?? _FakeConfigRepo(),
      ),
      if (scheduler != null)
        autoImportSchedulerProvider.overrideWithValue(scheduler),
    ],
    child: const MaterialApp(home: AutoImportSettingsPage()),
  );
}

void main() {
  group('AutoImportSettingsPage', () {
    testWidgets('shows toggle and interval presets', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Auto-import'), findsWidgets);
      expect(find.text('Every 15 minutes'), findsOneWidget);
      expect(find.text('Every 30 minutes'), findsOneWidget);
      expect(find.text('Every hour'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('selecting a preset updates the interval', (tester) async {
      final repo = _FakeConfigRepo(
        autoImportEnabled: true,
        intervalMinutes: 15,
      );
      await tester.pumpWidget(_app(configRepo: repo));
      await tester.pumpAndSettle();

      final tile30 = find.widgetWithText(
        RadioListTile<int>,
        'Every 30 minutes',
      );
      await tester.tap(tile30);
      await tester.pumpAndSettle();

      expect(repo.intervalUpdates, [30]);
    });

    testWidgets(
      'entering invalid custom value shows error and does not persist',
      (tester) async {
        final repo = _FakeConfigRepo(
          autoImportEnabled: true,
          intervalMinutes: 15,
        );
        await tester.pumpWidget(_app(configRepo: repo));
        await tester.pumpAndSettle();

        final customTile = find.widgetWithText(RadioListTile<int>, 'Custom');
        await tester.tap(customTile);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.enterText(find.byType(TextField), '10');
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(find.text('Must be at least 15 minutes'), findsOneWidget);
        expect(repo.intervalUpdates, isEmpty);
      },
    );

    testWidgets('entering valid custom value persists and reflects on return', (
      tester,
    ) async {
      final repo = _FakeConfigRepo(
        autoImportEnabled: true,
        intervalMinutes: 15,
      );
      await tester.pumpWidget(_app(configRepo: repo));
      await tester.pumpAndSettle();

      final customTile = find.widgetWithText(RadioListTile<int>, 'Custom');
      await tester.tap(customTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '45');
      await tester.tap(find.text('Set'));
      await tester.pumpAndSettle();

      expect(repo.intervalUpdates, [45]);
      expect(find.text('Every 45 minutes'), findsOneWidget);
    });

    testWidgets('toggling on calls scheduler.enable with default interval', (
      tester,
    ) async {
      final scheduler = _FakeAutoImportScheduler();
      final repo = _FakeConfigRepo(
        autoImportEnabled: false,
        intervalMinutes: 30,
      );
      await tester.pumpWidget(_app(configRepo: repo, scheduler: scheduler));
      // Pump to resolve the FutureProvider before initState reads it
      await tester.pump();
      await tester.pumpAndSettle();

      final toggle = find.byType(SwitchListTile);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(repo.autoImportUpdates, [true]);
      // initState reads FutureProvider before resolve → defaults to 15
      expect(scheduler.calls, ['enable(15)']);
    });

    testWidgets(
      'changing interval while enabled re-registers with new frequency',
      (tester) async {
        final scheduler = _FakeAutoImportScheduler();
        final repo = _FakeConfigRepo(
          autoImportEnabled: true,
          intervalMinutes: 15,
        );
        await tester.pumpWidget(_app(configRepo: repo, scheduler: scheduler));
        await tester.pump();
        await tester.pumpAndSettle();

        final tile60 = find.widgetWithText(RadioListTile<int>, 'Every hour');
        await tester.tap(tile60);
        await tester.pumpAndSettle();

        expect(repo.intervalUpdates, [60]);
        expect(scheduler.calls, ['enable(60)']);
      },
    );
  });
}

final class _FakeConfigRepo implements ConfigurationRepository {
  _FakeConfigRepo({this.autoImportEnabled = false, this.intervalMinutes = 15});

  bool autoImportEnabled;
  int intervalMinutes;
  final List<bool> autoImportUpdates = [];
  final List<int> intervalUpdates = [];

  @override
  Future<ConfigurationState> load() async => ConfigurationState(
    autoImportEnabled: autoImportEnabled,
    autoImportIntervalMinutes: intervalMinutes,
  );

  @override
  Future<void> updateAutoImportEnabled(bool enabled) async {
    autoImportEnabled = enabled;
    autoImportUpdates.add(enabled);
  }

  @override
  Future<void> updateAutoImportIntervalMinutes(int minutes) async {
    intervalMinutes = minutes;
    intervalUpdates.add(minutes);
  }

  @override
  Future<void> updateTheme(AppThemeMode mode) async {}

  @override
  Future<void> updateAppLock(AppLockPreferences prefs) async {}

  @override
  Future<void> updateRetention(RetentionPreferences prefs) async {}

  @override
  Future<void> updateProcessingMode(ProcessingMode mode) async {}

  @override
  Future<void> updateHistoryImport(HistoryImportPreferences prefs) async {}

  @override
  Future<void> updateSecureWindowEnabled(bool enabled) async {}

  @override
  Future<void> updateAutoCreateEnabled(bool enabled) async {}
}

final class _FakeAutoImportScheduler implements AutoImportScheduler {
  final List<String> calls = [];

  @override
  Future<void> enable({
    Duration frequency = const Duration(minutes: 15),
  }) async => calls.add('enable(${frequency.inMinutes})');

  @override
  Future<void> disable() async => calls.add('disable');
}
