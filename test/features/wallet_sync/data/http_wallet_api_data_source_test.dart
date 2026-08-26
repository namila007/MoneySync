import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_sync/data/http_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_outcome.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';

void main() {
  HttpWalletApiDataSource dataSource(HttpClientAdapter adapter) =>
      HttpWalletApiDataSource(
        tokenGetter: () async => WalletToken.parse('synthetic-token'),
        httpClientAdapter: adapter,
      );

  TransactionCandidateSnapshot makePayload() => TransactionCandidateSnapshot(
    accountId: 'acct-1',
    amountMinor: 442500,
    currencyCode: 'LKR',
    recordDateUtc: DateTime.utc(2026, 8, 25, 12, 0, 0),
    paymentType: WalletPaymentType.debitCard,
    recordState: WalletRecordState.cleared,
  );

  const recordId = 'rec-abc-123';

  // ---------------------------------------------------------------------------
  // createRecord
  // ---------------------------------------------------------------------------
  group('createRecord', () {
    test('200 with top-level id key', () async {
      final adapter = _QueueAdapter([
        _json(200, {'id': recordId}),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, recordId);
    });

    test('200 with results[].record.id wrapper', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'summary': {'created': 1},
          'results': [
            {
              'record': {'id': recordId},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, recordId);
    });

    test('200 with plain array response', () async {
      final adapter = _QueueAdapter([
        _json(200, [
          {'id': recordId},
        ]),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, recordId);
    });

    test('200 with no id in response → placeholder', () async {
      final adapter = _QueueAdapter([
        _json(200, {'status': 'ok'}),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, 'unknown');
    });

    test('200 with empty results list → placeholder', () async {
      final adapter = _QueueAdapter([
        _json(200, {'results': []}),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, 'unknown');
    });

    test('200 results with record missing id → placeholder', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'results': [
            {
              'record': {'note': 'no id'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, 'unknown');
    });

    test('200 results with first item not a map → placeholder', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'results': ['string'],
        }),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreateAllSucceeded>());
      expect((result as WalletCreateAllSucceeded).recordId, 'unknown');
    });

    test('207 partial success', () async {
      final adapter = _QueueAdapter([
        _json(207, {'partial': true}),
      ]);
      final result = await dataSource(adapter).createRecord(makePayload());
      expect(result, isA<WalletCreatePartial>());
    });

    test('401 → AuthenticationRequired', () async {
      final adapter = _QueueAdapter([_json(401, {})]);
      expect(
        () => dataSource(adapter).createRecord(makePayload()),
        throwsA(
          isA<WalletApiDataSourceException>().having(
            (e) => e.classification,
            'classification',
            isA<AuthenticationRequired>(),
          ),
        ),
      );
    });

    test('403 → AuthenticationRequired', () async {
      final adapter = _QueueAdapter([_json(403, {})]);
      expect(
        () => dataSource(adapter).createRecord(makePayload()),
        throwsA(
          isA<WalletApiDataSourceException>().having(
            (e) => e.classification,
            'classification',
            isA<AuthenticationRequired>(),
          ),
        ),
      );
    });

    test('409 → RetryableConflict', () async {
      final adapter = _QueueAdapter([_json(409, {})]);
      expect(
        () => dataSource(adapter).createRecord(makePayload()),
        throwsA(
          isA<WalletApiDataSourceException>().having(
            (e) => e.classification,
            'classification',
            isA<RetryableConflict>(),
          ),
        ),
      );
    });

    test('429 → RateLimited', () async {
      final adapter = _QueueAdapter([_json(429, {})]);
      expect(
        () => dataSource(adapter).createRecord(makePayload()),
        throwsA(
          isA<WalletApiDataSourceException>().having(
            (e) => e.classification,
            'classification',
            isA<RateLimited>(),
          ),
        ),
      );
    });

    test('other 4xx → RetryablePreTransmission', () async {
      final adapter = _QueueAdapter([_json(404, {})]);
      expect(
        () => dataSource(adapter).createRecord(makePayload()),
        throwsA(
          isA<WalletApiDataSourceException>().having(
            (e) => e.classification,
            'classification',
            isA<RetryablePreTransmission>(),
          ),
        ),
      );
    });

    test('418 (other 4xx fallthrough) → RetryablePreTransmission', () async {
      final adapter = _QueueAdapter([_json(418, {})]);
      expect(
        () => dataSource(adapter).createRecord(makePayload()),
        throwsA(
          isA<WalletApiDataSourceException>().having(
            (e) => e.classification,
            'classification',
            isA<RetryablePreTransmission>(),
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getRecord
  // ---------------------------------------------------------------------------
  group('getRecord', () {
    test('empty id → null, no network call', () async {
      final adapter = _QueueAdapter([]);
      final result = await dataSource(adapter).getRecord('');
      expect(result, isNull);
      expect(adapter.requests, isEmpty);
    });

    test('200 with decodable record', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'rec-1',
              'amount': {'value': 4425.0, 'currencyCode': 'LKR'},
              'note': 'lunch',
              'counterParty': 'Cafe',
              'recordDate': '2026-08-25T12:00:00.000Z',
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('rec-1');
      expect(result, isNotNull);
      expect(result!.id, 'rec-1');
      expect(result.amountMinor, 442500);
      expect(result.currencyCode, 'LKR');
      expect(result.note, 'lunch');
      expect(result.counterParty, 'Cafe');
      expect(result.recordDateUtc, isNotNull);
    });

    test('non-200 → null', () async {
      final adapter = _QueueAdapter([_json(404, {})]);
      final result = await dataSource(adapter).getRecord('rec-1');
      expect(result, isNull);
    });

    test('200 with no records key → null', () async {
      final adapter = _QueueAdapter([
        _json(200, {'data': 'empty'}),
      ]);
      final result = await dataSource(adapter).getRecord('rec-1');
      expect(result, isNull);
    });

    test('200 with empty records list → null', () async {
      final adapter = _QueueAdapter([
        _json(200, {'records': []}),
      ]);
      final result = await dataSource(adapter).getRecord('rec-1');
      expect(result, isNull);
    });

    test('DioException → null', () async {
      final adapter = _ThrowingAdapter(
        DioException(
          requestOptions: RequestOptions(path: '/v1/api/records'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      final result = await dataSource(adapter).getRecord('rec-1');
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // findRecordForReconciliation
  // ---------------------------------------------------------------------------
  group('findRecordForReconciliation', () {
    WalletReconciliationQuery makeQuery(
      String marker, {
      String accountId = '',
    }) => WalletReconciliationQuery(
      marker: marker,
      accountId: accountId,
      amountMinor: 442500,
    );

    test('empty marker → empty list, no network call', () async {
      final adapter = _QueueAdapter([]);
      final result = await dataSource(
        adapter,
      ).findRecordForReconciliation(makeQuery(''));
      expect(result, isEmpty);
      expect(adapter.requests, isEmpty);
    });

    test('200 with matching records', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'rec-a',
              'amount': {'value': 100, 'currencyCode': 'LKR'},
            },
            {
              'id': 'rec-b',
              'amount': {'value': 200, 'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(
        adapter,
      ).findRecordForReconciliation(makeQuery('sw:1'));
      expect(result, hasLength(2));
      expect(result.first.id, 'rec-a');
      expect(result.last.id, 'rec-b');
    });

    test('non-200 → empty list', () async {
      final adapter = _QueueAdapter([_json(503, {})]);
      final result = await dataSource(
        adapter,
      ).findRecordForReconciliation(makeQuery('sw:1'));
      expect(result, isEmpty);
    });

    test('DioException → empty list', () async {
      final adapter = _ThrowingAdapter(
        DioException(
          requestOptions: RequestOptions(path: '/v1/api/records'),
          type: DioExceptionType.connectionError,
        ),
      );
      final result = await dataSource(
        adapter,
      ).findRecordForReconciliation(makeQuery('sw:1'));
      expect(result, isEmpty);
    });

    test('200 with non-list records → empty list', () async {
      final adapter = _QueueAdapter([
        _json(200, {'records': 'not-a-list'}),
      ]);
      final result = await dataSource(
        adapter,
      ).findRecordForReconciliation(makeQuery('sw:1'));
      expect(result, isEmpty);
    });

    test('200 with empty records list → empty list', () async {
      final adapter = _QueueAdapter([
        _json(200, {'records': []}),
      ]);
      final result = await dataSource(
        adapter,
      ).findRecordForReconciliation(makeQuery('sw:1'));
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getUsageStats
  // ---------------------------------------------------------------------------
  group('getUsageStats', () {
    test('200 with full fields', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'recordCount': 42,
          'requestCount': 100,
          'rateLimitRemaining': 50,
        }),
      ]);
      final result = await dataSource(adapter).getUsageStats();
      expect(result.recordCount, 42);
      expect(result.requestCount, 100);
      expect(result.rateLimitRemaining, 50);
    });

    test('200 with partial fields → defaults', () async {
      final adapter = _QueueAdapter([_json(200, {})]);
      final result = await dataSource(adapter).getUsageStats();
      expect(result.recordCount, 0);
      expect(result.requestCount, 0);
      expect(result.rateLimitRemaining, isNull);
    });

    test('non-200 → zero-value fallback', () async {
      final adapter = _QueueAdapter([_json(503, {})]);
      final result = await dataSource(adapter).getUsageStats();
      expect(result.recordCount, 0);
      expect(result.requestCount, 0);
      expect(result.rateLimitRemaining, isNull);
    });

    test('200 with non-map body → zero-value fallback', () async {
      final adapter = _QueueAdapter([
        _json(200, [1, 2, 3]),
      ]);
      final result = await dataSource(adapter).getUsageStats();
      expect(result.recordCount, 0);
      expect(result.requestCount, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // ensureLabel
  // ---------------------------------------------------------------------------
  group('ensureLabel', () {
    test('label found on lookup → returns id, no POST', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'labels': [
            {'id': 'lbl-1', 'name': 'money_sync'},
          ],
        }),
      ]);
      final result = await dataSource(adapter).ensureLabel('money_sync');
      expect(result, 'lbl-1');
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.first.method, 'GET');
    });

    test('label not found → POST creates it', () async {
      final adapter = _QueueAdapter([
        _json(200, {'labels': []}),
        _json(201, {
          'label': {'id': 'lbl-new', 'name': 'test'},
        }),
      ]);
      final result = await dataSource(adapter).ensureLabel('test');
      expect(result, 'lbl-new');
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.method, 'POST');
    });

    test('lookup non-200 still attempts create', () async {
      final adapter = _QueueAdapter([
        _json(503, {}),
        _json(201, {
          'label': {'id': 'lbl-fallback', 'name': 'test'},
        }),
      ]);
      final result = await dataSource(adapter).ensureLabel('test');
      expect(result, 'lbl-fallback');
      expect(adapter.requests, hasLength(2));
    });

    test('create returns non-201 → null', () async {
      final adapter = _QueueAdapter([
        _json(200, {'labels': []}),
        _json(500, {}),
      ]);
      final result = await dataSource(adapter).ensureLabel('test');
      expect(result, isNull);
    });

    test('create 201 but missing label.id → null', () async {
      final adapter = _QueueAdapter([
        _json(200, {'labels': []}),
        _json(201, {'label': {}}),
      ]);
      final result = await dataSource(adapter).ensureLabel('test');
      expect(result, isNull);
    });

    test('DioException during lookup → null', () async {
      final adapter = _ThrowingAdapter(
        DioException(
          requestOptions: RequestOptions(path: '/v1/api/labels'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      final result = await dataSource(adapter).ensureLabel('test');
      expect(result, isNull);
    });

    test('DioException during create → null', () async {
      final adapter = _MixedAdapter([
        _json(200, {'labels': []}),
        DioException(
          requestOptions: RequestOptions(path: '/v1/api/labels'),
          type: DioExceptionType.connectionError,
        ),
      ]);
      final result = await dataSource(adapter).ensureLabel('test');
      expect(result, isNull);
    });

    test(
      'lookup label found but id missing/empty → falls through to create',
      () async {
        final adapter = _QueueAdapter([
          _json(200, {
            'labels': [
              {'name': 'test'},
            ],
          }),
          _json(201, {
            'label': {'id': 'lbl-created', 'name': 'test'},
          }),
        ]);
        final result = await dataSource(adapter).ensureLabel('test');
        expect(result, 'lbl-created');
      },
    );

    test(
      'lookup label found but label entry has no id field → falls through',
      () async {
        final adapter = _QueueAdapter([
          _json(200, {
            'labels': [
              {'name': 'test', 'color': 'red'},
            ],
          }),
          _json(201, {
            'label': {'id': 'lbl-post', 'name': 'test'},
          }),
        ]);
        final result = await dataSource(adapter).ensureLabel('test');
        expect(result, 'lbl-post');
      },
    );
  });

  // ---------------------------------------------------------------------------
  // _decodeRecord amount conversion (_asMap switch branches)
  // ---------------------------------------------------------------------------
  group('_decodeRecord amount conversion', () {
    test('amount.value as int → multiplied by 100', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'r1',
              'amount': {'value': 44, 'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('r1');
      expect(result!.amountMinor, 4400);
    });

    test('amount.value as double → rounded * 100', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'r2',
              'amount': {'value': 44.25, 'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('r2');
      expect(result!.amountMinor, 4425);
    });

    test('amount.value as String → parsed * 100', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'r3',
              'amount': {'value': '12.50', 'currencyCode': 'USD'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('r3');
      expect(result!.amountMinor, 1250);
    });

    test('amount.value unparseable string → 0', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'r4',
              'amount': {'value': 'not-a-number', 'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('r4');
      expect(result!.amountMinor, 0);
    });

    test('amount.value null → 0', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': 'r5',
              'amount': {'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('r5');
      expect(result!.amountMinor, 0);
    });

    test('amount entirely missing → 0', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {'id': 'r6'},
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('r6');
      expect(result!.amountMinor, 0);
    });

    test('record with missing id → null', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'amount': {'value': 100, 'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('any');
      expect(result, isNull);
    });

    test('record with empty id → null', () async {
      final adapter = _QueueAdapter([
        _json(200, {
          'records': [
            {
              'id': '',
              'amount': {'value': 100, 'currencyCode': 'LKR'},
            },
          ],
        }),
      ]);
      final result = await dataSource(adapter).getRecord('any');
      expect(result, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers — local adapter implementations (same pattern as
// wallet_catalog_reader_test.dart, not shared)
// ---------------------------------------------------------------------------
ResponseBody _json(
  int statusCode,
  Object data, {
  Map<String, List<String>>? headers,
}) => ResponseBody.fromString(
  jsonEncode(data),
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
    Stream<Uint8List>? requestStream,
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
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => Future<ResponseBody>.error(error);
}

/// Adapter that returns queued items where each item is either a
/// [ResponseBody] (success) or an [Object] to throw (error). Needed for
/// ensureLabel tests where DioException must happen on the POST, not the GET.
class _MixedAdapter implements HttpClientAdapter {
  _MixedAdapter(List<Object> items) : _items = List.of(items);

  final List<Object> _items;
  final List<RequestOptions> requests = [];
  int _callCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_callCount >= _items.length) {
      throw StateError('No synthetic response configured');
    }
    final item = _items[_callCount++];
    if (item is ResponseBody) return item;
    // ignore: only_throw_errors
    throw item;
  }
}
