import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';

/// M5.22 WP-M. Wallet derives recordType from the amount sign
/// (expense < 0 < income), so a debit sent positive is filed as INCOME.
///
/// Device evidence 2026-08-25: "LKR 4425.00 debited", displayed as
/// expense/debit, was POSTed as +442500 and returned recordType "income".
/// The existing serializer test passed because it hand-fed a negative amount;
/// the real parser yields an unsigned magnitude with direction alongside.
void main() {
  group('signedMinorUnits', () {
    test('a debit becomes negative', () {
      expect(signedMinorUnits(442500, TransactionDirection.debit), -442500);
    });

    test('a credit becomes positive', () {
      expect(signedMinorUnits(442500, TransactionDirection.credit), 442500);
    });

    test('an already-signed debit is not double-negated', () {
      expect(signedMinorUnits(-442500, TransactionDirection.debit), -442500);
    });

    test('an already-negative credit is corrected to positive', () {
      expect(signedMinorUnits(-442500, TransactionDirection.credit), 442500);
    });

    // plan/05:108: "income/credit and refund serialize as positive". A refund
    // can carry a debit direction, so direction alone would sign it wrong —
    // the same defect WP-M fixed for expenses, caught before it could ship.
    test('a refund is positive even when its direction is debit', () {
      expect(
        signedMinorUnits(
          442500,
          TransactionDirection.debit,
          kind: TransactionKind.refund,
        ),
        442500,
      );
    });

    test('a refund stays positive when already negative', () {
      expect(
        signedMinorUnits(
          -442500,
          TransactionDirection.debit,
          kind: TransactionKind.refund,
        ),
        442500,
      );
    });

    test('a non-refund kind does not override the direction', () {
      expect(
        signedMinorUnits(
          442500,
          TransactionDirection.debit,
          kind: TransactionKind.expense,
        ),
        -442500,
      );
    });

    test('neutral leaves the magnitude untouched', () {
      // Transfers are review-only; do not coerce a sign onto them.
      expect(signedMinorUnits(442500, TransactionDirection.neutral), 442500);
      expect(signedMinorUnits(-442500, TransactionDirection.neutral), -442500);
    });
  });

  test('an expense serializes to a negative wire amount', () {
    final body = const WalletRecordPayloadSerializer().serialize(
      TransactionCandidateSnapshot(
        accountId: 'account-1',
        amountMinor: signedMinorUnits(442500, TransactionDirection.debit),
        currencyCode: 'LKR',
        recordDateUtc: DateTime.utc(2026, 8, 13),
        paymentType: WalletPaymentType.debitCard,
        recordState: WalletRecordState.cleared,
      ),
    );
    expect(
      body.single['amount'],
      '-4425.00',
      reason: 'a positive amount would make Wallet file this as income',
    );
  });

  test('an income serializes to a positive wire amount', () {
    final body = const WalletRecordPayloadSerializer().serialize(
      TransactionCandidateSnapshot(
        accountId: 'account-1',
        amountMinor: signedMinorUnits(442500, TransactionDirection.credit),
        currencyCode: 'LKR',
        recordDateUtc: DateTime.utc(2026, 8, 13),
        paymentType: WalletPaymentType.debitCard,
        recordState: WalletRecordState.cleared,
      ),
    );
    expect(body.single['amount'], '4425.00');
  });
}
