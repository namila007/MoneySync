import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/transaction_parser/domain/money_parser.dart';

void main() {
  group('parseMoney separator handling (M4.6 rules 2-3)', () {
    test('rejects European convention 1.234,56 as ambiguousSeparators', () {
      final result = parseMoney('LKR 1.234,56');
      expect(
        result,
        const MoneyParseFailed(MoneyParseError.ambiguousSeparators),
      );
    });

    test(
      'rejects trailing two-digit comma group 1,50 as ambiguousSeparators',
      () {
        final result = parseMoney('LKR 1,50');
        expect(
          result,
          const MoneyParseFailed(MoneyParseError.ambiguousSeparators),
        );
      },
    );

    test('accepts thousands separators 1,234.56', () {
      final result = parseMoney('LKR 1,234.56');
      expect(result, isA<MoneyParsed>());
      expect((result as MoneyParsed).value.minorUnits, 123456);
    });

    test('accepts a comma with three trailing digits as thousands', () {
      final result = parseMoney('LKR 1,234');
      expect(result, isA<MoneyParsed>());
      expect((result as MoneyParsed).value.minorUnits, 123400);
    });
  });
}
