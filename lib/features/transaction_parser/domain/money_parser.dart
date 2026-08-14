import 'package:money_sync/core/money/currency.dart';
import 'package:money_sync/core/money/money.dart';

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

/// M4.6 rules 2–3: reject rather than guess when separators conflict —
/// a comma after a dot (`1.234,56`, European convention) or a trailing
/// two-digit comma group with no dot (`1,50`).
bool _hasAmbiguousSeparators(String amountToken) {
  final commaIndex = amountToken.indexOf(',');
  if (commaIndex < 0) return false;
  final dotIndex = amountToken.indexOf('.');
  if (dotIndex >= 0 && commaIndex > dotIndex) return true;
  if (dotIndex < 0 &&
      RegExp(r'^\d{2}$').hasMatch(amountToken.substring(commaIndex + 1))) {
    return true;
  }
  return false;
}

/// Parses an amount token into integer minor units. The currency comes from
/// the text itself (leading `[A-Z]{3}`), with [currencyCode] as a caller-
/// supplied fallback when a pack knows the currency without the message
/// stating it. There is deliberately no market default: a bare amount with no
/// currency is uninterpretable (M4.14 bank-agnosticism).
MoneyParseResult parseMoney(String raw, {String? currencyCode}) {
  final trimmed = raw.trim();
  final codeMatch = RegExp(r'^([A-Z]{3})\s*').firstMatch(trimmed);
  final code = codeMatch?.group(1) ?? currencyCode;
  if (code == null) {
    return const MoneyParseFailed(MoneyParseError.unsupportedCurrency);
  }
  final stripped = trimmed.replaceFirst(RegExp(r'^[A-Z]{3}\s*'), '');
  if (_hasAmbiguousSeparators(stripped)) {
    return const MoneyParseFailed(MoneyParseError.ambiguousSeparators);
  }
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
    return MoneyParsed(
      Money(
        minorUnits: minorUnits,
        currency: Currency(code: code, decimalDigits: 2),
      ),
    );
  } on Exception {
    return const MoneyParseFailed(MoneyParseError.overflow);
  }
}
