import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/data/keystore_wallet_secret_store.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'me.namila.money_sync/security';
  String? storedHex;
  var saveCalls = 0;
  var loadCalls = 0;
  var deleteCalls = 0;

  late KeystoreWalletSecretStore store;

  setUp(() {
    storedHex = null;
    saveCalls = 0;
    loadCalls = 0;
    deleteCalls = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall call,
        ) async {
          switch (call.method) {
            case 'storeWalletToken':
              saveCalls += 1;
              storedHex = call.arguments as String;
              return null;
            case 'loadWalletToken':
              loadCalls += 1;
              if (storedHex == null) return null;
              return storedHex;
            case 'deleteWalletToken':
              deleteCalls += 1;
              storedHex = null;
              return null;
            default:
              throw MissingPluginException();
          }
        });

    store = KeystoreWalletSecretStore(channel: const NativeSecurityChannel());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), null);
  });

  group('KeystoreWalletSecretStore', () {
    test('save stores hex-encoded token via native channel', () async {
      final token = WalletToken.parse('test-wallet-token-12345');

      await store.save(token);

      expect(saveCalls, 1);
      expect(storedHex, isNotNull);
      expect(storedHex!.length, greaterThan(10));

      final bytes = utf8.encode('test-wallet-token-12345');
      final expectedHex = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      expect(storedHex, expectedHex);
    });

    test('save with empty token value throws format exception', () async {
      await expectLater(
        () => store.save(WalletToken.parse('')),
        throwsA(isA<FormatException>()),
      );
    });

    test('useSecret loads, parses, and passes token to operation', () async {
      final token = WalletToken.parse('operation-token-abc');
      await store.save(token);

      String? capturedTokenStr;
      final result = await store.useSecret<String>((loadedToken) async {
        capturedTokenStr = loadedToken.toPersistenceString();
        return 'operation-done';
      });

      expect(result, 'operation-done');
      expect(capturedTokenStr, 'operation-token-abc');
      expect(loadCalls, 1);
    });

    test('useSecret propagates operation exception', () async {
      final token = WalletToken.parse('error-token-001');
      await store.save(token);

      await expectLater(
        store.useSecret<void>((_) async => throw StateError('op-failed')),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'op-failed'),
        ),
      );
    });

    test('clear deletes token via native channel', () async {
      final token = WalletToken.parse('clear-me-token');
      await store.save(token);
      expect(storedHex, isNotNull);

      await store.clear();

      expect(deleteCalls, 1);
      expect(storedHex, isNull);
    });

    test('clear is idempotent when no token exists', () async {
      await store.clear();
      await store.clear();

      expect(deleteCalls, 2);
    });

    test('useSecret throws when no token was saved', () async {
      await expectLater(
        store.useSecret<void>((_) async {}),
        throwsA(isA<Exception>()),
      );
    });

    test('save replaces previously saved token', () async {
      await store.save(WalletToken.parse('first-token'));
      await store.save(WalletToken.parse('second-token'));

      expect(saveCalls, 2);

      await store.useSecret<void>((token) async {
        expect(token.toPersistenceString(), 'second-token');
      });
    });

    test('token never appears in toString of store', () async {
      final token = WalletToken.parse('secret-token-never-logged');

      await store.save(token);

      final storeString = store.toString();
      final channelString = token.toString();

      expect(storeString, isNot(contains('secret-token-never-logged')));
      expect(channelString, contains('***'));
    });
  });
}
