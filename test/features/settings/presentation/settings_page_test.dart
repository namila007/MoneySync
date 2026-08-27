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

Widget _app({ConfigurationRepository? configRepo}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.playManual()),
      smsPermissionGatewayProvider.overrideWithValue(_UnavailableGateway()),
      configurationRepositoryProvider.overrideWith(
        (ref) async => configRepo ?? _FakeConfigRepo(),
      ),
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
      'playManual shows the permission status without a grant affordance',
      (tester) async {
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
        expect(find.text('Grant'), findsNothing);
        expect(find.text('Allow'), findsNothing);
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
