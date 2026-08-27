import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';

final class DriftConfigurationRepository implements ConfigurationRepository {
  DriftConfigurationRepository({required this.database});

  final AppDatabase database;

  static const _secureWindowKey = 'secure_window_enabled';

  @override
  Future<ConfigurationState> load() async {
    final setting = await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();
    final lockState = await (database.select(
      database.appLockState,
    )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
    final rawCopyDays = setting.rawCopyRetentionDays > kRawCopyRetentionMaxDays
        ? kRawCopyRetentionMaxDays
        : setting.rawCopyRetentionDays;
    final secureRow = await (database.select(
      database.databaseMetadata,
    )..where((t) => t.key.equals(_secureWindowKey))).getSingleOrNull();
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
        rawCopyDays: rawCopyDays,
        activityRetentionDays: setting.activityRetentionDays,
      ),
      historyImport: HistoryImportPreferences(
        enabled: setting.historySmsEnabled,
        windowDays: setting.historyWindowDays,
        messageCap: setting.historyMessageCap,
      ),
      secureWindowEnabled: secureRow?.value != 'false',
      autoImportEnabled: setting.autoImportEnabled,
      autoCreateEnabled: setting.autoCreateEnabled,
      autoImportIntervalMinutes: setting.autoImportIntervalMinutes,
    );
  }

  @override
  Future<void> updateSecureWindowEnabled(bool enabled) async {
    await database
        .into(database.databaseMetadata)
        .insertOnConflictUpdate(
          DatabaseMetadataCompanion.insert(
            key: _secureWindowKey,
            value: enabled ? 'true' : 'false',
          ),
        );
  }

  @override
  Future<void> updateAutoImportEnabled(bool enabled) async {
    await database.transaction(() async {
      await (database.update(database.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(AppSettingsCompanion(autoImportEnabled: Value(enabled)));
      await _incrementRevision();
    });
  }

  @override
  Future<void> updateAutoCreateEnabled(bool enabled) async {
    await database.transaction(() async {
      await (database.update(database.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(AppSettingsCompanion(autoCreateEnabled: Value(enabled)));
      await _incrementRevision();
    });
  }

  @override
  Future<void> updateAutoImportIntervalMinutes(int minutes) async {
    final clamped = minutes < 15 ? 15 : minutes;
    await database.transaction(() async {
      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        AppSettingsCompanion(autoImportIntervalMinutes: Value(clamped)),
      );
      await _incrementRevision();
    });
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
    final clamped = prefs.rawCopyDays > kRawCopyRetentionMaxDays
        ? kRawCopyRetentionMaxDays
        : prefs.rawCopyDays;
    await database.transaction(() async {
      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        AppSettingsCompanion(
          rawCopyRetentionDays: Value(clamped),
          activityRetentionDays: Value(prefs.activityRetentionDays),
        ),
      );
      await _incrementRevision();
    });
  }

  @override
  Future<void> updateHistoryImport(HistoryImportPreferences prefs) async {
    await database.transaction(() async {
      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        AppSettingsCompanion(
          historySmsEnabled: Value(prefs.enabled),
          historyWindowDays: Value(prefs.windowDays),
          historyMessageCap: Value(prefs.messageCap),
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
