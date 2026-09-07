import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

Widget _app({
  ConfigurationRepository? configRepo,
  AppFlavor flavor = AppFlavor.playManual,
}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.withFlavor(flavor)),
      smsPermissionGatewayProvider.overrideWithValue(_UnavailableGateway()),
      configurationRepositoryProvider.overrideWith(
        (ref) async => configRepo ?? _FakeConfigRepo(),
      ),
    ],
    child: const MaterialApp(home: SettingsPage()),
  );
}

void main() {
  group('SettingsPage (modernist design)', () {
    testWidgets('shows all three sections', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('SECURITY & PRIVACY'), findsOneWidget);

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );

      await tester.scrollUntilVisible(
        find.text('SMS & TRACKING'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('SMS & TRACKING'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('DATA & DIAGNOSTICS'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('DATA & DIAGNOSTICS'), findsOneWidget);
    });

    testWidgets('shows system environment card', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('SYSTEM ENVIRONMENT'), findsOneWidget);
      expect(find.text('Build: playManual'), findsOneWidget);
    });

    testWidgets('shows privateFull flavor in environment card', (tester) async {
      await tester.pumpWidget(_app(flavor: AppFlavor.privateFull));
      await tester.pumpAndSettle();

      expect(find.text('Build: privateFull'), findsOneWidget);
    });

    testWidgets('App lock tile navigates to security', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('App lock'), findsOneWidget);
      expect(find.text('Secure with biometrics/PIN'), findsOneWidget);
    });

    testWidgets('Message reading tile is present', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Message reading'),
        250,
        scrollable: scrollable,
      );

      expect(find.text('Message reading'), findsOneWidget);
      expect(find.text('Configure SMS permissions'), findsOneWidget);
    });

    testWidgets('History Import tile is present', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('History Import'),
        250,
        scrollable: scrollable,
      );

      expect(find.text('History Import'), findsOneWidget);
      expect(find.text('Import range settings'), findsOneWidget);
    });

    testWidgets('Tracked senders tile is present', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Tracked senders'),
        250,
        scrollable: scrollable,
      );

      expect(find.text('Tracked senders'), findsOneWidget);
    });

    testWidgets('Data control tile is present', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Data control'),
        250,
        scrollable: scrollable,
      );

      expect(find.text('Data control'), findsOneWidget);
      expect(find.text('Export or delete local cache'), findsOneWidget);
    });

    testWidgets('shows version info at bottom', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.textContaining('version 2.4.1'),
        250,
        scrollable: scrollable,
      );

      expect(find.textContaining('version 2.4.1'), findsOneWidget);
    });
  });
}

final class _FakeConfigRepo implements ConfigurationRepository {
  @override
  Future<ConfigurationState> load() async => const ConfigurationState();

  @override
  Future<void> updateSecureWindowEnabled(bool enabled) async {}

  @override
  Future<void> updateAutoImportEnabled(bool enabled) async {}

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

  @override
  Future<void> updateAutoImportIntervalMinutes(int minutes) async {}
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
