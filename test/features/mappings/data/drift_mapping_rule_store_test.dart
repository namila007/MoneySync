import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/data/drift_mapping_rule_store.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';

void main() {
  late AppDatabase database;
  late DriftMappingRuleStore store;

  setUp(() {
    database = AppDatabase.inMemoryForTesting();
    store = DriftMappingRuleStore(database: database);
  });

  tearDown(() => database.close());

  MappingRule rule({String id = 'rule-1', int ruleVersion = 1, bool enabled = true}) =>
      MappingRule(
        id: id,
        name: 'Rule $id',
        enabled: enabled,
        senderMatcher: SenderMatcher(['SAMPATH BANK']),
        walletAccountId: 'wallet-1',
        paymentType: 'debit_card',
        syncMode: MappingSyncMode.review,
        priority: 0,
        ruleVersion: ruleVersion,
        createdAtEpochMs: 1,
        updatedAtEpochMs: 1,
      );

  test('save then latest returns the saved version', () async {
    await store.saveVersioned(rule: rule());
    final latest = await store.latest('rule-1');
    expect(latest, isNotNull);
    expect(latest!.ruleVersion, 1);
  });

  test('saveVersioned supersedes and disables the previous row atomically',
      () async {
    await store.saveVersioned(rule: rule(ruleVersion: 1));
    await store.saveVersioned(
      rule: rule(ruleVersion: 2, enabled: true),
      supersededRuleId: 'rule-1',
    );

    final rows = await store.list();
    expect(rows, hasLength(2));
    final newest = await store.latest('rule-1');
    expect(newest!.ruleVersion, 2);
    expect(newest.supersededByRuleId, isNull);

    final rowsById = {for (final r in rows) r.ruleVersion: r};
    final v1 = rowsById[1]!;
    expect(v1.enabled, isFalse);
    expect(v1.supersededByRuleId, 'rule-1');
  });

  test('list returns rows ordered by enabled then name', () async {
    await store.saveVersioned(
      rule: rule(id: 'a', enabled: false),
    );
    await store.saveVersioned(rule: rule(id: 'b'));
    final rows = await store.list();
    expect(rows.map((r) => r.id).toList(), ['b', 'a']);
  });

  test('sender matcher aliases round-trip through JSON', () async {
    final saved = rule().nextVersion();
    await store.saveVersioned(
      rule: MappingRule(
        id: 'r',
        name: 'Aliases',
        enabled: true,
        senderMatcher: SenderMatcher(['NDB', 'NDB BANK']),
        walletAccountId: 'w',
        paymentType: 'cash',
        syncMode: MappingSyncMode.manual,
        priority: 0,
        ruleVersion: 1,
        createdAtEpochMs: 1,
        updatedAtEpochMs: 1,
      ),
    );
    final latest = await store.latest('r');
    expect(latest!.senderMatcher.aliases, ['NDB', 'NDB BANK']);
    expect(saved.ruleVersion, 2);
  });

  test('merchant matcher round-trips through JSON', () async {
    await store.saveVersioned(
      rule: MappingRule(
        id: 'm',
        name: 'Merchant',
        enabled: true,
        senderMatcher: SenderMatcher(['SAMPATH BANK']),
        merchantMatcher: const ExactMerchantMatcher('CAFE'),
        walletAccountId: 'w',
        paymentType: 'cash',
        syncMode: MappingSyncMode.review,
        priority: 0,
        ruleVersion: 1,
        createdAtEpochMs: 1,
        updatedAtEpochMs: 1,
      ),
    );
    final latest = await store.latest('m');
    expect(latest!.merchantMatcher, const ExactMerchantMatcher('CAFE'));
  });

  test('unknown rule returns null', () async {
    expect(await store.latest('missing'), isNull);
  });
}
