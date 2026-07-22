import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/money/currency.dart';
import 'package:money_sync/core/money/money.dart';

void main() {
  group('Currency', () {
    test('validates uppercase ISO code and supported scale', () {
      expect(Currency(code: 'LKR', decimalDigits: 2).code, 'LKR');
      expect(
        () => Currency(code: 'lkr', decimalDigits: 2),
        throwsA(isA<InvalidMoneyFailure>()),
      );
      expect(
        () => Currency(code: 'LKR', decimalDigits: 10),
        throwsA(isA<InvalidMoneyFailure>()),
      );
    });
  });

  group('Money', () {
    final lkr = Currency(code: 'LKR', decimalDigits: 2);
    final usd = Currency(code: 'USD', decimalDigits: 2);

    test('stores signed integer minor units without a floating-point API', () {
      final debit = Money(minorUnits: -123450, currency: lkr);
      final credit = Money(minorUnits: 123450, currency: lkr);

      expect(debit.minorUnits, -123450);
      expect(debit.isDebit, isTrue);
      expect(credit.isCredit, isTrue);
      expect(debit.toDecimalString(), '-1234.50');
      expect(credit.toDecimalString(), '1234.50');
    });

    test('parses exact grouped decimal text at the currency scale', () {
      final parsed = Money.parse(decimal: '1,234.50', currency: lkr);

      expect(parsed, Money(minorUnits: 123450, currency: lkr));
      expect(Money.parse(decimal: '-.75', currency: usd).minorUnits, -75);
      expect(Money.parse(decimal: '100', currency: lkr).minorUnits, 10000);
    });

    test('rejects malformed, over-scaled, and overflowing decimal text', () {
      expect(
        () => Money.parse(decimal: '12.345', currency: lkr),
        throwsA(isA<InvalidMoneyFailure>()),
      );
      expect(
        () => Money.parse(decimal: '12,34.50', currency: lkr),
        throwsA(isA<InvalidMoneyFailure>()),
      );
      expect(
        () => Money.parse(decimal: '92233720368547758.08', currency: lkr),
        throwsA(isA<InvalidMoneyFailure>()),
      );
    });

    test('requires a matching currency for arithmetic and comparison', () {
      final first = Money(minorUnits: 40, currency: lkr);
      final second = Money(minorUnits: 2, currency: lkr);

      expect(first + second, Money(minorUnits: 42, currency: lkr));
      expect(first.compareTo(second), greaterThan(0));
      expect(
        () => first + Money(minorUnits: 1, currency: usd),
        throwsA(isA<CurrencyMismatchFailure>()),
      );
    });

    test('serializes and restores the exact signed representation', () {
      final original = Money(minorUnits: -1, currency: lkr);

      expect(Money.fromJson(original.toJson()), original);
      expect(
        () => Money.fromJson(<String, Object?>{
          'minorUnits': 1.5,
          'currency': <String, Object?>{'code': 'LKR', 'decimalDigits': 2},
        }),
        throwsA(isA<InvalidMoneyFailure>()),
      );
    });

    test('rejects a malformed nested currency map as a domain failure', () {
      expect(
        () => Money.fromJson(<String, Object?>{
          'minorUnits': 1,
          'currency': <Object?, Object?>{7: 'not-a-json-key'},
        }),
        throwsA(isA<InvalidMoneyFailure>()),
      );
    });
  });
}
