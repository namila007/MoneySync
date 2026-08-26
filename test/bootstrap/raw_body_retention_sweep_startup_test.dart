import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';

void main() {
  group('runRawBodyRetentionSweep', () {
    test(
      'reads app_settings.rawCopyRetentionDays and purges accordingly',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await (db.update(db.appSettings)
              ..where((row) => row.singletonId.equals(1)))
            .write(const AppSettingsCompanion(rawCopyRetentionDays: Value(0)));

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'expired-1',
                senderKey: 'sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 100,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
                encryptedBody: Value('encrypted-body'),
              ),
            );

        await runRawBodyRetentionSweep(db, Logger('test'));

        final event = await db.select(db.smsEvents).getSingle();
        expect(event.encryptedBody, isNull);

        final activity = await db.select(db.activityEvents).get();
        expect(activity, hasLength(1));
        expect(activity.single.eventType, ActivityEventCode.rawCopyPurged);
        expect(activity.single.batchCount, 1);
      },
    );

    test('writes no activity event when nothing is purged', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await runRawBodyRetentionSweep(db, Logger('test'));

      final activity = await db.select(db.activityEvents).get();
      expect(activity, isEmpty);
    });

    test(
      'a purge of N produces exactly one activity row with count == N',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await (db.update(db.appSettings)
              ..where((row) => row.singletonId.equals(1)))
            .write(const AppSettingsCompanion(rawCopyRetentionDays: Value(0)));

        for (var i = 0; i < 3; i++) {
          await db
              .into(db.smsEvents)
              .insert(
                SmsEventsCompanion.insert(
                  sourceKey: 'expired-$i',
                  senderKey: 'sender',
                  ingestionSource: 'manual',
                  receivedAtEpochMs: 100,
                  status: SmsEventStatus.captured,
                  privacyEpoch: 0,
                  encryptedBody: Value('encrypted-body-$i'),
                ),
              );
        }

        await runRawBodyRetentionSweep(db, Logger('test'));

        final activity = await db.select(db.activityEvents).get();
        expect(activity, hasLength(1));
        expect(activity.single.batchCount, 3);
      },
    );
  });
}
