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

final class ConfigurationState {
  const ConfigurationState({
    this.themeMode = AppThemeMode.system,
    this.appLock = const AppLockPreferences(enabled: false),
    this.retention = const RetentionPreferences(),
    this.processingMode = ProcessingMode.review,
    this.configurationRevision = 0,
  });
  final AppThemeMode themeMode;
  final AppLockPreferences appLock;
  final RetentionPreferences retention;
  final ProcessingMode processingMode;
  final int configurationRevision;
}
