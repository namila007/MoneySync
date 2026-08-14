/// Per-item result of a Wallet create batch (plan/05 §Batching, HTTP 207).
/// One outbox item is sent per request in MVP; the model still understands
/// multi-item batches so 207 is handled safely before batching is enabled.
sealed class WalletItemResult {
  const WalletItemResult();
}

final class WalletItemSucceeded extends WalletItemResult {
  WalletItemSucceeded({required this.recordId}) {
    if (recordId.isEmpty) {
      throw ArgumentError.value(recordId, 'recordId', 'must not be empty');
    }
  }

  final String recordId;
}

final class WalletItemFailed extends WalletItemResult {
  const WalletItemFailed({required this.safeErrorCode});

  final String safeErrorCode;
}

/// Outcome of a `POST /records` call.
sealed class WalletCreateOutcome {
  const WalletCreateOutcome();
}

/// HTTP 200: every item succeeded. MVP sends one item, so one [recordId].
final class WalletCreateAllSucceeded extends WalletCreateOutcome {
  const WalletCreateAllSucceeded({required this.recordId});

  final String recordId;
}

/// HTTP 207 Multi-Status: per-item outcomes, never a blanket success.
final class WalletCreatePartial extends WalletCreateOutcome {
  WalletCreatePartial({required List<WalletItemResult> items})
    : items = List.unmodifiable(items);

  final List<WalletItemResult> items;
}
