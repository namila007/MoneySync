import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/data/rule_packs/registry_source.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';

/// Builds the active [RulePackRegistry] from the `rule_packs` table: packs
/// from the compiled manifest are registered on first run (that is what
/// `checksum` / `installedAtEpochMs` are for), and selection only ever sees
/// packs whose `enabled` flag is set. Pack definitions stay compiled Dart;
/// activation is data (M4.14 WP5).
final class RulePackRegistryRepository {
  const RulePackRegistryRepository({required this.database});

  final AppDatabase database;

  Future<RulePackRegistry> loadActiveRegistry() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final pack in allRulePacks) {
      await database
          .into(database.rulePacks)
          .insert(
            RulePacksCompanion.insert(
              id: pack.id,
              version: pack.version,
              checksum: pack.checksum,
              market: pack.market,
              installedAtEpochMs: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    final rows = await (database.select(
      database.rulePacks,
    )..where((t) => t.enabled.equals(true))).get();
    final enabled = {for (final row in rows) '${row.id}|${row.version}'};
    return RulePackRegistry(
      packs: [
        for (final pack in allRulePacks)
          if (enabled.contains('${pack.id}|${pack.version}')) pack,
      ],
    );
  }
}
