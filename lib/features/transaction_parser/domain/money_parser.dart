import 'package:money_sync/core/money/currency.dart';
import 'package:money_sync/core/money/money.dart';

final _lkr = Currency(code: 'LKR', decimalDigits: 2);

sealed class MoneyParseResult {
  const MoneyParseResult();
}

final class MoneyParsed extends MoneyParseResult {
  const MoneyParsed(this.value);
  final Money value;
}

final class MoneyParseFailed extends MoneyParseResult {
  const MoneyParseFailed(this.error);
  final MoneyParseError error;
}

enum MoneyParseError {
  noDigits,
  ambiguousSeparators,
  tooManyDecimalPlaces,
  overflow,
  unsupportedCurrency,
  zeroAmount,
}

MoneyParseResult parseMoney(String raw, {String currencyCode = 'LKR'}) {
  final stripped = raw.replaceFirst(RegExp(r'^[A-Z]{3}\s*'), '');
  var cleaned = stripped.replaceAll(',', '');
  final dotIndex = cleaned.indexOf('.');
  int? decimals;
  if (dotIndex >= 0) {
    decimals = cleaned.length - dotIndex - 1;
    cleaned = cleaned.replaceFirst('.', '');
  }
  final digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    return const MoneyParseFailed(MoneyParseError.noDigits);
  }
  if (decimals != null && decimals > 2) {
    return const MoneyParseFailed(MoneyParseError.tooManyDecimalPlaces);
  }
  final actualDecimals = decimals ?? 0;
  final padded = digitsOnly.padRight(
    digitsOnly.length + (2 - actualDecimals),
    '0',
  );
  final minorUnits = int.tryParse(padded);
  if (minorUnits == null) {
    return const MoneyParseFailed(MoneyParseError.overflow);
  }
  if (minorUnits == 0) {
    return const MoneyParseFailed(MoneyParseError.zeroAmount);
  }
  try {
    return MoneyParsed(Money(minorUnits: minorUnits, currency: _lkr));
  } on Exception {
    return const MoneyParseFailed(MoneyParseError.overflow);
  }
}
