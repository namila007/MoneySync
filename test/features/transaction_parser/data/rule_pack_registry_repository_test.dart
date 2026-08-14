import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/data/rule_pack_registry_repository.dart';
import 'package:money_sync/features/transaction_parser/data/rule_packs/registry_source.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';

/// Activation as data (M4.14 WP5): packs register on first run with their
/// checksum, and the `rule_packs.enabled` flag decides selection.
void main() {
  test('registry contains every pack in the manifest by default', () async {
    final db = AppDatabase.inMemoryForTesting();
    addTearDown(db.close);

    final registry = await RulePackRegistryRepository(
      database: db,
    ).loadActiveRegistry();

    expect(registry.packs, hasLength(allRulePacks.length));
    expect(registry.packs.map((p) => p.id), allRulePacks.map((p) => p.id));

    final rows = await db.select(db.rulePacks).get();
    expect(rows, hasLength(allRulePacks.length));
    for (final row in rows) {
      expect(row.enabled, isTrue);
      final pack = allRulePacks.firstWhere((p) => p.id == row.id);
      expect(row.checksum, pack.checksum);
      expect(row.version, pack.version);
      expect(row.installedAtEpochMs, greaterThan(0));
    }
  });

  test('a pack disabled in rule_packs is excluded from selection', () async {
    final db = AppDatabase.inMemoryForTesting();
    addTearDown(db.close);
    final repository = RulePackRegistryRepository(database: db);

    await repository.loadActiveRegistry();
    final pack = allRulePacks.first;
    await (db.update(db.rulePacks)..where((t) => t.id.equals(pack.id))).write(
      const RulePacksCompanion(enabled: Value(false)),
    );

    final registry = await repository.loadActiveRegistry();
    expect(registry.packs, isEmpty);
    expect(
      registry.select(body: 'anything', sender: 'SAMPATH'),
      isA<RulePackSelectionNone>(),
    );
  });

  test('a new pack is registered with its checksum on first run', () async {
    final db = AppDatabase.inMemoryForTesting();
    addTearDown(db.close);

    final repository = RulePackRegistryRepository(database: db);
    await repository.loadActiveRegistry();
    // Second run must not duplicate or overwrite the first-run registration.
    await repository.loadActiveRegistry();

    final rows = await db.select(db.rulePacks).get();
    expect(rows, hasLength(allRulePacks.length));
  });
}
