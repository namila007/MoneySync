import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/privacy/retention_policy.dart';

void main() {
  group('RawBodyRetentionSweep', () {
    test(
      'purges filtered events immediately regardless of retention setting',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'filtered-otp',
                senderKey: 'sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 100,
                status: SmsEventStatus.ignored,
                privacyEpoch: 0,
                encryptedBody: Value('encrypted-body-data'),
              ),
            );

        final sweep = RawBodyRetentionSweep(database: db, retentionDays: 14);

        final result = await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));
        expect(result.purgedOnFilter, 1);
        expect(result.totalPurged, 1);

        final event = await db.select(db.smsEvents).getSingle();
        expect(event.encryptedBody, isNull);
        expect(event.rawPurgeState, RawPurgeState.purgedOnFilter);
      },
    );

    test('purges filtered promotional events', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'filtered-promo',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.ignored,
              privacyEpoch: 0,
              encryptedBody: Value('promo-body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 7);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedOnFilter);
    });

    test('purges filtered unrelated events', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'filtered-unrelated',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.ignored,
              privacyEpoch: 0,
              encryptedBody: Value('unrelated-body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 7);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedOnFilter);
    });

    test('purges rejected events', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'rejected-msg',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.ignored,
              privacyEpoch: 0,
              encryptedBody: Value('rejected-body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 7);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedOnFilter);
    });

    test('purges processed events when retentionDays is 0', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'processed-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('some-body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 0);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedAfterProcessing);
    });

    test(
      'retains processed events when retentionDays > 0 and not expired',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'retained-key',
                senderKey: 'sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 100,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
                encryptedBody: Value('retained-body'),
              ),
            );

        final sweep = RawBodyRetentionSweep(database: db, retentionDays: 14);
        await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

        final event = await db.select(db.smsEvents).getSingle();
        expect(event.encryptedBody, 'retained-body');
        expect(event.rawPurgeState, RawPurgeState.retainedByConsent);
      },
    );

    test('purges on expiry when expires_at has passed', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'expired-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('expired-body'),
              expiresAtEpochMs: Value(500),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 14);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedOnExpiry);
    });

    test('clamps retentionDays > 30 to 30', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'clamped-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 90);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, 'body');
      expect(event.rawPurgeState, RawPurgeState.retainedByConsent);
    });

    test('clamps retentionDays < 0 to 0', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'negative-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: -5);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedAfterProcessing);
    });

    test('preserves source_key and sender_hash after purge', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'preserve-key',
              senderKey: 'preserve-sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 1234567890,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('body-to-purge'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 0);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final event = await db.select(db.smsEvents).getSingle();
      expect(event.sourceKey, 'preserve-key');
      expect(event.senderKey, 'preserve-sender');
      expect(event.receivedAtEpochMs, 1234567890);
      expect(event.encryptedBody, isNull);
      expect(event.rawPurgeState, RawPurgeState.purgedAfterProcessing);
    });

    test(
      'a purged event is still detected as duplicate on re-import',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        // Insert without encrypted body (simulating post-purge state)
        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'dedup-key',
                senderKey: 'sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 100,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final sweep = RawBodyRetentionSweep(database: db, retentionDays: 0);
        await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

        // Try to re-import same sourceKey via insertSmsEventIfAbsent
        final result = await db.insertSmsEventIfAbsent(
          sourceKey: 'dedup-key',
          senderKey: 'sender',
          ingestionSource: 'manual',
          receivedAtEpochMs: 100,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
        );

        expect(result.inserted, false);
      },
    );

    test('is idempotent — second run changes nothing', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'idempotent-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('body'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 0);

      final result1 = await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));
      expect(result1.purgedAfterProcessing, 1);
      expect(result1.totalPurged, 1);

      final result2 = await sweep.call(nowUtc: DateTime.utc(2025, 1, 2));
      expect(result2.purgedAfterProcessing, 0);
      expect(result2.totalPurged, 0);
      expect(result2.skipped, 0);
    });

    test('never touches activity_events', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'activity-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.ignored,
              privacyEpoch: 0,
              encryptedBody: Value('otp-data'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 0);
      await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      final activities = await db.select(db.activityEvents).get();
      expect(activities, isEmpty);
    });

    test('skips rows already in terminal purge states', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'already-purged',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              rawPurgeState: const Value(RawPurgeState.purgedAfterProcessing),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 0);
      final result = await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));
      expect(result.skipped, 0);
      expect(result.totalPurged, 0);
    });

    test('reports correct result counts', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'filtered',
              senderKey: 's',
              ingestionSource: 'manual',
              receivedAtEpochMs: 100,
              status: SmsEventStatus.ignored,
              privacyEpoch: 0,
              encryptedBody: Value('otp'),
            ),
          );
      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'processed',
              senderKey: 's',
              ingestionSource: 'manual',
              receivedAtEpochMs: 101,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('body'),
            ),
          );
      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'retained',
              senderKey: 's',
              ingestionSource: 'manual',
              receivedAtEpochMs: 102,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: Value('keep'),
            ),
          );

      final sweep = RawBodyRetentionSweep(database: db, retentionDays: 14);
      final result = await sweep.call(nowUtc: DateTime.utc(2025, 1, 1));

      expect(result.purgedOnFilter, 1);
      expect(result.purgedAfterProcessing, 0);
      expect(result.purgedOnExpiry, 0);
      expect(result.retainedByConsent, 2);
      expect(result.skipped, 0);
      expect(result.totalPurged, 1);
    });
  });
}
