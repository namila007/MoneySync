import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:drift/native.dart';

void main() {
  group('Sentinel absence', () {
    late Directory tempDir;
    late AppDatabase db;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('sentinel_test_');
    });

    tearDown(() async {
      try {
        await db.close();
      } catch (_) {}
      tempDir.deleteSync(recursive: true);
    });

    Future<AppDatabase> openDatabaseInDir(Directory dir) async {
      final dbFile = File('${dir.path}/test.db');
      return AppDatabase(NativeDatabase(dbFile));
    }

    test(
      'purged encrypted body is absent from db, wal, shm, and temp files',
      () async {
        const sentinel = 'SENTINEL_MARKER_a7b3c9d2e1f4';

        db = await openDatabaseInDir(tempDir);
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'sentinel-key',
                senderKey: 'sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.review,
                privacyEpoch: 0,
                encryptedBody: const Value(sentinel),
              ),
            );

        verifyFileContainsBytes(tempDir, sentinel.codeUnits);

        await db.close();

        db = await openDatabaseInDir(tempDir);
        addTearDown(db.close);

        await db.transaction(() async {
          await (db.update(
            db.smsEvents,
          )..where((row) => row.status.equals('filtered_otp'))).write(
            const SmsEventsCompanion(
              encryptedBody: Value<String?>(null),
              rawPurgeState: Value(RawPurgeState.purgedOnFilter),
            ),
          );
        });

        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

        verifyFileDoesNotContainBytes(tempDir, sentinel.codeUnits);
      },
    );

    test('body may remain after purge if retention is active', () async {
      const sentinel = 'SENTINEL_RETAINED_b8c4d5e6f7a9';

      db = await openDatabaseInDir(tempDir);
      addTearDown(db.close);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'retain-key',
              senderKey: 'sender',
              ingestionSource: 'manual',
              receivedAtEpochMs: 1234567890,
              status: SmsEventStatus.captured,
              privacyEpoch: 0,
              encryptedBody: const Value(sentinel),
            ),
          );

      verifyFileContainsBytes(tempDir, sentinel.codeUnits);

      await db.close();

      db = await openDatabaseInDir(tempDir);
      addTearDown(db.close);

      await db.transaction(() async {
        await (db.update(
          db.smsEvents,
        )..where((row) => row.status.equals('captured'))).write(
          const SmsEventsCompanion(
            rawPurgeState: Value(RawPurgeState.retainedByConsent),
          ),
        );
      });

      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

      verifyFileContainsBytes(tempDir, sentinel.codeUnits);
    });

    test(
      'purged encrypted body is absent from db, wal, shm after WAL checkpoint',
      () async {
        const sentinel = 'SENTINEL_PURGED_f1e2d3c4b5a6';

        db = await openDatabaseInDir(tempDir);
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'wal-key',
                senderKey: 'sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 100,
                status: SmsEventStatus.review,
                privacyEpoch: 0,
                encryptedBody: const Value(sentinel),
              ),
            );

        verifyFileContainsBytes(tempDir, sentinel.codeUnits);

        await db.close();

        db = await openDatabaseInDir(tempDir);
        addTearDown(db.close);

        await db.transaction(() async {
          await (db.update(
            db.smsEvents,
          )..where((row) => row.status.equals('filtered_otp'))).write(
            const SmsEventsCompanion(
              encryptedBody: Value<String?>(null),
              rawPurgeState: Value(RawPurgeState.purgedOnFilter),
            ),
          );
        });

        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

        final allFiles = tempDir.listSync(recursive: true);
        for (final file in allFiles) {
          if (file is File) {
            final name = file.path.split('/').last;
            if (name.startsWith('test.db')) {
              verifyFileDoesNotContainBytesSingle(file, sentinel.codeUnits);
            }
          }
        }
      },
    );
  });
}

void verifyFileContainsBytes(Directory dir, List<int> needle) {
  final allFiles = dir.listSync(recursive: true);
  var found = false;
  for (final file in allFiles) {
    if (file is File && file.path.contains('test.db')) {
      try {
        final bytes = file.readAsBytesSync();
        if (_containsSequence(bytes, needle)) {
          found = true;
          break;
        }
      } catch (_) {}
    }
  }
  expect(
    found,
    isTrue,
    reason: 'Expected sentinel bytes to exist in test.db files',
  );
}

void verifyFileDoesNotContainBytesSingle(File file, List<int> needle) {
  try {
    final bytes = file.readAsBytesSync();
    if (_containsSequence(bytes, needle)) {
      fail(
        'Sentinel bytes found in ${file.path} — they should have been purged.',
      );
    }
  } catch (_) {}
}

void verifyFileDoesNotContainBytes(Directory dir, List<int> needle) {
  final allFiles = dir.listSync(recursive: true);
  for (final file in allFiles) {
    if (file is File && file.path.contains('test.db')) {
      verifyFileDoesNotContainBytesSingle(file, needle);
    }
  }
}

bool _containsSequence(List<int> haystack, List<int> needle) {
  if (needle.length > haystack.length) return false;
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}
