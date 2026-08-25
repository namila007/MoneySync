import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_config.dart';
import 'package:money_sync/core/logging/native_log_pigeon.g.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

final class NativeLogBridge extends NativeLogFlutterApi {
  NativeLogBridge({required this._config, required this._redaction});

  final LogConfig _config;
  final LogRedactionPolicy _redaction;

  @override
  void onNativeLog(
    int priority,
    String tag,
    String message,
    String? safeErrorCode,
  ) {
    if (!_config.enableDebugLog && priority < 4) return;

    final level = switch (priority) {
      2 || 3 => Level.FINE,
      4 => Level.INFO,
      5 => Level.WARNING,
      6 || 7 => Level.SEVERE,
      _ => null,
    };
    if (level == null) return;

    final logger = Logger('native.$tag');
    if (!logger.isLoggable(level)) return;

    // redact() masks in place and always returns a string (M5.22 WP-F).
    final safeMsg = _redaction.redact(message);
    final line = safeErrorCode != null
        ? '$safeMsg | code=$safeErrorCode'
        : safeMsg;
    logger.log(level, line);
  }
}
