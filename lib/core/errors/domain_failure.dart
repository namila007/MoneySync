/// Safe, machine-readable categories for domain validation failures.
enum DomainFailureCode {
  invalidMoney,
  currencyMismatch,
  invalidDateEvidence,
  invalidCandidate,
  illegalStateTransition,
  invalidMutationIntent,
  invalidInstrumentEvidence,
  invalidMappingRule,
}

/// A failure that may cross domain boundaries without carrying sensitive input.
sealed class DomainFailure implements Exception {
  const DomainFailure(this.code, this.safeMessage);

  final DomainFailureCode code;
  final String safeMessage;

  @override
  String toString() => 'DomainFailure(${code.name})';
}

final class InvalidMoneyFailure extends DomainFailure {
  const InvalidMoneyFailure()
    : super(DomainFailureCode.invalidMoney, 'The money value is not valid.');
}

final class CurrencyMismatchFailure extends DomainFailure {
  const CurrencyMismatchFailure()
    : super(
        DomainFailureCode.currencyMismatch,
        'The money currencies do not match.',
      );
}

final class InvalidDateEvidenceFailure extends DomainFailure {
  const InvalidDateEvidenceFailure()
    : super(
        DomainFailureCode.invalidDateEvidence,
        'The source date evidence is not valid.',
      );
}

final class InvalidCandidateFailure extends DomainFailure {
  const InvalidCandidateFailure()
    : super(
        DomainFailureCode.invalidCandidate,
        'The transaction candidate is not valid.',
      );
}

final class InvalidStateTransitionFailure extends DomainFailure {
  const InvalidStateTransitionFailure({required this.from, required this.to})
    : super(
        DomainFailureCode.illegalStateTransition,
        'The requested operation is not allowed now.',
      );

  final String from;
  final String to;
}

final class InvalidMutationIntentFailure extends DomainFailure {
  const InvalidMutationIntentFailure()
    : super(
        DomainFailureCode.invalidMutationIntent,
        'The mutation intent is not valid.',
      );
}

final class InvalidInstrumentEvidenceFailure extends DomainFailure {
  const InvalidInstrumentEvidenceFailure()
    : super(
        DomainFailureCode.invalidInstrumentEvidence,
        'The instrument evidence is not valid.',
      );
}

final class InvalidMappingRuleFailure extends DomainFailure {
  const InvalidMappingRuleFailure()
    : super(
        DomainFailureCode.invalidMappingRule,
        'The mapping rule is not valid.',
      );
}
