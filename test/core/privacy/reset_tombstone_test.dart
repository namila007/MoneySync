import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/reset_tombstone.dart';

void main() {
  late Directory tempDir;
  late String databasePath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reset_tombstone_test');
    databasePath = '${tempDir.path}/database/money_sync.db';
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ResetTombstone', () {
    test('does not exist before it is persisted', () async {
      final tombstone = ResetTombstone(databasePath: databasePath);

      expect(await tombstone.exists(), isFalse);
    });

    test('exists after persist and is cleared by clear', () async {
      final tombstone = ResetTombstone(databasePath: databasePath);

      await tombstone.persist();
      expect(await tombstone.exists(), isTrue);

      await tombstone.clear();
      expect(await tombstone.exists(), isFalse);
    });

    test('clear is idempotent when no tombstone exists', () async {
      final tombstone = ResetTombstone(databasePath: databasePath);

      await tombstone.clear();
      await tombstone.clear();

      expect(await tombstone.exists(), isFalse);
    });

    test('persist creates the parent directory if missing', () async {
      final tombstone = ResetTombstone(databasePath: databasePath);
      expect(await Directory('${tempDir.path}/database').exists(), isFalse);

      await tombstone.persist();

      expect(await Directory('${tempDir.path}/database').exists(), isTrue);
    });

    test('is stored as a sibling of the database file', () async {
      final tombstone = ResetTombstone(databasePath: databasePath);

      await tombstone.persist();

      final markerFile = File('${tempDir.path}/database/reset_tombstone.marker');
      expect(await markerFile.exists(), isTrue);
    });
  });
}
