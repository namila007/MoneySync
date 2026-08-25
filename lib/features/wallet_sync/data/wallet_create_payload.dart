import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

/// Applies the Wallet sign convention to an unsigned amount magnitude.
///
/// **M5.22 WP-M.** Wallet derives `recordType` from the amount sign — expense
/// < 0 < income — so a debit sent as a positive number is filed as *income*.
/// The parser yields an unsigned magnitude and keeps direction in a separate
/// field (the project rule: direction is preserved separately from kind), so
/// the sign has to be applied at the point the wire payload is built.
///
/// Device evidence 2026-08-25: an SMS reading "LKR 4425.00 debited", shown in
/// the UI as expense/debit, was POSTed as `+442500` and came back from Wallet
/// as `recordType: "income"`. Every expense was being recorded sign-inverted.
///
/// [TransactionDirection.neutral] keeps the magnitude unchanged: transfers and
/// other neutral flows are review-only and must not be coerced either way.
/// [kind] overrides the direction for refunds. plan/05:108 is explicit that
/// "income/credit and refund serialize as positive", and a refund can carry a
/// debit direction — so signing on direction alone would record a refund with
/// the wrong sign, the same class of defect WP-M fixed for expenses.
///
/// Refunds are review-only today and cannot reach a create, so this is a
/// guard placed ahead of the policy change rather than a live fix.
int signedMinorUnits(
  int amountMinor,
  TransactionDirection direction, {
  TransactionKind? kind,
}) {
  if (kind == TransactionKind.refund) return amountMinor.abs();
  return switch (direction) {
    TransactionDirection.debit => -amountMinor.abs(),
    TransactionDirection.credit => amountMinor.abs(),
    TransactionDirection.neutral => amountMinor,
  };
}

/// Wire form of the Wallet `paymentType` enum (plan/05 §Create-record contract).
enum WalletPaymentType {
  cash('cash'),
  debitCard('debit_card'),
  creditCard('credit_card'),
  transfer('transfer'),
  voucher('voucher'),
  mobilePayment('mobile_payment'),
  webPayment('web_payment');

  const WalletPaymentType(this.wireName);
  final String wireName;
}

/// Wire form of the Wallet `recordState` enum (plan/05 §Create-record contract).
enum WalletRecordState {
  cleared('cleared'),
  reconciled('reconciled'),
  uncleared('uncleared');

  const WalletRecordState(this.wireName);
  final String wireName;
}

/// The narrow, structurally-safe input for a Wallet create request (M5.6).
///
/// **Redaction guarantee is structural, not a runtime check:** the DTO's
/// constructor only accepts the fields below, so it is impossible to pass
/// `bodyRedacted`, `body_ciphertext`, `availableBalanceMinor`, a full
/// instrument suffix, or HMAC key material — those fields do not exist on this
/// type. A compile-time allowlist test enumerates the declared fields so any
/// future field added here fails the test until it is deliberately reviewed.
final class TransactionCandidateSnapshot {
  TransactionCandidateSnapshot({
    required this.accountId,
    required this.amountMinor,
    required this.currencyCode,
    required this.recordDateUtc,
    required this.paymentType,
    required this.recordState,
    this.categoryId,
    this.counterParty,
    this.note,
    this.labelIds = const [],
  }) {
    if (accountId.isEmpty ||
        currencyCode.isEmpty ||
        amountMinor == 0 ||
        !recordDateUtc.isUtc) {
      throw const InvalidMutationIntentFailure();
    }
    if (counterParty != null && counterParty!.length > 255) {
      throw const InvalidMutationIntentFailure();
    }
    if (note != null && note!.length > 255) {
      throw const InvalidMutationIntentFailure();
    }
  }

  final String accountId;
  final int amountMinor;
  final String currencyCode;
  final DateTime recordDateUtc;
  final WalletPaymentType paymentType;
  final WalletRecordState recordState;
  final String? categoryId;
  final String? counterParty;
  final String? note;
  final List<String> labelIds;

  static const fieldAllowlist = <String>{
    'accountId',
    'amountMinor',
    'currencyCode',
    'recordDateUtc',
    'paymentType',
    'recordState',
    'categoryId',
    'counterParty',
    'note',
    'labelIds',
  };
}

/// Serializes a [TransactionCandidateSnapshot] into the Wallet create-record
/// request body shape (plan/05 §Create-record contract). Amount is emitted as
/// a decimal string in minor units — never a double.
final class WalletRecordPayloadSerializer {
  const WalletRecordPayloadSerializer();

  /// Returns the single-item array body accepted by `POST /records`.
  List<Map<String, Object?>> serialize(TransactionCandidateSnapshot snapshot) {
    final item = <String, Object?>{
      'accountId': snapshot.accountId,
      'amount': _formatAmount(snapshot.amountMinor),
      'recordDate': snapshot.recordDateUtc.toIso8601String(),
      'paymentType': snapshot.paymentType.wireName,
      'recordState': snapshot.recordState.wireName,
      if (snapshot.categoryId != null) 'categoryId': snapshot.categoryId,
      if (snapshot.counterParty != null) 'counterParty': snapshot.counterParty,
      if (snapshot.note != null) 'note': snapshot.note,
      if (snapshot.labelIds.isNotEmpty) 'labelIds': snapshot.labelIds,
    };
    return [item];
  }

  /// Integer minor units to a fixed-scale decimal string. Expenses are
  /// negative (plan/05 §Create-record contract).
  String _formatAmount(int minorUnits) {
    final sign = minorUnits < 0 ? '-' : '';
    final absolute = minorUnits.abs();
    final whole = absolute ~/ 100;
    final fraction = absolute % 100;
    return '$sign$whole.${fraction.toString().padLeft(2, '0')}';
  }
}
