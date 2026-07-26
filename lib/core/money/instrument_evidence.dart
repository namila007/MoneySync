import 'package:money_sync/core/errors/domain_failure.dart';

final class InstrumentEvidence {
  InstrumentEvidence({
    this.safeSuffix,
    this.availableBalanceMinorUnits,
    this.availableBalanceCurrencyCode,
  }) {
    if (safeSuffix != null && !_isValidSafeSuffix(safeSuffix!)) {
      throw const InvalidInstrumentEvidenceFailure();
    }
  }

  static const _maxSuffixLength = 4;
  static final _suffixPattern = RegExp(r'^\d+$');

  final String? safeSuffix;
  final int? availableBalanceMinorUnits;
  final String? availableBalanceCurrencyCode;

  bool get hasSuffix => safeSuffix != null;
  bool get hasAvailableBalance => availableBalanceMinorUnits != null;

  static bool _isValidSafeSuffix(String value) =>
      value.isNotEmpty &&
      value.length <= _maxSuffixLength &&
      _suffixPattern.hasMatch(value);

  @override
  bool operator ==(Object other) =>
      other is InstrumentEvidence &&
      other.safeSuffix == safeSuffix &&
      other.availableBalanceMinorUnits == availableBalanceMinorUnits &&
      other.availableBalanceCurrencyCode == availableBalanceCurrencyCode;

  @override
  int get hashCode => Object.hash(
    safeSuffix,
    availableBalanceMinorUnits,
    availableBalanceCurrencyCode,
  );

  @override
  String toString() => safeSuffix != null
      ? 'InstrumentEvidence(suffix=***${safeSuffix!.substring(safeSuffix!.length > 2 ? safeSuffix!.length - 2 : 0)})'
      : 'InstrumentEvidence(no_suffix)';
}
