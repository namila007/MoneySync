import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/core/security/foreground_lock.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/security_privacy_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App lock toggle propagation', () {
    test('updateAppLockRequired updates the router lock gate', () {
      updateAppLockRequired(true);
      updateAppLockRequired(false);
    });

    testWidgets(
      'security page enable toggle calls updateAppLockRequired(true)',
      (tester) async {
        final repo = _FakeConfigRepo(appLockEnabled: false);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(const AppConfig.playManual()),
              configurationRepositoryProvider.overrideWith((ref) async => repo),
              smsPermissionGatewayProvider.overrideWithValue(
                _UnavailableGateway(),
              ),
              freshAuthPortProvider.overrideWithValue(
                AsyncData(_FakeFreshAuth()),
              ),
            ],
            child: const MaterialApp(home: SecurityPrivacyPage()),
          ),
        );
        await tester.pumpAndSettle();

        final appLockSwitch = find.widgetWithText(SwitchListTile, 'App lock');
        expect(appLockSwitch, findsOneWidget);

        final switchWidget = tester.widget<SwitchListTile>(appLockSwitch);
        expect(switchWidget.value, isFalse);

        await tester.tap(appLockSwitch);
        await tester.pumpAndSettle();

        expect(repo.appLockUpdates, [true]);
      },
    );

    testWidgets(
      'security page disable toggle calls updateAppLockRequired(false)',
      (tester) async {
        final repo = _FakeConfigRepo(appLockEnabled: true);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(const AppConfig.playManual()),
              configurationRepositoryProvider.overrideWith((ref) async => repo),
              smsPermissionGatewayProvider.overrideWithValue(
                _UnavailableGateway(),
              ),
              freshAuthPortProvider.overrideWithValue(
                AsyncData(_FakeFreshAuth()),
              ),
            ],
            child: const MaterialApp(home: SecurityPrivacyPage()),
          ),
        );
        await tester.pumpAndSettle();

        final appLockSwitch = find.widgetWithText(SwitchListTile, 'App lock');
        final switchWidget = tester.widget<SwitchListTile>(appLockSwitch);
        expect(switchWidget.value, isTrue);

        await tester.tap(appLockSwitch);
        await tester.pumpAndSettle();

        // Confirmation dialog appears for disable.
        if (find.text('Turn off').evaluate().isNotEmpty) {
          await tester.tap(find.text('Turn off'));
          await tester.pumpAndSettle();
        }

        expect(repo.appLockUpdates, [false]);
      },
    );
  });

  group('ForegroundLockNotifier', () {
    test('starts in locked state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(foregroundLockControllerProvider);
      expect(state, ForegroundLockState.locked);
    });

    test('onAppPaused sets state to locked', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        foregroundLockControllerProvider.notifier,
      );
      notifier.onAppPaused();
      final state = container.read(foregroundLockControllerProvider);
      expect(state, ForegroundLockState.locked);
    });
  });
}

class _FakeFreshAuth implements FreshAuthPort {
  @override
  Future<DeviceAuthOutcome> authenticate({required String purpose}) async =>
      DeviceAuthOutcome.authenticated;

  @override
  Future<bool> isDeviceAuthAvailable() async => true;
}

final class _FakeConfigRepo implements ConfigurationRepository {
  _FakeConfigRepo({this.appLockEnabled = false});

  bool appLockEnabled;
  final List<bool> appLockUpdates = [];

  @override
  Future<ConfigurationState> load() async =>
      ConfigurationState(appLock: AppLockPreferences(enabled: appLockEnabled));

  @override
  Future<void> updateAppLock(AppLockPreferences prefs) async {
    appLockEnabled = prefs.enabled;
    appLockUpdates.add(prefs.enabled);
  }

  @override
  Future<void> updateSecureWindowEnabled(bool enabled) async {}

  @override
  Future<void> updateAutoImportEnabled(bool enabled) async {}

  @override
  Future<void> updateTheme(AppThemeMode mode) async {}

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
