import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/data/wallet_catalog_reader.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

void main() {
  WalletCatalogReader reader(HttpClientAdapter adapter) =>
      WalletCatalogReader.forTesting(adapter: adapter);

  test(
    'uses fixed GET catalog paths and injects bearer only on the audited wire',
    () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'accounts': [_accountJson],
          'nextOffset': null,
        }),
        _json(200, {
          'categories': [_categoryJson],
          'nextOffset': null,
        }),
      ]);

      final result = await reader(
        adapter,
      ).readCatalog(WalletToken.parse('synthetic-token'));

      expect(result, isA<WalletReadSuccess>());
      final success = result as WalletReadSuccess;
      // M5.2: OpenAPI v1.3.0 exposes no writable flag, so the reader stays
      // fail-closed until the live eligibility spike supplies evidence.
      // Eligibility-gate tests use FakeWritableWalletCatalogCache instead.
      expect(success.catalog.accounts.single.isWritable, isFalse);
      expect(
        success.catalog.accounts.single.eligibility,
        WalletAccountEligibility.unwritable,
      );
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.map((request) => request.method),
        everyElement('GET'),
      );
      expect(
        adapter.requests.map((request) => request.uri.toString()),
        containsAll(<String>[
          'https://rest.budgetbakers.com/wallet/v1/api/accounts?limit=100',
          'https://rest.budgetbakers.com/wallet/v1/api/categories?limit=100',
        ]),
      );
      expect(
        adapter.requests.every(
          (request) =>
              request.headers['authorization'] == 'Bearer synthetic-token',
        ),
        isTrue,
      );
      expect(result.toString(), isNot(contains('synthetic-token')));
    },
  );

  test(
    'fails closed for malformed collections, offsets, and account fields',
    () async {
      final malformedResponses = <ResponseBody>[
        _json(200, {'accounts': 'not-a-list'}),
        _json(200, {'accounts': List.filled(101, _accountJson)}),
        _json(200, {
          'accounts': [_accountJson],
          'nextOffset': 'one',
        }),
        _json(200, {
          'accounts': [_accountJson],
          'nextOffset': -1,
        }),
        _json(200, {
          'accounts': [
            {
              'id': 'one',
              'name': 'One',
              'archived': false,
              'isBankSync': false,
            },
          ],
        }),
      ];
      for (final response in malformedResponses) {
        final result = await reader(
          _QueueAdapter([response]),
        ).readCatalog(WalletToken.parse('synthetic-token'));
        expect(result, const WalletReadFailure.protocol());
      }
      final invalidCategory = await reader(
        _QueueAdapter([
          _json(200, {
            'accounts': [_accountJson],
          }),
          _json(200, {
            'categories': [
              {'id': '', 'name': 'Food'},
            ],
          }),
        ]),
      ).readCatalog(WalletToken.parse('synthetic-token'));
      expect(invalidCategory, const WalletReadFailure.protocol());
    },
  );

  test(
    'maps service and transport failures without exposing transport details',
    () async {
      final transportCases = <({Object error, WalletReadFailure expected})>[
        (
          error: DioException(
            requestOptions: RequestOptions(path: '/v1/api/accounts'),
            type: DioExceptionType.connectionTimeout,
          ),
          expected: const WalletReadFailure.timeout(),
        ),
        (
          error: DioException(
            requestOptions: RequestOptions(path: '/v1/api/accounts'),
            type: DioExceptionType.badCertificate,
          ),
          expected: const WalletReadFailure.tls(),
        ),
        (
          error: DioException(
            requestOptions: RequestOptions(path: '/v1/api/accounts'),
            type: DioExceptionType.connectionError,
          ),
          expected: const WalletReadFailure.offline(),
        ),
      ];
      for (final entry in transportCases) {
        final result = await reader(
          _ThrowingAdapter(entry.error),
        ).readCatalog(WalletToken.parse('synthetic-token'));
        expect(result, entry.expected);
      }
      final service = await reader(
        _QueueAdapter([
          _json(503, {'untrusted': 'detail'}),
        ]),
      ).readCatalog(WalletToken.parse('synthetic-token'));
      final unsupportedConflict = await reader(
        _QueueAdapter([
          _json(409, {'error': 'other'}),
        ]),
      ).readCatalog(WalletToken.parse('synthetic-token'));
      expect(service, const WalletReadFailure.service());
      expect(unsupportedConflict, const WalletReadFailure.protocol());
    },
  );

  test(
    'does not follow an alternate origin redirect or send it a bearer',
    () async {
      final adapter = _QueueAdapter([
        _json(
          302,
          {},
          headers: {
            'location': ['https://alternate.example/catalog'],
          },
        ),
      ]);

      final result = await reader(
        adapter,
      ).readCatalog(WalletToken.parse('synthetic-token'));

      expect(result, const WalletReadFailure.protocol());
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.uri.host, 'rest.budgetbakers.com');
      expect(
        adapter.requests.single.headers['authorization'],
        'Bearer synthetic-token',
      );
    },
  );

  test(
    'maps initial sync, rate limit, malformed JSON, and auth safely',
    () async {
      final cases = <({ResponseBody response, WalletReadFailure expected})>[
        (
          response: _json(409, {'error': 'init_sync_in_progress'}),
          expected: const WalletReadFailure.initialSyncInProgress(),
        ),
        (
          response: _json(
            429,
            {},
            headers: {
              'retry-after': ['60'],
            },
          ),
          expected: const WalletReadFailure.rateLimited(retryAfterSeconds: 60),
        ),
        (
          response: _json(401, {'error': 'raw_secret_detail'}),
          expected: const WalletReadFailure.invalidToken(),
        ),
        (
          response: _jsonText(200, '{malformed'),
          expected: const WalletReadFailure.protocol(),
        ),
      ];
      for (final entry in cases) {
        final result = await reader(
          _QueueAdapter([entry.response]),
        ).readCatalog(WalletToken.parse('synthetic-token'));
        expect(result, entry.expected);
        expect(result.toString(), isNot(contains('raw_secret_detail')));
      }
    },
  );

  test(
    'fails closed after a repeated integer offset without publishing partial accounts',
    () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'accounts': [_accountJson],
          'nextOffset': 1,
        }),
        _json(200, {
          'accounts': [_accountJson],
          'nextOffset': 1,
        }),
      ]);

      final result = await reader(
        adapter,
      ).readCatalog(WalletToken.parse('synthetic-token'));

      expect(result, const WalletReadFailure.protocol());
      expect(adapter.requests, hasLength(2));
    },
  );

  test(
    'fails closed after twenty distinct integer-offset pages without partial publish',
    () async {
      final adapter = _QueueAdapter(
        List<ResponseBody>.generate(
          20,
          (index) => _json(200, {
            'accounts': [_accountJson],
            'nextOffset': index + 1,
          }),
        ),
      );

      final result = await reader(
        adapter,
      ).readCatalog(WalletToken.parse('synthetic-token'));

      expect(result, const WalletReadFailure.protocol());
      expect(adapter.requests, hasLength(20));
    },
  );
}

final _accountJson = <String, dynamic>{
  'id': 'account-1',
  'name': 'Daily',
  'archived': false,
  'isBankSync': false,
  'accountType': 'CASH',
  'initialBalance': {'currencyCode': 'LKR'},
  'balance': {'currencyCode': 'USD'},
};

final _categoryJson = <String, dynamic>{'id': 'category-1', 'name': 'Food'};

ResponseBody _json(
  int statusCode,
  Object data, {
  Map<String, List<String>>? headers,
}) => _jsonText(statusCode, jsonEncode(data), headers: headers);

ResponseBody _jsonText(
  int statusCode,
  String data, {
  Map<String, List<String>>? headers,
}) => ResponseBody.fromString(
  data,
  statusCode,
  headers:
      headers ??
      {
        'content-type': ['application/json'],
      },
);

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(List<ResponseBody> responses) : _responses = List.of(responses);

  final List<ResponseBody> _responses;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_responses.isEmpty) {
      throw StateError('No synthetic response configured');
    }
    return _responses.removeAt(0);
  }
}

class _ThrowingAdapter implements HttpClientAdapter {
  const _ThrowingAdapter(this.error);

  final Object error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => Future<ResponseBody>.error(error);
}
