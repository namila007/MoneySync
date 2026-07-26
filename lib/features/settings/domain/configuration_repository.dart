import 'package:money_sync/features/settings/domain/configuration.dart';

abstract interface class ConfigurationRepository {
  Future<ConfigurationState> load();
  Future<void> updateTheme(AppThemeMode mode);
  Future<void> updateAppLock(AppLockPreferences prefs);
  Future<void> updateRetention(RetentionPreferences prefs);
  Future<void> updateProcessingMode(ProcessingMode mode);
}
