import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_tracking/domain/tracked_senders.dart';

/// Tracked senders backed by the `tracked_senders` table (M4.14 §3.4) — the
/// `schema_metadata` JSON blob was migrated out in v7. The interface is
/// unchanged; only the storage changed.
final class DriftTrackedSendersRepository implements TrackedSendersRepository {
  DriftTrackedSendersRepository({required this.database});

  final AppDatabase database;

  @override
  Future<List<TrackedSender>> load() async {
    final rows = await (database.select(
      database.trackedSenders,
    )..where((t) => t.enabled.equals(true))).get();
    final senders = <TrackedSender>[];
    for (final row in rows) {
      try {
        senders.add(
          TrackedSender.create(
            row.senderKey,
            addedAtEpochMs: row.addedAtEpochMs,
          ),
        );
      } on ArgumentError {
        // fail closed: skip malformed stored entries
      }
    }
    return senders;
  }

  @override
  Future<void> save(List<String> addresses) async {
    await database.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final address in addresses) {
        await database
            .into(database.trackedSenders)
            .insert(
              TrackedSendersCompanion.insert(
                senderKey: address,
                addedAtEpochMs: now,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      await (database.delete(
        database.trackedSenders,
      )..where((t) => t.senderKey.isNotIn(addresses))).go();
    });
  }
}
