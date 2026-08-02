import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';

final class DriftConfigurationRepository implements ConfigurationRepository {
  DriftConfigurationRepository({required this.database});

  final AppDatabase database;

  @override
  Future<ConfigurationState> load() async {
    final setting = await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();
    final lockState = await (database.select(
      database.appLockState,
    )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
    return ConfigurationState(
      configurationRevision: setting.configurationRevision,
      processingMode: setting.processingMode == 'manual'
          ? ProcessingMode.manual
          : ProcessingMode.review,
      appLock: AppLockPreferences(
        enabled: lockState?.lockEnabled ?? false,
        inactivityTimeoutSeconds: lockState?.inactivityTimeoutSeconds ?? 300,
      ),
      retention: RetentionPreferences(
        rawCopyDays: setting.rawCopyRetentionDays,
        activityRetentionDays: setting.activityRetentionDays,
      ),
    );
  }

  @override
  Future<void> updateTheme(AppThemeMode mode) async {}

  @override
  Future<void> updateAppLock(AppLockPreferences prefs) async {
    await database.transaction(() async {
      await (database.update(
        database.appLockState,
      )..where((row) => row.singletonId.equals(1))).write(
        AppLockStateCompanion(
          lockEnabled: Value(prefs.enabled),
          inactivityTimeoutSeconds: Value(prefs.inactivityTimeoutSeconds),
        ),
      );
      await _incrementRevision();
    });
  }

  @override
  Future<void> updateRetention(RetentionPreferences prefs) async {
    await database.transaction(() async {
      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        AppSettingsCompanion(
          rawCopyRetentionDays: Value(prefs.rawCopyDays),
          activityRetentionDays: Value(prefs.activityRetentionDays),
        ),
      );
      await _incrementRevision();
    });
  }

  @override
  Future<void> updateProcessingMode(ProcessingMode mode) async {
    await database.transaction(() async {
      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        AppSettingsCompanion(
          processingMode: Value(
            mode == ProcessingMode.manual ? 'manual' : 'review',
          ),
        ),
      );
      await _incrementRevision();
    });
  }

  Future<void> _incrementRevision() async {
    final current = await load();
    await (database.update(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).write(
      AppSettingsCompanion(
        configurationRevision: Value(current.configurationRevision + 1),
      ),
    );
  }
}
