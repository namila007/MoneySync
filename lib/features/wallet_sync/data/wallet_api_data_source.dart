import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';

/// A remote read of one Wallet record, used for read-back and reconciliation.
final class WalletRecordRead {
  const WalletRecordRead({
    required this.id,
    required this.amountMinor,
    required this.currencyCode,
    this.counterParty,
    this.note,
    this.recordDateUtc,
  });

  final String id;
  final int amountMinor;
  final String currencyCode;
  final String? counterParty;
  final String? note;
  final DateTime? recordDateUtc;
}

/// Sanitized usage stats for the connection surface (plan/05 §Usage).
final class WalletUsageStats {
  const WalletUsageStats({
    required this.recordCount,
    required this.requestCount,
    required this.rateLimitRemaining,
  });

  final int recordCount;
  final int requestCount;
  final int? rateLimitRemaining;
}

/// Lookup criteria for reconciliation by the note source marker plus narrow
/// date/account/amount evidence (plan/05 §Idempotency and reconciliation).
final class WalletReconciliationQuery {
  const WalletReconciliationQuery({
    required this.marker,
    required this.accountId,
    required this.amountMinor,
    this.recordDateUtc,
  });

  final String marker;
  final String accountId;
  final int amountMinor;
  final DateTime? recordDateUtc;
}

/// The Wallet create/read/reconcile network boundary (plan/05; M5.6). Built
/// and tested entirely against fakes — no live network calls in this slice.
abstract interface class WalletApiDataSource {
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  );

  Future<WalletRecordRead?> getRecord(String id);

  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  );

  Future<WalletUsageStats> getUsageStats();

  /// Resolves the id of the label named [name], creating it in Wallet if it
  /// does not already exist (M5.22 WP-L). Returns null if the label could
  /// not be resolved or created — callers must not block a create on this.
  Future<String?> ensureLabel(String name);
}

/// Raised by data-source implementations on transport failure. Carries only
/// the classification — no bodies, tokens, or sensitive fields.
final class WalletApiDataSourceException implements Exception {
  const WalletApiDataSourceException(this.classification);

  final WalletMutationFailureClassification classification;

  @override
  String toString() =>
      'WalletApiDataSourceException(${classification.runtimeType})';
}
