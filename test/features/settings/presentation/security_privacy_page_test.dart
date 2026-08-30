import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/settings/presentation/security_privacy_page.dart';

Widget _app({ConfigurationRepository? configRepo}) {
  return ProviderScope(
    overrides: [
      configurationRepositoryProvider.overrideWith(
        (ref) async => configRepo ?? _FakeConfigRepo(),
      ),
    ],
    child: const MaterialApp(home: SecurityPrivacyPage()),
  );
}

void main() {
  group('SecurityPrivacyPage', () {
    testWidgets('shows App Security title', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('App Security'), findsOneWidget);
    });

    testWidgets(
      'screenshot protection switch reflects and persists the state',
      (tester) async {
        final repo = _FakeConfigRepo(secureWindowEnabled: false);
        await tester.pumpWidget(_app(configRepo: repo));
        await tester.pumpAndSettle();

        final toggle = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Screenshot protection'),
        );
        expect(toggle.value, isFalse);

        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Screenshot protection'),
        );
        await tester.pumpAndSettle();

        expect(repo.secureWindowUpdates, [true]);
      },
    );

    testWidgets('retention section is not present', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Local copy retention'), findsNothing);
      expect(find.text('Raw app copy'), findsNothing);
      expect(find.text('Activity history'), findsNothing);
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

  @override
  Future<void> updateAutoImportIntervalMinutes(int minutes) async {}
}
