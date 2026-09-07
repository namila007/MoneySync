import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('AppSettings dedup migration', () {
    test(
      'app_settings singleton row exists after fresh database open',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        // The in-memory database runs through beforeOpen(), which applies
        // the dedup and creates the unique index. Verify the row exists.
        final row = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(row.singletonId, 1);
      },
    );

    test('app_settings has correct defaults after migration', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final row = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(row.singletonId, 1);
      expect(row.privacyEpoch, 0);
      expect(row.onboardingCompleted, false);
      expect(row.disclosureAccepted, false);
      expect(row.processingMode, 'review');
      expect(row.configurationRevision, 0);
    });

    test(
      'INSERT OR IGNORE prevents duplicate app_settings after dedup',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        // The beforeOpen has already inserted the singleton row and created
        // the unique index. Verify that repeated INSERT OR IGNORE doesn't
        // create duplicates (this is what would have failed before the fix).
        final countBefore = await db
            .customSelect(
              'SELECT COUNT(*) as cnt FROM app_settings WHERE singleton_id = 1',
              readsFrom: {db.appSettings},
            )
            .map((row) => row.read<int>('cnt'))
            .getSingle();
        expect(countBefore, 1);

        // Simulate another app open (another INSERT OR IGNORE)
        await db.customStatement(
          'INSERT OR IGNORE INTO app_settings (singleton_id, privacy_epoch) '
          'VALUES (1, 0)',
        );

        // Still exactly one row (INSERT OR IGNORE was ignored due to constraint)
        final countAfter = await db
            .customSelect(
              'SELECT COUNT(*) as cnt FROM app_settings WHERE singleton_id = 1',
              readsFrom: {db.appSettings},
            )
            .map((row) => row.read<int>('cnt'))
            .getSingle();
        expect(countAfter, 1);
      },
    );

    test('dedup SQL is idempotent (safe to run multiple times)', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      // Run the dedup SQL (even though there are no duplicates in this
      // in-memory database, verify it doesn't break anything)
      await db.customStatement(
        'DELETE FROM app_settings WHERE rowid NOT IN '
        '(SELECT MAX(rowid) FROM app_settings WHERE singleton_id = 1) '
        'AND singleton_id = 1',
      );

      // Verify the singleton row still exists
      final row = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(row.singletonId, 1);

      // Run dedup again (idempotent)
      await db.customStatement(
        'DELETE FROM app_settings WHERE rowid NOT IN '
        '(SELECT MAX(rowid) FROM app_settings WHERE singleton_id = 1) '
        'AND singleton_id = 1',
      );

      // Still one row
      final rowAfter = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(rowAfter.singletonId, 1);
    });

    test('unique index prevents manual duplicate inserts', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      // The unique index was created in beforeOpen. Verify that a direct
      // INSERT (not INSERT OR IGNORE) fails with UNIQUE constraint.
      expect(
        () => db.customStatement(
          'INSERT INTO app_settings (singleton_id, privacy_epoch) '
          'VALUES (1, 1)',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
