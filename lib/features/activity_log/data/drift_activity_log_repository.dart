import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';

/// Read-only Drift implementation. This repository never writes: activity rows
/// are written deliberately at user-facing moments and only ever read back here.
final class DriftActivityLogRepository implements ActivityLogRepository {
  const DriftActivityLogRepository({required this._database});

  final AppDatabase _database;

  static const defaultLimit = 200;

  @override
  Future<List<ActivityLogEntry>> recent({
    int limit = defaultLimit,
    ActivityEventCode? code,
  }) async {
    final query = _database.select(_database.activityEvents)
      ..orderBy([
        (row) => OrderingTerm(
          expression: row.occurredAtEpochMs,
          mode: OrderingMode.desc,
        ),
        (row) => OrderingTerm(expression: row.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    if (code != null) {
      query.where((row) => row.eventType.equals(code.wireValue));
    }

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
            count: row.batchCount,
            mutationId: row.mutationId,
            detailMessage: row.detailMessage,
          ),
        )
        .toList(growable: false);
  }
}
