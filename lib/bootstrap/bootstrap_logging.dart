import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/core/logging/log_config.dart';
import 'package:money_sync/core/logging/log_directory.dart';
import 'package:money_sync/core/logging/native_log_bridge.dart';
import 'package:money_sync/core/logging/native_log_pigeon.g.dart';
import 'package:money_sync/core/logging/rolling_file_handler.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

Future<void> initLogFileHandlers(AppConfig config) async {
  hierarchicalLoggingEnabled = true;

  final logConfig = LogConfig(
    flavor: config.flavor.name,
    enableDebugLog: const bool.fromEnvironment('ENABLE_DEBUG_LOG'),
    safeLogPolicy: config.logPolicy,
  );

  final dirs = LogDirectoryResolver();
  final redaction = const LogRedactionPolicy();

  Logger.root.level = Level.INFO;
  final errorHandler = RollingFileHandler(
    logDirectory: await dirs.appLogDirectory(),
    baseName: 'error.log',
    redactionPolicy: redaction,
  );
  final infoHandler = RollingFileHandler(
    logDirectory: await dirs.appLogDirectory(),
    baseName: 'info.log',
    redactionPolicy: redaction,
  );
  Logger.root.onRecord.listen((record) {
    if (record.level >= Level.SEVERE) {
      errorHandler.handleLogRecord(record);
    } else if (record.level >= Level.INFO) {
      infoHandler.handleLogRecord(record);
    }
  });

  if (logConfig.enableDebugLog && logConfig.safeLogPolicy.permitsDebugLog) {
    final debugLogger = Logger('app.debug');
    debugLogger.level = Level.FINE;
    final debugHandler = RollingFileHandler(
      logDirectory: await dirs.debugLogDirectory(),
      baseName: 'debug.log',
      maxBytes: 50 * 1024 * 1024,
      maxFiles: 2,
    );
    debugLogger.onRecord.listen(debugHandler.handleLogRecord);
  }

  final nativeLogBridge = NativeLogBridge(
    config: logConfig,
    redaction: redaction,
  );
  NativeLogFlutterApi.setUp(nativeLogBridge);
}
