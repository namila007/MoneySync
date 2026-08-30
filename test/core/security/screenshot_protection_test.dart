import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

const _channelName = 'me.namila.money_sync/security';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot protection startup', () {
    test('NativeSecurityChannel.setSecureWindowProtection is callable', () {
      const channel = NativeSecurityChannel();
      expect(channel.setSecureWindowProtection, isA<Function>());
    });

    testWidgets('startup reads persisted secureWindowEnabled and applies it', (
      tester,
    ) async {
      final capturedCalls = <bool>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(_channelName), (
            MethodCall call,
          ) async {
            if (call.method == 'setSecureWindowProtection') {
              final args = call.arguments as Map<dynamic, dynamic>;
              capturedCalls.add(args['enabled'] as bool);
              return null;
            }
            if (call.method == 'getSensitiveDatabasePath') {
              return '/tmp/test';
            }
            throw MissingPluginException();
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(_channelName), null);
      });

      final repo = _FakeConfigRepo(secureWindowEnabled: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(const AppConfig.playManual()),
            smsPermissionGatewayProvider.overrideWithValue(
              _UnavailableGateway(),
            ),
            configurationRepositoryProvider.overrideWith((ref) async => repo),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // The toggle should reflect the persisted false value.
      final scrollable = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.text('Screenshot protection'),
        250,
        scrollable: scrollable,
      );

      final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(toggle.value, isFalse);
    });
  });

  group('Screenshot protection toggle logging', () {
    testWidgets('native-channel failure during toggle is logged via .error()', (
      tester,
    ) async {
      final logRecords = <LogRecord>[];
      final sub = Logger('security').onRecord.listen(logRecords.add);
      addTearDown(sub.cancel);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(_channelName), (
            MethodCall call,
          ) async {
            if (call.method == 'setSecureWindowProtection') {
              throw PlatformException(
                code: 'TEST_ERROR',
                message: 'Simulated native failure',
              );
            }
            if (call.method == 'getSensitiveDatabasePath') {
              return '/tmp/test';
            }
            throw MissingPluginException();
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel(_channelName), null);
      });

      final repo = _FakeConfigRepo(secureWindowEnabled: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(const AppConfig.playManual()),
            smsPermissionGatewayProvider.overrideWithValue(
              _UnavailableGateway(),
            ),
            configurationRepositoryProvider.overrideWith((ref) async => repo),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
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

      // Toggle the switch — this triggers the native channel call.
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // The repo was updated.
      expect(repo.secureWindowUpdates, [true]);

      // The native-channel failure was logged at SEVERE level.
      final severeRecords = logRecords
          .where((r) => r.level == Level.SEVERE)
          .toList();
      expect(severeRecords, hasLength(1));
      expect(
        severeRecords.first.message,
        contains('setSecureWindowProtection failed'),
      );
      expect(severeRecords.first.error, isA<NativeChannelKeyException>());
    });
  });
}

final class _FakeConfigRepo implements ConfigurationRepository {
  _FakeConfigRepo({this.secureWindowEnabled = true});

  final bool secureWindowEnabled;
  final List<bool> secureWindowUpdates = [];

  @override
  Future<ConfigurationState> load() async =>
      ConfigurationState(secureWindowEnabled: secureWindowEnabled);

  @override
  Future<void> updateSecureWindowEnabled(bool enabled) async {
    secureWindowUpdates.add(enabled);
  }

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
