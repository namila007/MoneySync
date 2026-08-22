import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// The inputs every pre-send gate evaluates. Assembled by the caller (M5.9)
/// from repositories; gates are pure logic over it so the whole chain is
/// unit-testable against fakes with no DB/network (M5.8).
final class PreSendContext {
  PreSendContext({
    required this.candidateId,
    required this.amountMinor,
    required this.currencyCode,
    required this.recordDateUtc,
    required this.direction,
    required this.paymentType,
    required this.senderNormalized,
    required this.confidenceBasisPoints,
    required this.privacyEpochMatches,
    required this.consentCurrent,
    required this.connectionConnected,
    required this.eligibleTargetAccount,
    required this.targetAccountEligibility,
    required this.mappingResolution,
    required this.capabilityCanCreate,
    required this.hasActiveLineage,
    required this.hasOwnedRecordLink,
    this.parserFamily,
    this.instrumentSuffixHash,
    this.merchantNormalized,
  });

  final String candidateId;
  final int amountMinor;
  final String currencyCode;
  final DateTime recordDateUtc;
  final TransactionDirection direction;
  final String paymentType;
  final String senderNormalized;
  final int confidenceBasisPoints;

  /// Privacy/deletion epoch captured at ingest matches the current epoch.
  final bool privacyEpochMatches;

  /// Disclosure accepted + revision current + processing not automation-only.
  final bool consentCurrent;

  final bool connectionConnected;

  /// True when the Wallet account is writable/eligible (M5.2 fake fixture
  /// until that spike closes; never the real reader before then).
  final bool eligibleTargetAccount;
  final WalletAccountEligibility targetAccountEligibility;

  final MappingResolution mappingResolution;

  /// `WalletCapabilityLedger.canCreate` for the current contract version.
  final bool capabilityCanCreate;

  /// True when an active create lineage already exists for this candidate.
  final bool hasActiveLineage;

  /// True when an app-owned WalletRecordLink exists for this candidate.
  final bool hasOwnedRecordLink;

  final String? parserFamily;
  final String? instrumentSuffixHash;
  final String? merchantNormalized;
}

/// One pre-send gate. The first `Block` short-circuits the chain, but the
/// policy returns the FULL ordered list of outcomes (plan/05; M5.8).
sealed class PreSendGate {
  const PreSendGate();

  GateResult check(PreSendContext context);
}

sealed class GateResult {
  const GateResult();
}

final class GatePass extends GateResult {
  const GatePass();
}

final class GateBlock extends GateResult {
  const GateBlock(this.reason);
  final String reason;
}

/// Gate 1 — privacy epoch matches (deletion epoch / DatabaseMetadata).
final class PrivacyEpochGate extends PreSendGate {
  const PrivacyEpochGate();

  @override
  GateResult check(PreSendContext context) => context.privacyEpochMatches
      ? const GatePass()
      : const GateBlock('Stale privacy epoch. Re-confirm before sending.');
}

/// Gate 2 — consent current (disclosure accepted + revision + non-automation).
final class ConsentGate extends PreSendGate {
  const ConsentGate();

  @override
  GateResult check(PreSendContext context) => context.consentCurrent
      ? const GatePass()
      : const GateBlock('SMS consent is not current.');
}

/// Gate 3 — Wallet connection established.
final class WalletConnectionGate extends PreSendGate {
  const WalletConnectionGate();

  @override
  GateResult check(PreSendContext context) => context.connectionConnected
      ? const GatePass()
      : const GateBlock('Wallet is not connected.');
}

/// Gate 4 — account eligibility (writable + not archived + same currency).
final class AccountEligibilityGate extends PreSendGate {
  const AccountEligibilityGate();

  @override
  GateResult check(PreSendContext context) {
    if (!context.eligibleTargetAccount) {
      return GateBlock(
        'Target account is not writable (${context.targetAccountEligibility.name}).',
      );
    }
    if (context.targetAccountEligibility != WalletAccountEligibility.eligible) {
      return GateBlock(
        'Target account is not eligible (${context.targetAccountEligibility.name}).',
      );
    }
    return const GatePass();
  }
}

/// Gate 5 — mapping resolution (M5.3 resolver output in context).
final class MappingResolutionGate extends PreSendGate {
  const MappingResolutionGate();

  @override
  GateResult check(PreSendContext context) =>
      switch (context.mappingResolution) {
        MappingResolved(:final rule) => _ruleAllowed(context, rule),
        MappingAmbiguous() => const GateBlock(
          'Mapping is ambiguous. Review first.',
        ),
        MappingUnmatched() => const GateBlock('No mapping rule matched.'),
      };

  GateResult _ruleAllowed(PreSendContext context, MappingRule rule) {
    final automaticAllowed = switch (rule.syncMode) {
      MappingSyncMode.automatic =>
        context.confidenceBasisPoints >=
            (rule.minConfidenceBasisPoints ?? 9000),
      _ => true,
    };
    return automaticAllowed
        ? const GatePass()
        : const GateBlock('Confidence below the automatic threshold.');
  }
}

/// Gate 6 — amount/date/currency validation (same-currency only for M5).
final class CandidateValidationGate extends PreSendGate {
  const CandidateValidationGate();

  @override
  GateResult check(PreSendContext context) {
    if (context.amountMinor == 0) {
      return const GateBlock('Amount must be non-zero.');
    }
    final now = DateTime.now().toUtc();
    final futureLimit = now.add(const Duration(hours: 24));
    final pastLimit = now.subtract(const Duration(days: 3650));
    if (context.recordDateUtc.isAfter(futureLimit) ||
        context.recordDateUtc.isBefore(pastLimit)) {
      return const GateBlock('Record date is outside Wallet accepted bounds.');
    }
    if (context.currencyCode.toUpperCase() != 'LKR') {
      return const GateBlock('Foreign-currency create is review-only in M5.');
    }
    return const GatePass();
  }
}

/// Gate 7 — duplicate/tombstone: no active create lineage, no owned link.
final class DuplicateTombstoneGate extends PreSendGate {
  const DuplicateTombstoneGate();

  @override
  GateResult check(PreSendContext context) {
    if (context.hasActiveLineage) {
      return const GateBlock('An active create lineage already exists.');
    }
    if (context.hasOwnedRecordLink) {
      return const GateBlock('This candidate already owns a Wallet record.');
    }
    return const GatePass();
  }
}

/// Gate 8 — capability gate (reuses WalletCapabilityLedger.canCreate).
final class CapabilityGate extends PreSendGate {
  const CapabilityGate();

  @override
  GateResult check(PreSendContext context) => context.capabilityCanCreate
      ? const GatePass()
      : const GateBlock('Wallet create capability is not enabled.');
}

/// The fixed-order pre-send gate chain. Runs all gates, short-circuits on the
/// first block, returns the FULL ordered outcome list for the review UI.
final class WalletCreateEligibilityPolicy {
  const WalletCreateEligibilityPolicy();

  static const gates = <PreSendGate>[
    PrivacyEpochGate(),
    ConsentGate(),
    WalletConnectionGate(),
    AccountEligibilityGate(),
    MappingResolutionGate(),
    CandidateValidationGate(),
    DuplicateTombstoneGate(),
    CapabilityGate(),
  ];

  GateEvaluation evaluate(PreSendContext context) {
    final outcomes = <GateResult>[];
    var firstBlockedGate = -1;
    for (var i = 0; i < gates.length; i++) {
      final result = gates[i].check(context);
      outcomes.add(result);
      if (result is GateBlock && firstBlockedGate < 0) {
        firstBlockedGate = i;
      }
    }
    return GateEvaluation(
      outcomes: List.unmodifiable(outcomes),
      firstBlockedGateIndex: firstBlockedGate,
      allowed: firstBlockedGate < 0,
    );
  }
}

/// Full evaluation: every gate's outcome plus whether and where the chain
/// blocked (UI needs the specific gate, not just a boolean).
final class GateEvaluation {
  GateEvaluation({
    required this.outcomes,
    required this.firstBlockedGateIndex,
    required this.allowed,
  }) : assert(
         firstBlockedGateIndex == -1 || !allowed,
         'blocked index and allowed disagree',
       );

  final List<GateResult> outcomes;
  final int firstBlockedGateIndex;
  final bool allowed;

  String? get firstBlockReason => switch (firstBlockedGateIndex) {
    -1 => null,
    final int i => (outcomes[i] as GateBlock).reason,
  };
}
