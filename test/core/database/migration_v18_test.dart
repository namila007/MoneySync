import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('Schema v18 migration', () {
    test('schema version is 18', () {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      expect(db.schemaVersion, 18);
    });

    test('wallet_mutations has a nullable discardedAtEpochMs column', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db.customStatement(
        "INSERT INTO wallet_mutations "
        "(id, operation_kind, payload, state, lineage_key, fingerprint, "
        " created_at_epoch_ms, updated_at_epoch_ms) "
        "VALUES ('m1', 'create', '{}', 'retry_scheduled', 'lk', 'fp', 0, 0)",
      );

      final row = await (db.select(
        db.walletMutations,
      )..where((m) => m.id.equals('m1'))).getSingle();
      expect(row.discardedAtEpochMs, isNull);

      await (db.update(db.walletMutations)..where((m) => m.id.equals('m1')))
          .write(const WalletMutationsCompanion(discardedAtEpochMs: Value(42)));

      final updated = await (db.select(
        db.walletMutations,
      )..where((m) => m.id.equals('m1'))).getSingle();
      expect(updated.discardedAtEpochMs, 42);
    });
  });
}
