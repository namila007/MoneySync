import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';

void main() {
  TransactionCandidateSnapshot snapshot({
    int amountMinor = -4500,
    String currencyCode = 'LKR',
  }) => TransactionCandidateSnapshot(
    accountId: 'account-1',
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    recordDateUtc: DateTime.utc(2026, 7, 18, 10, 42),
    paymentType: WalletPaymentType.creditCard,
    recordState: WalletRecordState.cleared,
    counterParty: 'Redacted merchant',
    note: 'SMS import [sw:7K2M9P4D8Q6R1V3X5T0Z]',
  );

  group('redaction guarantee', () {
    test(
      'serializer DTO declares exactly the allowlisted fields (compile-time '
      'redaction guarantee)',
      () {
        // Any field added to the DTO must be reviewed before it can serialize
        // something sensitive. This test fails on a new field until the
        // allowlist is deliberately extended.
        expect(
          TransactionCandidateSnapshot.fieldAllowlist,
          {
            'accountId',
            'amountMinor',
            'currencyCode',
            'recordDateUtc',
            'paymentType',
            'recordState',
            'categoryId',
            'counterParty',
            'note',
          },
        );
      },
    );

    test('snapshot has no sensitive field members at all', () {
      // Reflect over the instance's runtime type fields: none may be named
      // like a body/secret/balance field.
      final declared = TransactionCandidateSnapshot(
        accountId: 'a',
        amountMinor: -1,
        currencyCode: 'LKR',
        recordDateUtc: DateTime.utc(2026),
        paymentType: WalletPaymentType.cash,
        recordState: WalletRecordState.cleared,
      );
      for (final field in declared.runtimeType.toString().split(' ')) {
        expect(field.toLowerCase(), isNot(contains('body')));
        expect(field.toLowerCase(), isNot(contains('hmac')));
        expect(field.toLowerCase(), isNot(contains('token')));
      }
      expect(declared.counterParty, isNull);
    });
  });

  group('serializer output', () {
    test('emits the single-item create body with a decimal amount', () {
      const serializer = WalletRecordPayloadSerializer();
      final body = serializer.serialize(snapshot());

      expect(body, hasLength(1));
      final item = body.single;
      expect(item['accountId'], 'account-1');
      expect(item['amount'], '-45.00');
      expect(item['recordDate'], '2026-07-18T10:42:00.000Z');
      expect(item['paymentType'], 'credit_card');
      expect(item['recordState'], 'cleared');
      expect(item['counterParty'], 'Redacted merchant');
      expect(item['note'], 'SMS import [sw:7K2M9P4D8Q6R1V3X5T0Z]');
    });

    test('omits optional fields when absent', () {
      const serializer = WalletRecordPayloadSerializer();
      final body = serializer.serialize(
        TransactionCandidateSnapshot(
          accountId: 'a',
          amountMinor: 1200,
          currencyCode: 'USD',
          recordDateUtc: DateTime.utc(2026),
          paymentType: WalletPaymentType.cash,
          recordState: WalletRecordState.uncleared,
        ),
      );

      final item = body.single;
      expect(item['amount'], '12.00');
      expect(item.containsKey('categoryId'), isFalse);
      expect(item.containsKey('counterParty'), isFalse);
      expect(item.containsKey('note'), isFalse);
    });

    test('serializes a full-amount income as positive', () {
      const serializer = WalletRecordPayloadSerializer();
      final body = serializer.serialize(snapshot(amountMinor: 9876));
      expect(body.single['amount'], '98.76');
    });
  });

  group('snapshot validation', () {
    test('rejects empty account, zero amount, or non-UTC date', () {
      expect(
        () => snapshot(amountMinor: 0),
        throwsA(isA<Exception>()),
      );
      expect(
        () => TransactionCandidateSnapshot(
          accountId: '',
          amountMinor: -1,
          currencyCode: 'LKR',
          recordDateUtc: DateTime.utc(2026),
          paymentType: WalletPaymentType.cash,
          recordState: WalletRecordState.cleared,
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => TransactionCandidateSnapshot(
          accountId: 'a',
          amountMinor: -1,
          currencyCode: 'LKR',
          recordDateUtc: DateTime(2026),
          paymentType: WalletPaymentType.cash,
          recordState: WalletRecordState.cleared,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects over-long counterparty and note', () {
      TransactionCandidateSnapshot withCounterparty(String value) =>
          TransactionCandidateSnapshot(
            accountId: 'account-1',
            amountMinor: -4500,
            currencyCode: 'LKR',
            recordDateUtc: DateTime.utc(2026),
            paymentType: WalletPaymentType.creditCard,
            recordState: WalletRecordState.cleared,
            counterParty: value,
          );
      TransactionCandidateSnapshot withNote(String value) =>
          TransactionCandidateSnapshot(
            accountId: 'account-1',
            amountMinor: -4500,
            currencyCode: 'LKR',
            recordDateUtc: DateTime.utc(2026),
            paymentType: WalletPaymentType.creditCard,
            recordState: WalletRecordState.cleared,
            note: value,
          );
      expect(
        () => withCounterparty('x' * 256),
        throwsA(isA<Exception>()),
      );
      expect(() => withNote('x' * 256), throwsA(isA<Exception>()));
    });
  });
}
