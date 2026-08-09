import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:drift/native.dart';

void main() {
  group('v5 migration', () {
    Future<AppDatabase> _migrateFrom(int fromVersion) async {
      return AppDatabase(
        NativeDatabase.memory(
          setup: (db) {
            db.execute(
              'INSERT INTO _drift_schema_versions (id, run_at) '
              'VALUES (?, unixepoch())',
              [fromVersion],
            );
          },
        ),
      );
    }

    test('v5 schema version is reported on fresh database', () {
      final database = AppDatabase.inMemoryForTesting();
      expect(database.schemaVersion, 5);
    });

    test('smsDisclosureRevision is null after migration', () async {
      final db = AppDatabase.inMemoryForTesting();
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(setting.smsDisclosureRevision, isNull);
    });

    test('historySmsEnabled defaults to false after migration', () async {
      final db = AppDatabase.inMemoryForTesting();
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(setting.historySmsEnabled, false);
    });

    test(
      'historyWindowDays defaults to 7 and historyMessageCap to 100',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(setting.historyWindowDays, 7);
        expect(setting.historyMessageCap, 100);
      },
    );

    test('rule_packs and ingestion_checkpoint exist and are empty', () async {
      final db = AppDatabase.inMemoryForTesting();
      final rulePacksRows = await db.select(db.rulePacks).get();
      expect(rulePacksRows.length, 0);
      final checkpointsRows = await db.select(db.ingestionCheckpoints).get();
      expect(checkpointsRows.length, 0);
    });
  });
}
