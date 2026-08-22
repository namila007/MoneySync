import 'package:money_sync/core/errors/domain_failure.dart';

import '../mapping_rule.dart';

/// Persistence boundary for [MappingRule] rows. The data layer implements
/// these inside one Drift transaction so versioning is atomic (M5.3).
abstract interface class MappingRuleStore {
  /// All rule rows, newest version first for each rule id.
  Future<List<MappingRule>> list();

  /// The latest (highest [MappingRule.ruleVersion]) enabled-or-disabled row
  /// for [ruleId], or null when the rule has never been saved.
  Future<MappingRule?> latest(String ruleId);

  /// Atomically insert [rule] and supersede [supersededRuleId] if provided
  /// (set `superseded_by_rule_id`, disable the old row). The old row is never
  /// updated in place otherwise.
  Future<MappingRule> saveVersioned({
    required MappingRule rule,
    String? supersededRuleId,
  });
}

/// Saves a mapping rule as a new immutable version. Never mutates an existing
/// row: a fresh row with incremented [MappingRule.ruleVersion] is inserted and
/// the previous version is superseded+disabled in the same transaction
/// (plan/03 §Rule creation flow; M5.3).
final class SaveMappingRule {
  SaveMappingRule({required this._store});

  final MappingRuleStore _store;

  /// [draft] may carry any ruleVersion — the use case owns versioning and  /// overrides it. When [editingRuleId] is null this is a brand-new rule.
  Future<MappingRule> call({
    required MappingRule draft,
    String? editingRuleId,
  }) async {
    final previous = editingRuleId == null
        ? null
        : await _store.latest(editingRuleId);
    if (editingRuleId != null && previous == null) {
      throw const InvalidMappingRuleFailure();
    }

    final next = _nextVersion(draft, previous);
    return _store.saveVersioned(rule: next, supersededRuleId: previous?.id);
  }

  MappingRule _nextVersion(MappingRule draft, MappingRule? previous) {
    final baseVersion = previous?.ruleVersion ?? 0;
    return MappingRule(
      id: previous?.id ?? draft.id,
      name: draft.name,
      enabled: draft.enabled,
      senderMatcher: draft.senderMatcher,
      parserFamily: draft.parserFamily,
      instrumentSuffixHash: draft.instrumentSuffixHash,
      direction: draft.direction,
      merchantMatcher: draft.merchantMatcher,
      walletAccountId: draft.walletAccountId,
      walletCategoryId: draft.walletCategoryId,
      paymentType: draft.paymentType,
      syncMode: draft.syncMode,
      priority: draft.priority,
      minConfidenceBasisPoints: draft.minConfidenceBasisPoints,
      ruleVersion: baseVersion + 1,
      supersededByRuleId: null,
      createdAtEpochMs: previous?.createdAtEpochMs ?? draft.createdAtEpochMs,
      updatedAtEpochMs: draft.updatedAtEpochMs,
    );
  }
}
