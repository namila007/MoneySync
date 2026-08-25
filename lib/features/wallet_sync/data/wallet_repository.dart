import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

/// High-level Wallet create/reconcile boundary over a [WalletApiDataSource]
/// (plan/05; M5.6). Maps transport outcomes onto the domain port result space
/// so callers (M5.8/M5.9) never see raw HTTP.
final class WalletRepository {
  WalletRepository({
    required this._dataSource,
    this._failureMapper = const WalletMutationFailureMapper(),
  });

  final WalletApiDataSource _dataSource;
  final WalletMutationFailureMapper _failureMapper;

  /// Creates one Wallet record. Returns the domain port result — success
  /// carries the confirmed remote record id; ambiguity is surfaced as
  /// [WalletMutationPostTransmissionAmbiguity] for reconciliation.
  Future<WalletMutationResult> create(
    TransactionCandidateSnapshot payload,
  ) async {
    try {
      final outcome = await _dataSource.createRecord(payload);
      return switch (outcome) {
        WalletCreateAllSucceeded(:final recordId) =>
          WalletMutationRemoteSuccess(
            statusCode: 200,
            remoteRecordId: recordId,
          ),
        WalletCreatePartial(:final items) => _partialToResult(items),
      };
    } on WalletApiDataSourceException catch (exception) {
      return _failureMapper.toPortResult(exception.classification);
    }
  }

  Future<WalletRecordRead?> getRecord(String id) => _dataSource.getRecord(id);

  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) => _dataSource.findRecordForReconciliation(query);

  Future<WalletUsageStats> getUsageStats() => _dataSource.getUsageStats();

  Future<String?> ensureLabel(String name) => _dataSource.ensureLabel(name);

  WalletMutationResult _partialToResult(List<WalletItemResult> items) {
    final succeeded = items.whereType<WalletItemSucceeded>().toList();
    if (succeeded.length == 1) {
      return WalletMutationRemoteSuccess(
        statusCode: 207,
        remoteRecordId: succeeded.single.recordId,
      );
    }
    return const WalletMutationPreTransmissionFailure();
  }
}
