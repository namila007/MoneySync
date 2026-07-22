import 'package:money_sync/core/errors/domain_failure.dart';

/// ISO-style currency metadata used to interpret integer minor units.
final class Currency {
  Currency({required this.code, required this.decimalDigits}) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code) ||
        decimalDigits < 0 ||
        decimalDigits > 9) {
      throw const InvalidMoneyFailure();
    }
  }

  final String code;
  final int decimalDigits;

  Map<String, Object> toJson() => <String, Object>{
    'code': code,
    'decimalDigits': decimalDigits,
  };

  factory Currency.fromJson(Map<String, Object?> value) {
    final code = value['code'];
    final decimalDigits = value['decimalDigits'];
    if (code is! String || decimalDigits is! int) {
      throw const InvalidMoneyFailure();
    }
    return Currency(code: code, decimalDigits: decimalDigits);
  }

  @override
  bool operator ==(Object other) =>
      other is Currency &&
      other.code == code &&
      other.decimalDigits == decimalDigits;

  @override
  int get hashCode => Object.hash(code, decimalDigits);
}
