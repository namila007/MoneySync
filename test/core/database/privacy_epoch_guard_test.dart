import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('Privacy epoch guard', () {
    test('insertSmsEventIfAbsent succeeds when epoch is current', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final result = await db.insertSmsEventIfAbsent(
        sourceKey: 'test-key',
        senderKey: 'test-sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1234567890,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      expect(result.inserted, true);
      expect(result.id, isNonZero);
    });

    test(
      'insertSmsEventIfAbsent throws StalePrivacyEpochException when epoch is stale',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db.advancePrivacyEpoch(expectedCurrent: 0);

        expect(
          () => db.insertSmsEventIfAbsent(
            sourceKey: 'test-key',
            senderKey: 'test-sender',
            ingestionSource: 'manual',
            receivedAtEpochMs: 1234567890,
            status: SmsEventStatus.captured,
            privacyEpoch: 0,
            captureCanonicalizationVersion: 2,
          ),
          throwsA(isA<StalePrivacyEpochException>()),
        );
      },
    );

    test(
      'insertSmsEventIfAbsent does not insert when epoch is stale',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db.advancePrivacyEpoch(expectedCurrent: 0);

        try {
          await db.insertSmsEventIfAbsent(
            sourceKey: 'test-key',
            senderKey: 'test-sender',
            ingestionSource: 'manual',
            receivedAtEpochMs: 1234567890,
            status: SmsEventStatus.captured,
            privacyEpoch: 0,
            captureCanonicalizationVersion: 2,
          );
        } on StalePrivacyEpochException {
          // Expected
        }

        final events = await db.select(db.smsEvents).get();
        expect(events, isEmpty);
      },
    );

    test('insertSmsEventIfAbsent succeeds with advanced epoch', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final newEpoch = await db.advancePrivacyEpoch(expectedCurrent: 0);

      final result = await db.insertSmsEventIfAbsent(
        sourceKey: 'test-key',
        senderKey: 'test-sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1234567890,
        status: SmsEventStatus.captured,
        privacyEpoch: newEpoch,
        captureCanonicalizationVersion: 2,
      );

      expect(result.inserted, true);
    });

    test('advancePrivacyEpoch rejects stale expectedCurrent', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db.advancePrivacyEpoch(expectedCurrent: 0);

      expect(
        () => db.advancePrivacyEpoch(expectedCurrent: 0),
        throwsA(isA<StalePrivacyEpochException>()),
      );
    });

    test('advancePrivacyEpoch increments epoch atomically', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final epoch1 = await db.advancePrivacyEpoch(expectedCurrent: 0);
      expect(epoch1, 1);

      final epoch2 = await db.advancePrivacyEpoch(expectedCurrent: 1);
      expect(epoch2, 2);

      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(setting.privacyEpoch, 2);
    });

    test(
      'duplicate sourceKey with current epoch returns existing id',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final result1 = await db.insertSmsEventIfAbsent(
          sourceKey: 'duplicate-key',
          senderKey: 'sender-1',
          ingestionSource: 'manual',
          receivedAtEpochMs: 1234567890,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
        );

        final result2 = await db.insertSmsEventIfAbsent(
          sourceKey: 'duplicate-key',
          senderKey: 'sender-2',
          ingestionSource: 'history_selection',
          receivedAtEpochMs: 9876543210,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
        );

        expect(result1.inserted, true);
        expect(result2.inserted, false);
        expect(result2.id, result1.id);
      },
    );

    test(
      'duplicate sourceKey with stale epoch throws before checking',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db.insertSmsEventIfAbsent(
          sourceKey: 'duplicate-key',
          senderKey: 'sender',
          ingestionSource: 'manual',
          receivedAtEpochMs: 1234567890,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
        );

        await db.advancePrivacyEpoch(expectedCurrent: 0);

        expect(
          () => db.insertSmsEventIfAbsent(
            sourceKey: 'duplicate-key',
            senderKey: 'sender',
            ingestionSource: 'manual',
            receivedAtEpochMs: 1234567890,
            status: SmsEventStatus.captured,
            privacyEpoch: 0,
            captureCanonicalizationVersion: 2,
          ),
          throwsA(isA<StalePrivacyEpochException>()),
        );
      },
    );

    test(
      'transaction rollback on stale epoch prevents partial writes',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db.advancePrivacyEpoch(expectedCurrent: 0);

        try {
          await db.transaction(() async {
            await db.insertSmsEventIfAbsent(
              sourceKey: 'test-key',
              senderKey: 'test-sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 1234567890,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              captureCanonicalizationVersion: 2,
            );
          });
        } on StalePrivacyEpochException {
          // Expected
        }

        final events = await db.select(db.smsEvents).get();
        expect(events, isEmpty);
      },
    );
  });
}
