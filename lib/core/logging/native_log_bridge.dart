import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_config.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

final class NativeLogBridge {
  NativeLogBridge({
    required LogConfig config,
    required LogRedactionPolicy redaction,
  })  : _config = config,
        _redaction = redaction;

  final LogConfig _config;
  final LogRedactionPolicy _redaction;

  void onNativeLog(int priority, String tag, String message, String? safeErrorCode) {
    if (!_config.enableDebugLog && priority < 4) return;

    final level = switch (priority) {
      2 || 3 => Level.SEVERE,
      4 || 5 => Level.INFO,
      _ => Level.FINE,
    };

    final logger = Logger('native.$tag');
    if (!logger.isLoggable(level)) return;

    final safeMsg = _redaction.redact(message) ?? '[redacted]';
    final line = safeErrorCode != null ? '$safeMsg | code=$safeErrorCode' : safeMsg;
    logger.log(level, line);
  }
}
