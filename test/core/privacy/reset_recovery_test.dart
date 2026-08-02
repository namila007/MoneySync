import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/reset_recovery.dart';
import 'package:money_sync/core/privacy/reset_tombstone.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'me.namila.money_sync/security';
  late Directory tempDir;
  late String databasePath;
  var deleteKeysCalls = 0;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reset_recovery_test');
    databasePath = '${tempDir.path}/database/money_sync.db';
    deleteKeysCalls = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall call,
        ) async {
          switch (call.method) {
            case 'deleteKeys':
              deleteKeysCalls += 1;
              return null;
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

  group('InterruptedResetRecovery', () {
    test('does nothing when no tombstone is present', () async {
      final tombstone = ResetTombstone(databasePath: databasePath);
      final recovery = InterruptedResetRecovery(
        channel: const NativeSecurityChannel(),
        databasePath: databasePath,
        tombstone: tombstone,
      );

      await recovery.recoverIfNeeded();

      expect(deleteKeysCalls, 0);
    });

    test(
      'deletes keys, removes DB/WAL/SHM sentinels, and clears the tombstone',
      () async {
        final tombstone = ResetTombstone(databasePath: databasePath);
        await tombstone.persist();

        final dbDir = Directory('${tempDir.path}/database')
          ..createSync(recursive: true);
        final dbFile = File('${dbDir.path}/money_sync.db')
          ..writeAsStringSync('synthetic-db-sentinel');
        final walFile = File('${dbDir.path}/money_sync.db-wal')
          ..writeAsStringSync('synthetic-wal-sentinel');
        final shmFile = File('${dbDir.path}/money_sync.db-shm')
          ..writeAsStringSync('synthetic-shm-sentinel');

        final recovery = InterruptedResetRecovery(
          channel: const NativeSecurityChannel(),
          databasePath: databasePath,
          tombstone: tombstone,
        );

        await recovery.recoverIfNeeded();

        expect(deleteKeysCalls, 1);
        expect(dbFile.existsSync(), isFalse);
        expect(walFile.existsSync(), isFalse);
        expect(shmFile.existsSync(), isFalse);
        expect(await tombstone.exists(), isFalse);
      },
    );

    test(
      'clears the tombstone even when the DB file was already gone',
      () async {
        final tombstone = ResetTombstone(databasePath: databasePath);
        await tombstone.persist();

        final recovery = InterruptedResetRecovery(
          channel: const NativeSecurityChannel(),
          databasePath: databasePath,
          tombstone: tombstone,
        );

        await recovery.recoverIfNeeded();

        expect(deleteKeysCalls, 1);
        expect(await tombstone.exists(), isFalse);
      },
    );
  });
}
