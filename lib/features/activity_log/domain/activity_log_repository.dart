import 'package:money_sync/features/activity_log/domain/activity_event.dart';

/// A single sanitized entry in the local activity log.
///
/// Every field is either an enum or a number. The `activity_events` table has
/// no free-text column, so an entry structurally cannot carry message content,
/// account numbers, or any other personal data.
final class ActivityLogEntry {
  const ActivityLogEntry({
    required this.id,
    required this.code,
    required this.detail,
    required this.occurredAt,
    required this.privacyEpoch,
    this.count,
  });

  final int id;
  final ActivityEventCode code;
  final ActivityStateTransition detail;
  final DateTime occurredAt;
  final int privacyEpoch;

  /// Batch size for aggregated events (M4.15 WP3); null for single-item
  /// events.
  final int? count;
}

/// Read-only port over the local activity log.
abstract interface class ActivityLogRepository {
  /// Most recent entries first, capped at [limit].
  Future<List<ActivityLogEntry>> recent({int limit});
}
