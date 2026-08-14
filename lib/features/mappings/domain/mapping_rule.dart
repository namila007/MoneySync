import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

/// Automation level of one mapping rule (plan/03 §mapping_rule `sync_mode`).
/// Persisted by name — append new members, never rename or reorder.
enum MappingSyncMode { inherit, manual, review, automatic }

/// Exact normalized sender aliases a rule matches (plan/03 §mapping_rule
/// `sender_matcher`). Never matched by display name; sender strings are
/// normalized (trim, uppercase, NFC) before comparison.
final class SenderMatcher {
  SenderMatcher(Iterable<String> aliases)
    : aliases = List<String>.unmodifiable(
        aliases.map((a) => a.trim().toUpperCase()),
      ) {
    if (this.aliases.isEmpty) {
      throw const InvalidMappingRuleFailure();
    }
  }

  final List<String> aliases;

  bool matches(String normalizedSender) =>
      aliases.contains(normalizedSender.toUpperCase());
}

/// Optional merchant constraint. Arbitrary user regex is excluded from MVP
/// (plan/03 §mapping_rule `merchant_matcher`).
sealed class MerchantMatcher {
  const MerchantMatcher();

  bool matches(String normalizedMerchant);
}

final class ExactMerchantMatcher extends MerchantMatcher {
  const ExactMerchantMatcher(this.merchant);

  final String merchant;

  @override
  bool matches(String normalizedMerchant) =>
      normalizedMerchant.toUpperCase() == merchant.toUpperCase();

  @override
  bool operator ==(Object other) =>
      other is ExactMerchantMatcher && other.merchant == merchant;

  @override
  int get hashCode => Object.hash(ExactMerchantMatcher, merchant);
}

final class ContainsMerchantMatcher extends MerchantMatcher {
  const ContainsMerchantMatcher(this.fragment);

  final String fragment;

  @override
  bool matches(String normalizedMerchant) =>
      normalizedMerchant.toUpperCase().contains(fragment.toUpperCase());

  @override
  bool operator ==(Object other) =>
      other is ContainsMerchantMatcher && other.fragment == fragment;

  @override
  int get hashCode => Object.hash(ContainsMerchantMatcher, fragment);
}

/// An immutable, versioned Wallet-routing rule (plan/03 §mapping_rule).
/// New versions replace old ones; a rule is never updated in place (M5.3).
final class MappingRule {
  MappingRule({
    required this.id,
    required this.name,
    required this.enabled,
    required this.senderMatcher,
    this.parserFamily,
    this.instrumentSuffixHash,
    this.direction,
    this.merchantMatcher,
    required this.walletAccountId,
    this.walletCategoryId,
    required this.paymentType,
    required this.syncMode,
    required this.priority,
    this.minConfidenceBasisPoints,
    required this.ruleVersion,
    this.supersededByRuleId,
    required this.createdAtEpochMs,
    required this.updatedAtEpochMs,
  }) {
    if (id.isEmpty ||
        name.isEmpty ||
        walletAccountId.isEmpty ||
        paymentType.isEmpty ||
        ruleVersion < 1 ||
        minConfidenceBasisPoints != null &&
            (minConfidenceBasisPoints! < 0 ||
                minConfidenceBasisPoints! > 10000)) {
      throw const InvalidMappingRuleFailure();
    }
  }

  final String id;
  final String name;
  final bool enabled;
  final SenderMatcher senderMatcher;
  final String? parserFamily;
  final String? instrumentSuffixHash;
  final TransactionDirection? direction;
  final MerchantMatcher? merchantMatcher;
  final String walletAccountId;
  final String? walletCategoryId;
  final String paymentType;
  final MappingSyncMode syncMode;
  final int priority;
  final int? minConfidenceBasisPoints;
  final int ruleVersion;
  final String? supersededByRuleId;
  final int createdAtEpochMs;
  final int updatedAtEpochMs;

  /// Copy for the next immutable version: increments [ruleVersion] and clears
  /// the superseded link of the previous generation.
  MappingRule nextVersion({String? supersededByRuleId}) => MappingRule(
    id: id,
    name: name,
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
    ruleVersion: ruleVersion + 1,
    supersededByRuleId: supersededByRuleId,
    createdAtEpochMs: createdAtEpochMs,
    updatedAtEpochMs: updatedAtEpochMs,
  );
}
