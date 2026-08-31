import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/mappings/domain/use_cases/save_mapping_rule.dart';

/// Deletes a mapping rule by its [ruleId]. Confirms the rule exists before
/// deletion (harmless no-op if already deleted or never existed).
final class DeleteMappingRule {
  DeleteMappingRule({required this._store});

  final MappingRuleStore _store;

  /// Deletes the rule with [ruleId]. Throws [InvalidMappingRuleFailure] if
  /// the rule does not exist.
  Future<void> call({required String ruleId}) async {
    final existing = await _store.latest(ruleId);
    if (existing == null) {
      throw const InvalidMappingRuleFailure();
    }
    await _store.delete(ruleId);
  }
}
