import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/logging/activity_writer_generation.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart'
    as ae;

final class ActivityEventWriter {
  ActivityEventWriter({
    required this._database,
    required this._redaction,
    required this._privacyEpochProvider,
    this._generation,
  });

  final AppDatabase _database;
  final LogRedactionPolicy _redaction;
  final Future<int> Function() _privacyEpochProvider;
  final ActivityWriterGeneration? _generation;

  Future<void> writeFromLogRecord(LogRecord record) async {
    final message = record.message.toString();
    // The activity table keeps the strict allowlist. M5.22 WP-F relaxed
    // redact() to masking so log FILES stop coming out empty; this sink must
    // not inherit that relaxation, so it gates on the allowlist explicitly
    // rather than on redact() returning null as it used to.
    if (!_redaction.isAllowedForActivityLog(message)) return;
    final sanitized = _redaction.redact(message);

    final observedGeneration = _generation?.current;

    try {
      final epoch = await _privacyEpochProvider();
      // A clear-activity action may have run while the epoch lookup above
      // was in flight; discard this write rather than resurrect a row the
      // user just intentionally cleared. This fence is independent of the
      // global privacy epoch, which only full-reset advances.
      if (observedGeneration != null &&
          _generation!.current != observedGeneration) {
        return;
      }
      await _database
          .into(_database.activityEvents)
          .insert(
            ActivityEventsCompanion.insert(
              eventType: _eventTypeFor(record.level),
              sanitizedDetail: ae.ActivityStateTransition.logEvent,
              occurredAtEpochMs: record.time.millisecondsSinceEpoch,
              privacyEpoch: epoch,
              detailMessage: Value(sanitized),
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
