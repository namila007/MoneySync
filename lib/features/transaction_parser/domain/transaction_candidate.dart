import 'dart:collection';

import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/money/money.dart';
import 'package:money_sync/core/time/source_date_evidence.dart';

enum TransactionKind {
  expense,
  income,
  refund,
  transfer,
  authorization,
  settlement,
  reversal,
  nonTransaction,
  unknown,
}

enum TransactionDirection { debit, credit, neutral }

enum FinancialLifecycle {
  posted,
  authorized,
  awaitingSettlement,
  settled,
  reversed,
  unclassified,
}

enum ConfidenceBand { low, medium, high }

enum ReviewReason {
  lowConfidence,
  authorization,
  foreignCurrency,
  transfer,
  ambiguousDirection,
  ambiguousMapping,
  parserConflict,
  unknownKind,
  externalShare,
}

enum CandidateRecordState { needsReview, ignored, retainedLocal, superseded }

enum DecisionTraceCode {
  initialReview,
  filteredNonTransaction,
  filteredOtp,
  filteredPromotional,
  ruleFamilyMatched,
  ruleFamilyUnmatched,
  parsedComplete,
  parsedPartial,
  validationRejected,
  ambiguousDirection,
  ambiguousCurrency,
  reviewRequired,
}

enum DecisionStage {
  normalize,
  filter,
  ruleFamilySelect,
  parse,
  validate,
  classify,
  finalize,
}

/// Confidence stored as integer basis points, never binary floating point.
final class CandidateConfidence {
  CandidateConfidence({required this.basisPoints}) {
    if (basisPoints < 0 || basisPoints > 10000) {
      throw const InvalidCandidateFailure();
    }
  }

  final int basisPoints;

  ConfidenceBand get band => switch (basisPoints) {
    >= 9000 => ConfidenceBand.high,
    >= 7000 => ConfidenceBand.medium,
    _ => ConfidenceBand.low,
  };

  @override
  bool operator ==(Object other) =>
      other is CandidateConfidence && other.basisPoints == basisPoints;

  @override
  int get hashCode => basisPoints.hashCode;
}

/// Versioned evidence needed to reproduce a parser outcome.
final class CandidateProvenance {
  CandidateProvenance({
    required this.parserRuleId,
    required this.parserRuleVersion,
    required this.captureCanonicalizationVersion,
    required this.sourceDateEvidence,
  }) {
    if (parserRuleId.isEmpty ||
        parserRuleVersion.isEmpty ||
        captureCanonicalizationVersion < 1) {
      throw const InvalidCandidateFailure();
    }
  }

  final String parserRuleId;
  final String parserRuleVersion;
  final int captureCanonicalizationVersion;
  final SourceDateEvidence sourceDateEvidence;
}

/// A validated, immutable financial interpretation of one source message.
final class TransactionCandidate {
  TransactionCandidate({
    required this.id,
    required this.sourceMessageKey,
    required this.kind,
    required this.direction,
    required this.lifecycle,
    required this.originalAmount,
    required DateTime transactionAtUtc,
    required this.confidence,
    required Set<ReviewReason> reviewReasons,
    required this.provenance,
  }) : transactionAtUtc = transactionAtUtc,
       reviewReasons = UnmodifiableSetView<ReviewReason>(
         Set<ReviewReason>.from(reviewReasons),
       ) {
    if (id.isEmpty || sourceMessageKey.isEmpty || !transactionAtUtc.isUtc) {
      throw const InvalidCandidateFailure();
    }
    _validateSemantics();
  }

  final String id;
  final String sourceMessageKey;
  final TransactionKind kind;
  final TransactionDirection direction;
  final FinancialLifecycle lifecycle;
  final Money originalAmount;
  final DateTime transactionAtUtc;
  final CandidateConfidence confidence;
  final Set<ReviewReason> reviewReasons;
  final CandidateProvenance provenance;

  bool get requiresReview =>
      reviewReasons.isNotEmpty ||
      kind == TransactionKind.authorization ||
      kind == TransactionKind.refund ||
      kind == TransactionKind.transfer ||
      kind == TransactionKind.unknown;

  TransactionCandidate copyWith({
    TransactionKind? kind,
    TransactionDirection? direction,
    FinancialLifecycle? lifecycle,
    Money? originalAmount,
    DateTime? transactionAtUtc,
    CandidateConfidence? confidence,
    Set<ReviewReason>? reviewReasons,
    CandidateProvenance? provenance,
  }) {
    return TransactionCandidate(
      id: id,
      sourceMessageKey: sourceMessageKey,
      kind: kind ?? this.kind,
      direction: direction ?? this.direction,
      lifecycle: lifecycle ?? this.lifecycle,
      originalAmount: originalAmount ?? this.originalAmount,
      transactionAtUtc: transactionAtUtc ?? this.transactionAtUtc,
      confidence: confidence ?? this.confidence,
      reviewReasons: reviewReasons ?? this.reviewReasons,
      provenance: provenance ?? this.provenance,
    );
  }

  void _validateSemantics() {
    final directionMatchesAmount = switch (direction) {
      TransactionDirection.debit => originalAmount.minorUnits < 0,
      TransactionDirection.credit => originalAmount.minorUnits > 0,
      TransactionDirection.neutral => originalAmount.isZero,
    };
    if (!directionMatchesAmount ||
        !_isValidKindDirection() ||
        !_isValidLifecycle()) {
      throw const InvalidCandidateFailure();
    }
  }

  bool _isValidKindDirection() => switch (kind) {
    TransactionKind.expense ||
    TransactionKind.authorization ||
    TransactionKind.settlement => direction == TransactionDirection.debit,
    TransactionKind.income ||
    TransactionKind.refund ||
    TransactionKind.reversal => direction == TransactionDirection.credit,
    TransactionKind.nonTransaction ||
    TransactionKind.unknown => direction == TransactionDirection.neutral,
    TransactionKind.transfer => direction != TransactionDirection.neutral,
  };

  bool _isValidLifecycle() => switch (kind) {
    TransactionKind.authorization =>
      lifecycle == FinancialLifecycle.authorized ||
          lifecycle == FinancialLifecycle.awaitingSettlement,
    TransactionKind.settlement => lifecycle == FinancialLifecycle.settled,
    TransactionKind.reversal => lifecycle == FinancialLifecycle.reversed,
    TransactionKind.nonTransaction ||
    TransactionKind.unknown => lifecycle == FinancialLifecycle.unclassified,
    _ => lifecycle == FinancialLifecycle.posted,
  };
}
