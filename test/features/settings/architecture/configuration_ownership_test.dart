import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Configuration ownership', () {
    String read(String path) => File(path).readAsStringSync();

    test(
      'config-owned columns are written only by the configuration repository',
      () {
        final repoSource = read(
          'lib/features/settings/data/drift_configuration_repository.dart',
        );
        final onboardingRepo = read(
          'lib/features/onboarding/data/drift_onboarding_repository.dart',
        );

        // The onboarding repo owns its columns (onboarding/disclosure) but must
        // not touch config-owned app_settings columns.
        for (final column in [
          'rawCopyRetentionDays',
          'activityRetentionDays',
          'historySmsEnabled',
          'historyWindowDays',
          'historyMessageCap',
          'processingMode',
        ]) {
          expect(
            onboardingRepo.contains(column),
            isFalse,
            reason: 'onboarding repo must not write $column',
          );
        }

        for (final column in [
          'rawCopyRetentionDays',
          'activityRetentionDays',
          'historySmsEnabled',
          'historyWindowDays',
          'historyMessageCap',
          'processingMode',
        ]) {
          expect(
            repoSource.contains(column),
            isTrue,
            reason: 'config repo must own $column',
          );
        }
      },
    );

    test('no settings widget imports the database or Drift companions', () {
      final widgetSources = <String>[
        'lib/features/settings/presentation/settings_page.dart',
        'lib/features/settings/presentation/security_privacy_page.dart',
        'lib/features/sms_permission/presentation/sms_access_page.dart',
        'lib/features/sms_ingestion/presentation/history_scan_page.dart',
        'lib/features/sms_tracking/presentation/tracked_senders_page.dart',
      ];
      for (final path in widgetSources) {
        final source = read(path);
        expect(
          source.contains('package:drift/drift.dart'),
          isFalse,
          reason: '$path must not import Drift',
        );
        expect(
          source.contains('AppDatabase'),
          isFalse,
          reason: '$path must not reference AppDatabase',
        );
        expect(
          source.contains('AppSettingsCompanion'),
          isFalse,
          reason: '$path must not build Drift companions',
        );
      }
    });

    test(
      'settings pages write no configuration themselves (read + navigate only)',
      () {
        // The flattened settings root (M4.15 WP5) owns the secure-window
        // toggle, but all other configuration writes stay in the repository.
        final settings = read(
          'lib/features/settings/presentation/settings_page.dart',
        );
        expect(settings.contains('updateHistoryImport'), isFalse);
        expect(settings.contains('updateRetention'), isFalse);
        expect(settings.contains('updateAppLock'), isFalse);
        expect(settings.contains('updateTheme'), isFalse);
        expect(settings.contains('updateProcessingMode'), isFalse);
      },
    );
  });
}
