import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

/// Settings-root deep links after the Configuration hub was flattened into
/// the settings page (M4.15 WP5).
void main() {
  Widget app() {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/settings/security',
          builder: (context, state) =>
              const Scaffold(body: Text('APP-LOCK-DESTINATION')),
        ),
        GoRoute(
          path: '/settings/permissions',
          builder: (context, state) =>
              const Scaffold(body: Text('PERMISSIONS-DESTINATION')),
        ),
        GoRoute(
          path: '/settings/message-reading',
          builder: (context, state) =>
              const Scaffold(body: Text('MESSAGE-READING')),
        ),
        GoRoute(
          path: '/settings/history-import',
          builder: (context, state) =>
              const Scaffold(body: Text('HISTORY-IMPORT')),
        ),
        GoRoute(
          path: '/settings/tracked-senders',
          builder: (context, state) =>
              const Scaffold(body: Text('TRACKED-SENDERS')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.playManual()),
        smsPermissionGatewayProvider.overrideWithValue(_UnavailableGateway()),
        configurationRepositoryProvider.overrideWith(
          (ref) async => _FakeConfigRepo(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Finder scrollableFinder() => find.descendant(
    of: find.byType(ListView),
    matching: find.byType(Scrollable),
  );

  group('Settings root navigation', () {
    testWidgets('Tracked senders opens its page', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Tracked senders'),
        250,
        scrollable: scrollableFinder(),
      );
      await tester.ensureVisible(find.text('Tracked senders'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tracked senders'));
      await tester.pumpAndSettle();

      expect(find.text('TRACKED-SENDERS'), findsOneWidget);
    });

    testWidgets('History window opens the import page', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('History window'),
        250,
        scrollable: scrollableFinder(),
      );
      await tester.ensureVisible(find.text('History window'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('History window'));
      await tester.pumpAndSettle();

      expect(find.text('HISTORY-IMPORT'), findsOneWidget);
    });

    testWidgets('Permissions opens the permissions page', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Permissions'),
        250,
        scrollable: scrollableFinder(),
      );
      await tester.ensureVisible(find.text('Permissions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Permissions'));
      await tester.pumpAndSettle();

      expect(find.text('PERMISSIONS-DESTINATION'), findsOneWidget);
    });

    testWidgets('App lock still opens the security page', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('App lock & biometric'));
      await tester.pumpAndSettle();

      expect(find.text('APP-LOCK-DESTINATION'), findsOneWidget);
    });
  });
}

final class _FakeConfigRepo implements ConfigurationRepository {
  @override
  Future<ConfigurationState> load() async => const ConfigurationState();

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
  Future<void> updateAutoImportEnabled(bool enabled) async {}

  @override
  Future<void> updateAutoCreateEnabled(bool enabled) async {}
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
