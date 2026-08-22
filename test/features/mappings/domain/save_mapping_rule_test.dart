import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/use_cases/save_mapping_rule.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule draft({String id = 'rule-1', String name = 'R1'}) => MappingRule(
    id: id,
    name: name,
    enabled: true,
    senderMatcher: SenderMatcher(['SAMPATH BANK']),
    walletAccountId: 'wallet-1',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: 0,
    ruleVersion: 99,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  test('creates a brand-new rule at version 1 without superseding', () async {
    final store = _FakeMappingRuleStore();
    final useCase = SaveMappingRule(store: store);

    final saved = await useCase.call(draft: draft());

    expect(saved.ruleVersion, 1);
    expect(saved.supersededByRuleId, isNull);
    expect(store.saves, hasLength(1));
    expect(store.saves.single.supersededRuleId, isNull);
  });

  test('editing inserts version+1 and supersedes the previous row', () async {
    final store = _FakeMappingRuleStore(
      existing: draft().copyWith(ruleVersion: 3),
    );
    final useCase = SaveMappingRule(store: store);

    final saved = await useCase.call(
      draft: draft(name: 'R1 renamed'),
      editingRuleId: 'rule-1',
    );

    expect(saved.ruleVersion, 4);
    expect(saved.name, 'R1 renamed');
    expect(saved.supersededByRuleId, isNull);
    expect(store.saves.single.supersededRuleId, 'rule-1');
  });

  test('editing an unknown rule fails closed', () async {
    final store = _FakeMappingRuleStore();
    final useCase = SaveMappingRule(store: store);

    expect(
      () => useCase.call(draft: draft(), editingRuleId: 'missing'),
      throwsA(isA<InvalidMappingRuleFailure>()),
    );
  });

  test('createdAt is preserved across versions', () async {
    final store = _FakeMappingRuleStore(
      existing: draft().copyWith(ruleVersion: 1, createdAtEpochMs: now),
    );
    final useCase = SaveMappingRule(store: store);

    final saved = await useCase.call(draft: draft(), editingRuleId: 'rule-1');
    expect(saved.createdAtEpochMs, now);
  });
}

final class _FakeMappingRuleStore implements MappingRuleStore {
  _FakeMappingRuleStore({this._existing});

  MappingRule? _existing;
  final List<_SaveRecord> saves = [];

  @override
  Future<List<MappingRule>> list() async =>
      _existing == null ? [] : [_existing!];

  @override
  Future<MappingRule?> latest(String ruleId) async =>
      _existing?.id == ruleId ? _existing : null;

  @override
  Future<MappingRule> saveVersioned({
    required MappingRule rule,
    String? supersededRuleId,
  }) async {
    saves.add(_SaveRecord(rule, supersededRuleId));
    _existing = rule;
    return rule;
  }
}

final class _SaveRecord {
  const _SaveRecord(this.rule, this.supersededRuleId);
  final MappingRule rule;
  final String? supersededRuleId;
}

extension on MappingRule {
  MappingRule copyWith({
    int? ruleVersion,
    String? name,
    int? createdAtEpochMs,
  }) {
    return MappingRule(
      id: id,
      name: name ?? this.name,
      enabled: enabled,
      senderMatcher: senderMatcher,
      parserFamily: parserFamily,
      instrumentSuffixHash: instrumentSuffixHash,
      direction: direction,
      merchantMatcher: merchantMatcher,
      walletAccountId: walletAccountId,
      walletCategoryId: walletCategoryId,
      paymentType: paymentType,
      syncMode: syncMode,
      priority: priority,
      minConfidenceBasisPoints: minConfidenceBasisPoints,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      supersededByRuleId: supersededByRuleId,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      updatedAtEpochMs: updatedAtEpochMs,
    );
  }
}
