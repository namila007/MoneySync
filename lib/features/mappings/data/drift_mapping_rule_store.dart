import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/use_cases/save_mapping_rule.dart';

/// Drift implementation of [MappingRuleStore] over the v9 `mapping_rule`
/// table (M5.1/M5.4). Versioning is atomic: save inserts the new row and
/// supersedes+disables the previous one inside one transaction.
final class DriftMappingRuleStore implements MappingRuleStore {
  DriftMappingRuleStore({required this._database});

  final AppDatabase _database;

  @override
  Future<List<MappingRule>> list() async {    final rows = await (_database.select(_database.mappingRules)
          ..orderBy([
            (t) => OrderingTerm.desc(t.enabled),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<MappingRule?> latest(String ruleId) async {
    final rows = await (_database.select(_database.mappingRules)
          ..where((t) => t.id.equals(ruleId))
          ..orderBy([(t) => OrderingTerm.desc(t.ruleVersion)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : _toDomain(rows.single);
  }

  @override
  Future<MappingRule> saveVersioned({
    required MappingRule rule,
    String? supersededRuleId,
  }) async {
    return _database.transaction(() async {
      if (supersededRuleId != null) {
        final previous = await _database
            .customSelect(
              'SELECT MAX(rule_version) AS v FROM mapping_rule '
              'WHERE id = ?',
              variables: [Variable(supersededRuleId)],
              readsFrom: {_database.mappingRules},
            )
            .getSingle();
        final previousVersion = previous.read<int?>('v');
        if (previousVersion != null) {
          await (_database.update(_database.mappingRules)
                ..where(
                  (t) =>
                      t.id.equals(supersededRuleId) &
                      t.ruleVersion.equals(previousVersion),
                ))
              .write(
            MappingRulesCompanion(
              enabled: const Value(false),
              supersededByRuleId: Value(rule.id),
              updatedAtEpochMs: Value(rule.updatedAtEpochMs),
            ),
          );
        }
      }
      await _database.into(_database.mappingRules).insert(_fromDomain(rule));
      return rule;
    });
  }

  MappingRule _toDomain(MappingRuleRow row) {
    final sender = SenderMatcher(
      (jsonDecode(row.senderMatcher) as List<dynamic>).cast<String>(),
    );
    return MappingRule(
      id: row.id,
      name: row.name,
      enabled: row.enabled,
      senderMatcher: sender,
      parserFamily: row.parserFamily,
      instrumentSuffixHash: row.instrumentSuffixHash,
      direction: row.direction,
      merchantMatcher: row.merchantMatcher == null
          ? null
          : _merchantMatcherFromJson(row.merchantMatcher!),
      walletAccountId: row.walletAccountId,
      walletCategoryId: row.walletCategoryId,
      paymentType: row.paymentType,
      syncMode: row.syncMode,
      priority: row.priority,
      minConfidenceBasisPoints: row.minConfidenceBasisPoints,
      ruleVersion: row.ruleVersion,
      supersededByRuleId: row.supersededByRuleId,
      createdAtEpochMs: row.createdAtEpochMs,
      updatedAtEpochMs: row.updatedAtEpochMs,
    );
  }

  MappingRulesCompanion _fromDomain(MappingRule rule) {
    return MappingRulesCompanion.insert(
      id: rule.id,
      name: rule.name,
      enabled: rule.enabled,
      senderMatcher: jsonEncode(rule.senderMatcher.aliases),
      parserFamily: Value(rule.parserFamily),
      instrumentSuffixHash: Value(rule.instrumentSuffixHash),
      direction: Value(rule.direction),
      merchantMatcher: Value(
        rule.merchantMatcher == null
            ? null
            : _merchantMatcherToJson(rule.merchantMatcher!),
      ),
      walletAccountId: rule.walletAccountId,
      walletCategoryId: Value(rule.walletCategoryId),
      paymentType: rule.paymentType,
      syncMode: rule.syncMode,
      priority: rule.priority,
      minConfidenceBasisPoints: Value(rule.minConfidenceBasisPoints),
      ruleVersion: rule.ruleVersion,
      supersededByRuleId: Value(rule.supersededByRuleId),
      createdAtEpochMs: rule.createdAtEpochMs,
      updatedAtEpochMs: rule.updatedAtEpochMs,
    );
  }

  static MerchantMatcher _merchantMatcherFromJson(String json) {
    final map = (jsonDecode(json) as Map<dynamic, dynamic>).cast<String, dynamic>();
    return switch (map['kind']) {
      'exact' => ExactMerchantMatcher(map['value'] as String),
      'contains' => ContainsMerchantMatcher(map['value'] as String),
      _ => throw const FormatException('Unknown merchant matcher'),
    };
  }

  static String _merchantMatcherToJson(MerchantMatcher matcher) =>
      switch (matcher) {
        ExactMerchantMatcher(merchant: final v) =>
          jsonEncode({'kind': 'exact', 'value': v}),
        ContainsMerchantMatcher(fragment: final f) =>
          jsonEncode({'kind': 'contains', 'value': f}),
      };
}
