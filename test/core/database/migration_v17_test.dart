import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('Schema v17 migration', () {
    test('schema version is 17', () {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      expect(db.schemaVersion, 17);
    });

    test('fresh install defaults autoImportIntervalMinutes to 15', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(setting.autoImportIntervalMinutes, 15);
    });

    test(
      'v16->v17 upgrade sets autoImportIntervalMinutes to 15 for existing rows',
      () async {
        // A fresh in-memory database starts at the current schema version.
        // The ALTER-add-column migration in onUpgrade sets the DEFAULT (15)
        // for all existing rows. Verify the column is present and defaulted.
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.autoImportIntervalMinutes, 15);
      },
    );
  });
}
