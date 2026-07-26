import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart' as ae;

final class ActivityEventWriter {
  ActivityEventWriter({
    required AppDatabase database,
    required LogRedactionPolicy redaction,
    required Future<int> Function() privacyEpochProvider,
  })  : _database = database,
        _redaction = redaction,
        _privacyEpochProvider = privacyEpochProvider;

  final AppDatabase _database;
  final LogRedactionPolicy _redaction;
  final Future<int> Function() _privacyEpochProvider;

  Future<void> writeFromLogRecord(LogRecord record) async {
    final message = record.message.toString();
    final sanitized = _redaction.redact(message);
    if (sanitized == null) return;

    try {
      await _database.into(_database.activityEvents).insert(
        ActivityEventsCompanion.insert(
          eventType: _eventTypeFor(record.level),
          sanitizedDetail: ae.ActivityStateTransition.logEvent,
          occurredAtEpochMs: record.time.millisecondsSinceEpoch,
          privacyEpoch: await _privacyEpochProvider(),
        ),
      );
    } on Exception {
      // best-effort: failure to write activity event never blocks the caller
    }
  }

  ae.ActivityEventCode _eventTypeFor(Level level) {
    if (level >= Level.SEVERE) return ae.ActivityEventCode.logError;
    if (level >= Level.WARNING) return ae.ActivityEventCode.logWarning;
    return ae.ActivityEventCode.logInfo;
  }
}
