import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('Schema v16 migration', () {
    test('schema version is 16', () {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      expect(db.schemaVersion, 16);
    });

    test('tracking_state singleton row exists with safe defaults', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final row = await (db.select(
        db.trackingState,
      )..where((row) => row.id.equals(1))).getSingle();

      expect(row.id, 1);
      expect(row.lastScanAtEpochMs, isNull);
      expect(row.lastScanOutcome, isNull);
      expect(row.lastSafeErrorCode, isNull);
      expect(row.privacyEpoch, 0);
    });

    test(
      'app_settings has auto-import and auto-create flags defaulting false',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.autoImportEnabled, false);
        expect(setting.autoCreateEnabled, false);
      },
    );
  });
}
