import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
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
  static const _labelsPath = '/v1/api/labels';

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
    // plan/05:187 — never log request or response bodies, not even at fine.
    _log.fine('Request body prepared: ${bodyJson.length} bytes');

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
      _log.warning('200 OK but no record id in the response envelope');
      return const WalletCreateAllSucceeded(recordId: 'unknown');
    }

    if (response.statusCode == 207) {
      // Partial success.
      _log.warning('207 Partial — per-item results returned');
      return WalletCreatePartial(
        items: [WalletItemSucceeded(recordId: 'partial')],
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      _log.severe('Auth error: status ${response.statusCode}');
      throw WalletApiDataSourceException(const AuthenticationRequired());
    }

    if (response.statusCode == 409) {
      _log.warning('Conflict: status ${response.statusCode}');
      throw WalletApiDataSourceException(const RetryableConflict());
    }

    if (response.statusCode == 429) {
      _log.warning('Rate limited: status ${response.statusCode}');
      throw WalletApiDataSourceException(const RateLimited());
    }

    // 4xx/5xx — transient by default.
    _log.severe('HTTP ${response.statusCode}');
    throw WalletApiDataSourceException(const RetryablePreTransmission());
  }

  @override
  Future<WalletRecordRead?> getRecord(String id) async {
    // M5.22 WP-N. There is no `/records/{id}` endpoint — the OpenAPI contract
    // exposes only the list route with an `id` filter, and that filter is
    // specifically documented to bypass the default date window. That matters
    // here: records are backdated to the SMS date, so a plain date-bounded
    // query would miss the very record we just created.
    if (id.isEmpty) return null;
    _log.info('GET $_recordsPath?id=… — read-back');
    try {
      final token = await _tokenGetter();
      final response = await _dio.get<Object?>(
        _recordsPath,
        queryParameters: <String, Object?>{'id': id, 'limit': 1},
        options: Options(
          headers: {'Authorization': 'Bearer ${token.toPersistenceString()}'},
        ),
      );
      if (response.statusCode != 200) {
        _log.error('Read-back failed: status ${response.statusCode}');
        return null;
      }
      final records = _asMap(response.data)?['records'];
      if (records is! List || records.isEmpty) {
        _log.error('Read-back found no record for the created id');
        return null;
      }
      return _decodeRecord(records.first);
    } on DioException catch (e) {
      _log.error('Read-back transport failure: SafeErrorCode: ${e.type.name}');
      return null;
    }
  }

  static Map<String, Object?>? _asMap(Object? data) {
    if (data is Map<String, Object?>) return data;
    if (data is Map) return data.cast<String, Object?>();
    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return decoded.cast<String, Object?>();
    }
    return null;
  }

  static WalletRecordRead? _decodeRecord(Object? value) {
    final map = _asMap(value);
    final id = map?['id'];
    if (id is! String || id.isEmpty) return null;
    final amount = _asMap(map?['amount']);
    final rawValue = amount?['value'];
    // The wire amount is a major-unit decimal; store minor units.
    final minor = switch (rawValue) {
      int v => v * 100,
      double v => (v * 100).round(),
      String v => ((double.tryParse(v) ?? 0) * 100).round(),
      _ => 0,
    };
    return WalletRecordRead(
      id: id,
      amountMinor: minor,
      currencyCode: (amount?['currencyCode'] as String?) ?? '',
      note: map?['note'] as String?,
      counterParty: map?['counterParty'] as String?,
      recordDateUtc: DateTime.tryParse(
        (map?['recordDate'] as String?) ?? '',
      )?.toUtc(),
    );
  }

  @override
  Future<List<WalletRecordRead>> findRecordForReconciliation(
    WalletReconciliationQuery query,
  ) async {
    // M5.22 WP-N/WP-E. Marker lookup is the go/no-go gate for writes
    // (plan/05:167): a create whose outcome is ambiguous is resolved by
    // finding its `[sw:…]` note marker, never by resending.
    final marker = query.marker;
    if (marker.isEmpty) return const [];
    _log.info('GET $_recordsPath?note=eq… — reconciliation by marker');
    try {
      final token = await _tokenGetter();
      final response = await _dio.get<Object?>(
        _recordsPath,
        queryParameters: <String, Object?>{
          'note': 'contains.$marker',
          if (query.accountId.isNotEmpty) 'accountId': query.accountId,
          'limit': 30,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${token.toPersistenceString()}'},
        ),
      );
      if (response.statusCode != 200) {
        _log.error('Reconciliation failed: status ${response.statusCode}');
        return const [];
      }
      final records = _asMap(response.data)?['records'];
      if (records is! List) return const [];
      final decoded = <WalletRecordRead>[];
      for (final record in records) {
        final value = _decodeRecord(record);
        if (value != null) decoded.add(value);
      }
      _log.info('Reconciliation matched ${decoded.length} record(s)');
      return decoded;
    } on DioException catch (e) {
      _log.error(
        'Reconciliation transport failure: SafeErrorCode: ${e.type.name}',
      );
      return const [];
    }
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

  @override
  Future<String?> ensureLabel(String name) async {
    // M5.22 WP-L: create the default `money_sync`/`test` labels on demand —
    // the owner's Wallet has neither, and auto-creation was explicitly
    // approved (this file already POSTs mutations, unlike the GET-only
    // wallet_catalog_reader boundary).
    _log.info('GET $_labelsPath?name=eq… — label lookup');
    try {
      final token = await _tokenGetter();
      final headers = {
        'Authorization': 'Bearer ${token.toPersistenceString()}',
        'Accept': 'application/json',
      };
      final lookup = await _dio.get<Object?>(
        _labelsPath,
        queryParameters: <String, Object?>{'name': 'eq.$name', 'limit': 1},
        options: Options(headers: headers),
      );
      if (lookup.statusCode == 200) {
        final labels = _asMap(lookup.data)?['labels'];
        if (labels is List && labels.isNotEmpty) {
          final id = _asMap(labels.first)?['id'];
          if (id is String && id.isNotEmpty) {
            _log.info('Label found: $name');
            return id;
          }
        }
      } else {
        _log.error('Label lookup failed: status ${lookup.statusCode}');
      }

      _log.info('POST $_labelsPath — creating label');
      final created = await _dio.post<Object?>(
        _labelsPath,
        data: {'name': name},
        options: Options(
          headers: {...headers, 'Content-Type': 'application/json'},
        ),
      );
      if (created.statusCode == 201) {
        final label = _asMap(created.data)?['label'];
        final id = _asMap(label)?['id'];
        if (id is String && id.isNotEmpty) {
          _log.info('Label created: $name');
          return id;
        }
      }
      _log.error('Label create failed: status ${created.statusCode}');
      return null;
    } on DioException catch (e) {
      _log.error('Label transport failure: SafeErrorCode: ${e.type.name}');
      return null;
    }
  }
}
