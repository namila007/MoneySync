import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
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
    final log = Logger('wallet.fake');
    log.info(
      '[FakeAPI] createRecord #$createCalls: '
      'account=${payload.accountId} amount=${payload.amountMinor} '
      '${payload.currencyCode} date=${payload.recordDateUtc} '
      'payment=${payload.paymentType.wireName} category=${payload.categoryId}',
    );
    if (_error case final error?) {
      log.error('[FakeAPI] ERROR: $error', error);
      throw error;
    }
    final outcome =
        _createOutcome ?? const WalletCreateAllSucceeded(recordId: 'record-1');
    log.info(
      '[FakeAPI] → ${outcome.runtimeType} recordId=${outcome is WalletCreateAllSucceeded ? outcome.recordId : "partial"}',
    );
    // M5.22 WP-N: remember what was created so a read-back can find it. A
    // fake that reports "created" and then "no such record" does not model
    // the API, and would make every caller look like an unverified create.
    if (outcome is WalletCreateAllSucceeded) {
      _created[outcome.recordId] = WalletRecordRead(
        id: outcome.recordId,
        amountMinor: payload.amountMinor,
        currencyCode: payload.currencyCode,
        note: payload.note,
        counterParty: payload.counterParty,
        recordDateUtc: payload.recordDateUtc,
      );
    }
    return outcome;
  }

  /// Records this fake has "created", keyed by id.
  final Map<String, WalletRecordRead> _created = {};

  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    getRecordCalls++;
    // An explicitly injected record wins, so a test can still model the
    // record-missing case.
    return _record ?? _created[id];
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

  /// Name -> id, mirroring the real API's find-or-create (M5.22 WP-L).
  final Map<String, String> _labels = {};
  int ensureLabelCalls = 0;

  @override
  Future<String?> ensureLabel(String name) async {
    ensureLabelCalls++;
    return _labels.putIfAbsent(name, () => 'label-${_labels.length + 1}');
  }
}
