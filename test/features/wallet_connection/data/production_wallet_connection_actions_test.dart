import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/data/production_wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/data/wallet_catalog_reader.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart'
    hide FreshAuthPort;

void main() {
  group('ProductionWalletConnectionActions', () {
    test('connect reads once, saves the token only after success, and writes '
        'the cache from the same result', () async {
      final adapter = _QueueAdapter([
        _json(200, {'accounts': [], 'nextOffset': null}),
        _json(200, {'categories': [], 'nextOffset': null}),
        // M5.22 WP-L: the catalog now fetches labels as a third page.
        _json(200, {'labels': [], 'nextOffset': null}),
      ]);
      final secretStore = _FakeSecretStore();
      final cache = _FakeCache();
      final actions = ProductionWalletConnectionActions(
        secretStore: secretStore,
        freshAuth: _FakeFreshAuth(),
        cache: cache,
        reader: WalletCatalogReader.forTesting(adapter: adapter),
      );

      final result = await actions.connect(
        WalletToken.parse('synthetic-token'),
        replacing: false,
        lifecycleEpoch: 0,
      );

      expect(result, isA<WalletConnectionCatalogReady>());
      expect(secretStore.saved, isNotNull);
      expect(cache.written, isNotNull);
    });

    test('connect does not save the token when the read fails', () async {
      final adapter = _QueueAdapter([
        _json(401, {'error': 'invalid'}),
      ]);
      final secretStore = _FakeSecretStore();
      final actions = ProductionWalletConnectionActions(
        secretStore: secretStore,
        freshAuth: _FakeFreshAuth(),
        cache: _FakeCache(),
        reader: WalletCatalogReader.forTesting(adapter: adapter),
      );

      final result = await actions.connect(
        WalletToken.parse('bad-token'),
        replacing: false,
        lifecycleEpoch: 0,
      );

      expect(result, isA<WalletConnectionActionFailure>());
      expect(secretStore.saved, isNull);
    });

    test('connect requires fresh authentication when replacing an existing '
        'token', () async {
      final freshAuth = _FakeFreshAuth(outcome: DeviceAuthOutcome.cancelled);
      final actions = ProductionWalletConnectionActions(
        secretStore: _FakeSecretStore(),
        freshAuth: freshAuth,
        cache: _FakeCache(),
        reader: WalletCatalogReader.forTesting(adapter: _QueueAdapter([])),
      );

      final result = await actions.connect(
        WalletToken.parse('replacement-token'),
        replacing: true,
        lifecycleEpoch: 0,
      );

      expect(result, isA<WalletConnectionFreshAuthenticationRequired>());
      expect(freshAuth.calls, 1);
    });

    test('refresh reads via the stored token and writes the cache', () async {
      final adapter = _QueueAdapter([
        _json(200, {'accounts': [], 'nextOffset': null}),
        _json(200, {'categories': [], 'nextOffset': null}),
        // M5.22 WP-L: the catalog now fetches labels as a third page.
        _json(200, {'labels': [], 'nextOffset': null}),
      ]);
      final secretStore = _FakeSecretStore()
        ..saved = WalletToken.parse('stored-token');
      final cache = _FakeCache();
      final actions = ProductionWalletConnectionActions(
        secretStore: secretStore,
        freshAuth: _FakeFreshAuth(),
        cache: cache,
        reader: WalletCatalogReader.forTesting(adapter: adapter),
      );

      final result = await actions.refresh(lifecycleEpoch: 0);

      expect(result, isA<WalletConnectionCatalogReady>());
      expect(cache.written, isNotNull);
    });

    test('disconnect clears both the cache and the stored secret', () async {
      final secretStore = _FakeSecretStore()
        ..saved = WalletToken.parse('to-be-cleared');
      final cache = _FakeCache()
        ..written = WalletCatalog(accounts: const [], categories: const []);
      final actions = ProductionWalletConnectionActions(
        secretStore: secretStore,
        freshAuth: _FakeFreshAuth(),
        cache: cache,
        reader: WalletCatalogReader.forTesting(adapter: _QueueAdapter([])),
      );

      await actions.disconnect(lifecycleEpoch: 0);

      expect(secretStore.cleared, isTrue);
      expect(cache.cleared, isTrue);
    });
  });
}

final class _FakeSecretStore implements WalletSecretStore {
  WalletToken? saved;
  bool cleared = false;

  @override
  Future<void> save(WalletToken token) async => saved = token;

  @override
  Future<T> useSecret<T>(
    Future<T> Function(WalletToken token) operation,
  ) async {
    final token = saved;
    if (token == null) throw StateError('no token saved');
    return operation(token);
  }

  @override
  Future<void> clear() async {
    saved = null;
    cleared = true;
  }
}

final class _FakeCache implements WalletCatalogCache {
  WalletCatalog? written;
  bool cleared = false;

  @override
  Future<WalletCatalog?> read() async => written;

  @override
  Future<void> write(WalletCatalog catalog) async => written = catalog;

  @override
  Future<void> clear() async {
    written = null;
    cleared = true;
  }
}

final class _FakeFreshAuth implements FreshAuthPort {
  _FakeFreshAuth({this.outcome = DeviceAuthOutcome.authenticated});

  final DeviceAuthOutcome outcome;
  int calls = 0;

  @override
  Future<DeviceAuthOutcome> authenticate({required String purpose}) async {
    calls += 1;
    return outcome;
  }

  @override
  Future<bool> isDeviceAuthAvailable() async => true;
}

ResponseBody _json(int statusCode, Map<String, Object?> body) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(bytes, statusCode);
}

final class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this._responses);

  final List<ResponseBody> _responses;
  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_index >= _responses.length) {
      throw StateError('No more queued responses');
    }
    return _responses[_index++];
  }

  @override
  void close({bool force = false}) {}
}
