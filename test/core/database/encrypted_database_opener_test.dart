import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/encrypted_database_opener.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

final class _FixedKeyProvider implements DatabaseKeyProvider {
  const _FixedKeyProvider(this._bytes);
  final Uint8List _bytes;

  @override
  Future<DatabaseKeyAccess> acquire() async {
    return DatabaseKeyAvailable(DatabaseKeyHandle(Uint8List.fromList(_bytes)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'me.namila.money_sync/security';
  late Directory tempDir;
  late String databasePath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'encrypted_database_opener_test',
    );
    databasePath = '${tempDir.path}/money_sync.db';

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall call,
        ) async {
          switch (call.method) {
            case 'getSensitiveDatabasePath':
              return databasePath;
            default:
              throw MissingPluginException();
          }
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('opens a fresh encrypted database with a real SQLCipher key', () async {
    final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final opener = ProductionEncryptedDatabaseOpener(
      channel: const NativeSecurityChannel(),
      keyProvider: _FixedKeyProvider(key),
    );

    final database = await opener.open();
    addTearDown(database.close);

    expect(database.schemaVersion, 5);
    expect(await database.smsEvents.count().getSingle(), 0);
    expect(await File(databasePath).exists(), isTrue);
  });

  test(
    'reopening the same file with the same key round-trips written data',
    () async {
      final key = Uint8List.fromList(List<int>.generate(32, (i) => i));

      final first = await ProductionEncryptedDatabaseOpener(
        channel: const NativeSecurityChannel(),
        keyProvider: _FixedKeyProvider(key),
      ).open();
      await first.advancePrivacyEpoch(expectedCurrent: 0);
      await first.close();

      final second = await ProductionEncryptedDatabaseOpener(
        channel: const NativeSecurityChannel(),
        keyProvider: _FixedKeyProvider(key),
      ).open();
      addTearDown(second.close);

      final row = await (second.select(
        second.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(row.privacyEpoch, 1);
    },
  );

  test('reopening with the wrong key fails closed', () async {
    final firstKey = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final wrongKey = Uint8List.fromList(List<int>.generate(32, (i) => 255 - i));

    final first = await ProductionEncryptedDatabaseOpener(
      channel: const NativeSecurityChannel(),
      keyProvider: _FixedKeyProvider(firstKey),
    ).open();
    await first.advancePrivacyEpoch(expectedCurrent: 0);
    await first.close();

    final opener = ProductionEncryptedDatabaseOpener(
      channel: const NativeSecurityChannel(),
      keyProvider: _FixedKeyProvider(wrongKey),
    );

    var threw = false;
    try {
      final db = await opener.open();
      // The key is only actually applied lazily on first query, and
      // SQLCipher only detects a wrong key once it reads an actual
      // encrypted page — query multiple tables to force that read.
      await db.smsEvents.count().getSingle();
      await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      await db.close();
    } on Exception {
      threw = true;
    }

    expect(
      threw,
      isTrue,
      reason:
          'opening with the wrong key must fail closed rather than '
          'silently return wrong/empty data',
    );
  });

  test('fails closed when the key provider cannot supply a key', () async {
    final opener = ProductionEncryptedDatabaseOpener(
      channel: const NativeSecurityChannel(),
      keyProvider: const _UnavailableKeyProvider(),
    );

    await expectLater(
      opener.open(),
      throwsA(isA<DatabaseKeyUnavailableException>()),
    );
  });
}

final class _UnavailableKeyProvider implements DatabaseKeyProvider {
  const _UnavailableKeyProvider();

  @override
  Future<DatabaseKeyAccess> acquire() async =>
      const DatabaseKeyUnavailable(DatabaseKeyUnavailableReason.missing);
}
