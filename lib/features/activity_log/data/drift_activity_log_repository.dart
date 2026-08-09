import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';

/// Read-only Drift implementation. This repository never writes: activity rows
/// are produced by ActivityEventWriter and only ever read back here.
final class DriftActivityLogRepository implements ActivityLogRepository {
  const DriftActivityLogRepository({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  static const defaultLimit = 200;

  @override
  Future<List<ActivityLogEntry>> recent({int limit = defaultLimit}) async {
    final query = _database.select(_database.activityEvents)
      ..orderBy([
        (row) => OrderingTerm(
          expression: row.occurredAtEpochMs,
          mode: OrderingMode.desc,
        ),
        (row) => OrderingTerm(expression: row.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows
        .map(
          (row) => ActivityLogEntry(
            id: row.id,
            code: row.eventType,
            detail: row.sanitizedDetail,
            occurredAt: DateTime.fromMillisecondsSinceEpoch(
              row.occurredAtEpochMs,
              isUtc: true,
            ),
            privacyEpoch: row.privacyEpoch,
          ),
        )
        .toList(growable: false);
  }
}
