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
    final rawCopyDays = await _readMetadata('retention.rawCopyDays');
    final activityDays = await _readMetadata('retention.activityRetentionDays');
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
        rawCopyDays: int.tryParse(rawCopyDays ?? '') ?? 0,
        activityRetentionDays: int.tryParse(activityDays ?? '') ?? 180,
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
      await _writeMetadata('retention.rawCopyDays', prefs.rawCopyDays.toString());
      await _writeMetadata('retention.activityRetentionDays', prefs.activityRetentionDays.toString());
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

  Future<String?> _readMetadata(String key) async {
    final row = await (database.select(database.databaseMetadata)
      ..where((r) => r.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeMetadata(String key, String value) async {
    await database.into(database.databaseMetadata).insertOnConflictUpdate(
      DatabaseMetadataCompanion.insert(key: key, value: value),
    );
  }
}
