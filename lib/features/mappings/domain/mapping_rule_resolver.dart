import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

import 'mapping_rule.dart';

/// Resolves which Wallet destination an already-parsed candidate routes to.
///
/// Distinct from `transaction_parser/domain/rule_pack_registry.dart` — that
/// registry picks the bank parser that extracts fields from raw SMS; this
/// resolver picks the Wallet destination for an already-parsed candidate.
/// They only share an input shape (`parserFamily`, `senderNormalized`).
/// Implements the 5-rank precedence from plan/03 §Mapping resolution as
/// ordered predicate buckets (M5.3).
final class MappingRuleResolver {
  MappingRuleResolver({required List<MappingRule> rules})
    : _rules = List.unmodifiable(rules);

  final List<MappingRule> _rules;

  MappingResolution resolve(MappingResolutionInput input) {
    final enabled = _rules.where((rule) => rule.enabled).toList();

    final ranked = <int, List<MappingRule>>{};
    for (final rule in enabled) {
      final rank = _rank(rule, input);
      if (rank != null) ranked.putIfAbsent(rank, () => []).add(rule);
    }
    if (ranked.isEmpty) return const MappingUnmatched();

    final bestRank = ranked.keys.reduce((a, b) => a < b ? a : b);
    var bucket = ranked[bestRank]!;

    if (bucket.length > 1) {
      final maxPriority = bucket
          .map((r) => r.priority)
          .reduce((a, b) => a > b ? a : b);
      bucket = bucket.where((r) => r.priority == maxPriority).toList();
    }

    if (bucket.length == 1) return MappingResolved(bucket.single);
    return MappingAmbiguous(List.unmodifiable(bucket));
  }

  /// Highest-precedence bucket the rule matches, or null when any configured
  /// constraint fails. Ranks follow plan/03 §Mapping resolution:
  /// 1 = sender + instrument + parser family + direction,
  /// 2 = sender + instrument,
  /// 3 = sender + parser family/direction,
  /// 4 = sender only. A configured constraint that does not match excludes the
  /// rule entirely — it never degrades to a lower bucket. Explicit user
  /// priority breaks ties within a bucket.
  int? _rank(MappingRule rule, MappingResolutionInput input) {
    if (!rule.senderMatcher.matches(input.senderNormalized)) return null;
    if (!_confidenceSatisfied(rule, input)) return null;
    if (rule.merchantMatcher != null &&
        !rule.merchantMatcher!.matches(input.merchantNormalized)) {
      return null;
    }

    final hasInstrument = rule.instrumentSuffixHash != null;
    final hasFamily = rule.parserFamily != null;
    final hasDirection = rule.direction != null;

    if (hasInstrument) {
      if (input.instrumentSuffixHash == null ||
          rule.instrumentSuffixHash != input.instrumentSuffixHash) {
        return null;
      }
    }
    if (hasFamily) {
      if (input.parserFamily == null || rule.parserFamily != input.parserFamily) {
        return null;
      }
    }
    if (hasDirection) {
      if (input.direction == null || rule.direction != input.direction) {
        return null;
      }
    }

    if (hasInstrument && hasFamily && hasDirection) return 1;
    if (hasInstrument) return 2;
    if (hasFamily || hasDirection) return 3;
    return 4;
  }

  bool _confidenceSatisfied(MappingRule rule, MappingResolutionInput input) {
    final floor = rule.minConfidenceBasisPoints;
    return floor == null || input.confidenceBasisPoints >= floor;
  }
}

/// The input an already-parsed candidate provides to the resolver.
final class MappingResolutionInput {
  const MappingResolutionInput({
    required this.senderNormalized,
    required this.confidenceBasisPoints,
    required this.merchantNormalized,
    this.parserFamily,
    this.instrumentSuffixHash,
    this.direction,
  });

  final String senderNormalized;
  final int confidenceBasisPoints;
  final String merchantNormalized;
  final String? parserFamily;
  final String? instrumentSuffixHash;
  final TransactionDirection? direction;
}

/// Outcome of a mapping resolution — mirrors `rule_pack_registry.dart`'s
/// Match|Tie|None shape (same pattern, different domain).
sealed class MappingResolution {
  const MappingResolution();
}

final class MappingResolved extends MappingResolution {
  const MappingResolved(this.rule);
  final MappingRule rule;
}

/// Two or more rules tied at the same specificity and priority — never pick
/// arbitrarily (plan/03 §Mapping resolution).
final class MappingAmbiguous extends MappingResolution {
  const MappingAmbiguous(this.tiedRules);
  final List<MappingRule> tiedRules;
}

final class MappingUnmatched extends MappingResolution {
  const MappingUnmatched();
}
