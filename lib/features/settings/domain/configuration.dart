enum AppThemeMode { system, light, dark }

enum ProcessingMode { review, manual }

final class AppLockPreferences {
  const AppLockPreferences({
    required this.enabled,
    this.inactivityTimeoutSeconds = 300,
  });
  final bool enabled;
  final int inactivityTimeoutSeconds;
}

final class RetentionPreferences {
  const RetentionPreferences({
    this.rawCopyDays = 0,
    this.activityRetentionDays = 180,
  });
  final int rawCopyDays;
  final int activityRetentionDays;
}

final class HistoryImportPreferences {
  const HistoryImportPreferences({
    this.windowDays = 7,
    this.messageCap = 100,
    this.enabled = false,
  });

  final int windowDays;
  final int messageCap;
  final bool enabled;
}

const int kHistoryMinWindowDays = 1;
const int kHistoryMaxWindowDays = 90;
const List<int> kHistoryWindowPresets = [3, 7, 14];
const int kHistoryHardCap = 500;
const int kRawCopyRetentionMaxDays = 30;

final class ConfigurationState {
  const ConfigurationState({
    this.themeMode = AppThemeMode.system,
    this.appLock = const AppLockPreferences(enabled: false),
    this.retention = const RetentionPreferences(),
    this.historyImport = const HistoryImportPreferences(),
    this.processingMode = ProcessingMode.review,
    this.configurationRevision = 0,
    this.secureWindowEnabled = true,
    this.autoImportEnabled = false,
    this.autoCreateEnabled = false,
    this.autoImportIntervalMinutes = 15,
  });
  final AppThemeMode themeMode;
  final AppLockPreferences appLock;
  final RetentionPreferences retention;
  final HistoryImportPreferences historyImport;
  final ProcessingMode processingMode;
  final int configurationRevision;
  final bool secureWindowEnabled;
  final bool autoImportEnabled;
  final bool autoCreateEnabled;
  final int autoImportIntervalMinutes;
}
