import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

final _log = Logger('HttpWalletApi');

/// Real HTTP implementation of [WalletApiDataSource] that calls the BudgetBakers
/// REST API. Only used for TEST_ACCOUNT during M5.17+ development.
///
/// POST /v1/api/records — creates up to 20 records per request.
/// See: https://rest.budgetbakers.com/wallet/reference
final class HttpWalletApiDataSource implements WalletApiDataSource {
  HttpWalletApiDataSource({required Future<WalletToken> Function() tokenGetter})
    : _tokenGetter = tokenGetter,
      _dio = _createDio();

  final Future<WalletToken> Function() _tokenGetter;
  final Dio _dio;

  static const _baseUrl = 'https://rest.budgetbakers.com/wallet';
  static const _recordsPath = '/v1/api/records';

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        followRedirects: false,
        maxRedirects: 0,
        validateStatus: (_) => true,
      ),
    );
  }

  @override
  Future<WalletCreateOutcome> createRecord(
    TransactionCandidateSnapshot payload,
  ) async {
    final body = const WalletRecordPayloadSerializer().serialize(payload);
    final bodyJson = jsonEncode(body);

    _log.info(
      'POST $_recordsPath — '
      'account=${payload.accountId} amount=${payload.amountMinor} '
      '${payload.currencyCode} date=${payload.recordDateUtc.toIso8601String()} '
      'payment=${payload.paymentType.wireName} category=${payload.categoryId}',
    );
    _log.fine('Request body: $bodyJson');

    final token = await _tokenGetter();
    final response = await _dio.post(
      _recordsPath,
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${token.toPersistenceString()}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _log.info('Response: ${response.statusCode} ${response.statusMessage}');

    if (response.statusCode == 200) {
      // Success — response may contain the created record(s).
      final data = response.data;
      if (data is Map<String, Object?> && data.containsKey('id')) {
        final recordId = data['id'] as String;
        _log.info('Created record: $recordId');
        return WalletCreateAllSucceeded(recordId: recordId);
      }
      // BudgetBakers wraps results in {summary, results: [{record: {id}}]}.
      if (data is Map<String, Object?> && data.containsKey('results')) {
        final results = data['results'];
        if (results is List && results.isNotEmpty) {
          final first = results.first;
          if (first is Map<String, Object?> && first.containsKey('record')) {
            final record = first['record'];
            if (record is Map<String, Object?> && record.containsKey('id')) {
              final recordId = record['id'] as String;
              _log.info('Created record: $recordId');
              return WalletCreateAllSucceeded(recordId: recordId);
            }
          }
        }
      }
      // If response is a plain array, take the first record's id.
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, Object?> && first.containsKey('id')) {
          final recordId = first['id'] as String;
          _log.info('Created record: $recordId');
          return WalletCreateAllSucceeded(recordId: recordId);
        }
      }
      // No id in response — use a placeholder.
      _log.warning('200 OK but no record id in response: $data');
      return const WalletCreateAllSucceeded(recordId: 'unknown');
    }

    if (response.statusCode == 207) {
      // Partial success.
      _log.warning('207 Partial — ${response.data}');
      return WalletCreatePartial(
        items: [WalletItemSucceeded(recordId: 'partial')],
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      _log.severe('Auth error: ${response.statusCode} — ${response.data}');
      throw WalletApiDataSourceException(const AuthenticationRequired());
    }

    if (response.statusCode == 409) {
      _log.warning('Conflict: ${response.data}');
      throw WalletApiDataSourceException(const RetryableConflict());
    }

    if (response.statusCode == 429) {
      _log.warning('Rate limited: ${response.data}');
      throw WalletApiDataSourceException(const RateLimited());
    }

    // 4xx/5xx — transient by default.
    _log.severe('HTTP ${response.statusCode}: ${response.data}');
    throw WalletApiDataSourceException(const RetryablePreTransmission());
  }

  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    _log.info('GET /v1/api/records/$id');
    // TODO: implement when needed for reconciliation.
    return null;
  }

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async {
    _log.info('GET /v1/api/records — reconciliation query');
    // TODO: implement when needed for reconciliation.
    return [];
  }

  @override
  Future<WalletUsageStats> getUsageStats() async {
    _log.info('GET /v1/api/api-usage/stats');
    final token = await _tokenGetter();
    final response = await _dio.get(
      '/v1/api/api-usage/stats',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${token.toPersistenceString()}',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200 && response.data is Map<String, Object?>) {
      final data = response.data as Map<String, Object?>;
      return WalletUsageStats(
        recordCount: data['recordCount'] as int? ?? 0,
        requestCount: data['requestCount'] as int? ?? 0,
        rateLimitRemaining: data['rateLimitRemaining'] as int?,
      );
    }
    return const WalletUsageStats(
      recordCount: 0,
      requestCount: 0,
      rateLimitRemaining: null,
    );
  }
}
