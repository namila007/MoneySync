import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/data/drift_activity_log_repository.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';

void main() {
  late AppDatabase db;
  late DriftActivityLogRepository repository;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    repository = DriftActivityLogRepository(database: db);
  });

  tearDown(() => db.close());

  Future<void> insert({
    required ActivityEventCode code,
    required ActivityStateTransition detail,
    required int occurredAtEpochMs,
    int privacyEpoch = 0,
  }) {
    return db
        .into(db.activityEvents)
        .insert(
          ActivityEventsCompanion.insert(
            eventType: code,
            sanitizedDetail: detail,
            occurredAtEpochMs: occurredAtEpochMs,
            privacyEpoch: privacyEpoch,
          ),
        );
  }

  group('DriftActivityLogRepository', () {
    test('returns an empty list when nothing has been recorded', () async {
      expect(await repository.recent(), isEmpty);
    });

    test('returns entries newest first', () async {
      await insert(
        code: ActivityEventCode.logInfo,
        detail: ActivityStateTransition.logEvent,
        occurredAtEpochMs: 1000,
      );
      await insert(
        code: ActivityEventCode.rawCopyPurged,
        detail: ActivityStateTransition.rawCopyPurged,
        occurredAtEpochMs: 3000,
      );
      await insert(
        code: ActivityEventCode.privacyEpochAdvanced,
        detail: ActivityStateTransition.privacyEpochAdvanced,
        occurredAtEpochMs: 2000,
      );

      final entries = await repository.recent();

      expect(
        entries.map((e) => e.occurredAt.millisecondsSinceEpoch).toList(),
        equals([3000, 2000, 1000]),
      );
      expect(entries.first.code, ActivityEventCode.rawCopyPurged);
    });

    test('honours the limit and keeps the newest entries', () async {
      for (var i = 0; i < 10; i++) {
        await insert(
          code: ActivityEventCode.logInfo,
          detail: ActivityStateTransition.logEvent,
          occurredAtEpochMs: i * 1000,
        );
      }

      final entries = await repository.recent(limit: 3);

      expect(entries, hasLength(3));
      expect(
        entries.map((e) => e.occurredAt.millisecondsSinceEpoch).toList(),
        equals([9000, 8000, 7000]),
      );
    });

    test('exposes only enum-typed fields, never free text', () async {
      await insert(
        code: ActivityEventCode.candidateNeedsReview,
        detail: ActivityStateTransition.needsReview,
        occurredAtEpochMs: 5000,
        privacyEpoch: 2,
      );

      final entry = (await repository.recent()).single;

      // The table has no free-text column, so a rendered entry cannot carry
      // message content. Assert the shape stays enum-only.
      expect(entry.code, isA<ActivityEventCode>());
      expect(entry.detail, isA<ActivityStateTransition>());
      expect(entry.privacyEpoch, 2);
    });
  });
}
