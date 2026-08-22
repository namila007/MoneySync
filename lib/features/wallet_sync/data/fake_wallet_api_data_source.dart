import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// Deterministic fake for [WalletApiDataSource].
///
/// This is the **production M5 posture**: the live create-contract spike
/// (M5.7) has not closed, so the shipped app wires this fake instead of real
/// network. All M5.6–M5.12 flows build and test against it. Swap for the live
/// implementation when M5.7 closes behind a feature flag.
final class FakeWalletApiDataSource implements WalletApiDataSource {
  FakeWalletApiDataSource({
    this._createOutcome,
    this._record,
    this._reconciliationResults = const [],
    this._usageStats,
    this._error,
  });

  final WalletCreateOutcome? _createOutcome;
  final WalletRecordRead? _record;
  final List<WalletRecordRead> _reconciliationResults;
  final WalletUsageStats? _usageStats;
  final WalletApiDataSourceException? _error;

  int createCalls = 0;
  int getRecordCalls = 0;
  int reconciliationCalls = 0;
  int usageStatsCalls = 0;
  TransactionCandidateSnapshot? lastCreatePayload;

  /// Seeds the "connected" catalog the fake serves back, so E2E flows can
  /// model a connected Wallet without a live API (M5.13).
  void writeCatalog(WalletCatalog catalog) {
    _accountIds = {for (final account in catalog.accounts) account.id};
  }

  Set<String> _accountIds = const {};
  bool get isConnected => _accountIds.isNotEmpty;

  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async {
    createCalls++;
    lastCreatePayload = payload;
    if (_error case final error?) throw error;
    return _createOutcome ??
        const WalletCreateAllSucceeded(recordId: 'record-1');
  }

  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    getRecordCalls++;
    return _record;
  }

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async {
    reconciliationCalls++;
    return _reconciliationResults;
  }

  @override
  Future<WalletUsageStats> getUsageStats() async {
    usageStatsCalls++;
    return _usageStats ??
        const WalletUsageStats(
          recordCount: 0,
          requestCount: 0,
          rateLimitRemaining: null,
        );
  }
}
