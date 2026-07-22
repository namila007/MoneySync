import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

/// An injected persistence boundary for validated parser output.
abstract interface class TransactionCandidateStore {
  Future<TransactionCandidate?> findBySourceMessageKey(String sourceMessageKey);

  Future<void> put(TransactionCandidate candidate);
}

/// An injected keyed-digest boundary; implementations own key material.
abstract interface class SourceMessageKeyGenerator {
  Future<String> generate({
    required String normalizedSender,
    required String normalizedBody,
    required DateTime receivedAtUtc,
    required int canonicalizationVersion,
  });
}
