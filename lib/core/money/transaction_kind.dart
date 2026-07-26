enum TransactionKind {
  expense,
  income,
  refund,
  transfer,
  authorization,
  settlement,
  reversal,
  nonTransaction,
  unknown,
}

enum TransactionDirection { debit, credit }

enum TransactionLifecycle { pending, authorized, settled, reversed, refunded }

final class TransactionKindClassifier {
  const TransactionKindClassifier();

  TransactionDirection directionFor(TransactionKind kind) => switch (kind) {
    TransactionKind.expense ||
    TransactionKind.refund ||
    TransactionKind.transfer ||
    TransactionKind.authorization ||
    TransactionKind.settlement => TransactionDirection.debit,
    TransactionKind.income ||
    TransactionKind.reversal => TransactionDirection.credit,
    TransactionKind.nonTransaction ||
    TransactionKind.unknown => TransactionDirection.debit,
  };

  bool isFinancial(TransactionKind kind) => switch (kind) {
    TransactionKind.nonTransaction || TransactionKind.unknown => false,
    _ => true,
  };

  bool mayCreateWalletRecord(TransactionKind kind) => switch (kind) {
    TransactionKind.expense ||
    TransactionKind.income ||
    TransactionKind.refund ||
    TransactionKind.transfer => true,
    TransactionKind.authorization ||
    TransactionKind.settlement ||
    TransactionKind.reversal ||
    TransactionKind.nonTransaction ||
    TransactionKind.unknown => false,
  };
}
