import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/money/currency.dart';

/// An exact, signed financial amount represented in currency minor units.
///
/// Values are deliberately restricted to signed 64-bit bounds so they remain
/// safe to persist across SQLite, Kotlin, and Dart boundaries.
final class Money implements Comparable<Money> {
  Money({required this.minorUnits, required this.currency}) {
    if (!_isInSigned64BitRange(minorUnits)) {
      throw const InvalidMoneyFailure();
    }
  }

  static const int _maxMinorUnits = 9223372036854775807;
  static const int _minMinorUnits = -9223372036854775808;

  final int minorUnits;
  final Currency currency;

  bool get isDebit => minorUnits < 0;
  bool get isCredit => minorUnits > 0;
  bool get isZero => minorUnits == 0;

  factory Money.parse({required String decimal, required Currency currency}) {
    final match = RegExp(r'^([+-]?)(.*)$').firstMatch(decimal);
    if (match == null) throw const InvalidMoneyFailure();

    final sign = match.group(1)!;
    final body = match.group(2)!;
    final parts = body.split('.');
    if (parts.length > 2) throw const InvalidMoneyFailure();

    final whole = parts.first;
    final fraction = parts.length == 2 ? parts.last : '';
    final hasDigits = whole.isNotEmpty || fraction.isNotEmpty;
    if (!hasDigits || !_isValidWholePart(whole) || !_isDigits(fraction)) {
      throw const InvalidMoneyFailure();
    }
    if (fraction.length > currency.decimalDigits) {
      throw const InvalidMoneyFailure();
    }

    final normalizedWhole = whole.replaceAll(',', '');
    final normalizedFraction = fraction.padRight(currency.decimalDigits, '0');
    final digits =
        '${normalizedWhole.isEmpty ? '0' : normalizedWhole}'
        '$normalizedFraction';
    final parsed = int.tryParse(digits);
    if (parsed == null) throw const InvalidMoneyFailure();
    final signed = sign == '-' ? -parsed : parsed;
    if (!_isInSigned64BitRange(signed)) throw const InvalidMoneyFailure();
    return Money(minorUnits: signed, currency: currency);
  }

  factory Money.fromJson(Map<String, Object?> value) {
    final minorUnits = value['minorUnits'];
    final currencyValue = value['currency'];
    if (minorUnits is! int ||
        currencyValue is! Map ||
        !currencyValue.keys.every((key) => key is String)) {
      throw const InvalidMoneyFailure();
    }
    final typedCurrency = Map<String, Object?>.from(currencyValue);
    return Money(
      minorUnits: minorUnits,
      currency: Currency.fromJson(typedCurrency),
    );
  }

  Money operator +(Money other) {
    _requireSameCurrency(other);
    final result = minorUnits + other.minorUnits;
    if (!_isInSigned64BitRange(result)) throw const InvalidMoneyFailure();
    return Money(minorUnits: result, currency: currency);
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    final result = minorUnits - other.minorUnits;
    if (!_isInSigned64BitRange(result)) throw const InvalidMoneyFailure();
    return Money(minorUnits: result, currency: currency);
  }

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  String toDecimalString() {
    final absolute = minorUnits.abs().toString().padLeft(
      currency.decimalDigits + 1,
      '0',
    );
    final wholeEnd = absolute.length - currency.decimalDigits;
    final whole = currency.decimalDigits == 0
        ? absolute
        : absolute.substring(0, wholeEnd);
    final fraction = currency.decimalDigits == 0
        ? ''
        : '.${absolute.substring(wholeEnd)}';
    return '${minorUnits < 0 ? '-' : ''}$whole$fraction';
  }

  Map<String, Object> toJson() => <String, Object>{
    'minorUnits': minorUnits,
    'currency': currency.toJson(),
  };

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) throw const CurrencyMismatchFailure();
  }

  static bool _isValidWholePart(String value) =>
      value.isEmpty ||
      _isDigits(value) ||
      RegExp(r'^\d{1,3}(?:,\d{3})+$').hasMatch(value);

  static bool _isDigits(String value) => RegExp(r'^\d*$').hasMatch(value);

  static bool _isInSigned64BitRange(int value) =>
      value >= _minMinorUnits && value <= _maxMinorUnits;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);
}
