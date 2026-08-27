import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/scheduling/auto_import_scheduler.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

Widget _app({
  ConfigurationRepository? configRepo,
  AppFlavor flavor = AppFlavor.playManual,
  AutoImportScheduler? scheduler,
}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.withFlavor(flavor)),
      smsPermissionGatewayProvider.overrideWithValue(_UnavailableGateway()),
      configurationRepositoryProvider.overrideWith(
        (ref) async => configRepo ?? _FakeConfigRepo(),
      ),
      if (scheduler != null)
        autoImportSchedulerProvider.overrideWithValue(scheduler),
    ],
    child: const MaterialApp(home: SettingsPage()),
  );
}

void main() {
  group('SettingsPage (post M4.15 flattening)', () {
    testWidgets('shows all four sections and no Configuration hub tile', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Security & Privacy'), findsOneWidget);

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );

      await tester.scrollUntilVisible(
        find.text('SMS & Tracking'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('SMS & Tracking'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Wallet'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('Wallet'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Data & Diagnostics'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('Data & Diagnostics'), findsOneWidget);

      // The hub page, its entry tile, and its duplicate sections are gone.
      expect(find.text('Configuration hub', skipOffstage: false), findsNothing);
      expect(find.text('MANAGE', skipOffstage: false), findsNothing);
      expect(find.text('CAPABILITIES', skipOffstage: false), findsNothing);
      expect(find.text('Delete app data', skipOffstage: false), findsNothing);
      expect(find.text('Activity history', skipOffstage: false), findsNothing);
    });

    testWidgets(
      'Permissions tile is present and Message reading is not inline',
      (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        final scrollable = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('Permissions'),
          250,
          scrollable: scrollable,
        );

        expect(find.text('Permissions'), findsOneWidget);
        // Message reading moved to Permissions page — no longer inline.
        expect(find.text('Message reading'), findsNothing);
      },
    );

    testWidgets(
      'screenshot protection switch reflects and persists the state',
      (tester) async {
        final repo = _FakeConfigRepo(secureWindowEnabled: false);
        await tester.pumpWidget(_app(configRepo: repo));
        await tester.pumpAndSettle();

        final scrollable = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('Screenshot protection'),
          250,
          scrollable: scrollable,
        );

        final toggle = tester.widget<SwitchListTile>(
          find.byType(SwitchListTile),
        );
        expect(toggle.value, isFalse);

        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();

        expect(repo.secureWindowUpdates, [true]);
      },
    );

    testWidgets('auto-import toggle is visible only on privateFull', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('SMS & Tracking'),
        250,
        scrollable: scrollable,
      );

      // playManual: no Auto-import tile
      expect(find.text('Auto-import'), findsNothing);

      await tester.pumpWidget(_app(flavor: AppFlavor.privateFull));
      await tester.pumpAndSettle();

      final scrollable2 = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Auto-import'),
        250,
        scrollable: scrollable2,
      );
      expect(find.text('Auto-import'), findsOneWidget);
    });

    testWidgets(
      'auto-import toggle on calls scheduler.enable, off calls scheduler.disable',
      (tester) async {
        final scheduler = _FakeAutoImportScheduler();
        final repo = _FakeConfigRepo(autoImportEnabled: false);
        await tester.pumpWidget(
          _app(
            flavor: AppFlavor.privateFull,
            configRepo: repo,
            scheduler: scheduler,
          ),
        );
        await tester.pumpAndSettle();

        final scrollable = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.text('Auto-import'),
          250,
          scrollable: scrollable,
        );
        await tester.ensureVisible(find.text('Auto-import'));
        await tester.pumpAndSettle();

        // Find the SwitchListTile that is a descendant of the Auto-import text's ancestor
        final autoImportTile = find.ancestor(
          of: find.text('Auto-import'),
          matching: find.byType(SwitchListTile),
        );

        // Tap to turn on
        await tester.tap(autoImportTile);
        await tester.pumpAndSettle();

        expect(repo.autoImportUpdates, [true]);
        expect(scheduler.calls, ['enable']);

        // Tap again to turn off
        await tester.tap(autoImportTile);
        await tester.pumpAndSettle();

        expect(repo.autoImportUpdates, [true, false]);
        expect(scheduler.calls, ['enable', 'disable']);
      },
    );
  });
}

final class _FakeConfigRepo implements ConfigurationRepository {
  _FakeConfigRepo({
    this.secureWindowEnabled = true,
    this.autoImportEnabled = false,
  });

  final bool secureWindowEnabled;
  bool autoImportEnabled;
  final List<bool> secureWindowUpdates = [];
  final List<bool> autoImportUpdates = [];

  @override
  Future<ConfigurationState> load() async => ConfigurationState(
    secureWindowEnabled: secureWindowEnabled,
    autoImportEnabled: autoImportEnabled,
  );

  @override
  Future<void> updateSecureWindowEnabled(bool enabled) async {
    secureWindowUpdates.add(enabled);
  }

  @override
  Future<void> updateAutoImportEnabled(bool enabled) async {
    autoImportEnabled = enabled;
    autoImportUpdates.add(enabled);
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
  Future<void> updateAutoCreateEnabled(bool enabled) async {}
}

final class _FakeAutoImportScheduler implements AutoImportScheduler {
  final List<String> calls = [];

  @override
  Future<void> enable() async => calls.add('enable');

  @override
  Future<void> disable() async => calls.add('disable');
}

final class _UnavailableGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionStatus> current() async =>
      SmsPermissionStatus.unavailableInBuild;

  @override
  Future<SmsPermissionStatus> request() async =>
      SmsPermissionStatus.unavailableInBuild;

  @override
  Future<void> openAppSettings() async {}
}
