import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/logging/activity_writer_generation.dart';
import 'package:money_sync/core/privacy/clear_local_data.dart';
import 'package:money_sync/core/privacy/reset_tombstone.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'me.namila.money_sync/security';
  late Directory tempDir;
  late String databasePath;
  late AppDatabase database;
  var deleteKeysCalls = 0;
  var deleteKeysThrows = false;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clear_local_data_test');
    databasePath = '${tempDir.path}/database/money_sync.db';
    database = AppDatabase.inMemoryForTesting();
    deleteKeysCalls = 0;
    deleteKeysThrows = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall call,
        ) async {
          switch (call.method) {
            case 'deleteKeys':
              deleteKeysCalls += 1;
              if (deleteKeysThrows) {
                throw PlatformException(code: 'KEY_DELETION_FAILED');
              }
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

  group('ClearLocalDataService.clearAllAppData', () {
    test(
      'advances the epoch, persists then clears the tombstone, deletes '
      'keys and files, and reports full success',
      () async {
        final dbDir = Directory('${tempDir.path}/database')
          ..createSync(recursive: true);
        File('${dbDir.path}/money_sync.db').writeAsStringSync('db-sentinel');
        File(
          '${dbDir.path}/money_sync.db-wal',
        ).writeAsStringSync('wal-sentinel');

        final service = ClearLocalDataService(
          database: database,
          channel: const NativeSecurityChannel(),
          databasePath: databasePath,
        );

        final result = await service.clearAllAppData();

        expect(result.epochAdvanced, isTrue);
        expect(result.keysDeleted, isTrue);
        expect(result.databaseRemoved, isTrue);
        expect(result.tombstoneCleared, isTrue);
        expect(result.success, isTrue);
        expect(deleteKeysCalls, 1);
        expect(
          File('${dbDir.path}/money_sync.db').existsSync(),
          isFalse,
        );
        expect(
          await ResetTombstone(databasePath: databasePath).exists(),
          isFalse,
        );
      },
    );

    test(
      'leaves the tombstone in place when key deletion fails, so a later '
      'boot can resume cleanup',
      () async {
        deleteKeysThrows = true;
        final service = ClearLocalDataService(
          database: database,
          channel: const NativeSecurityChannel(),
          databasePath: databasePath,
        );

        final result = await service.clearAllAppData();

        expect(result.keysDeleted, isFalse);
        expect(result.tombstoneCleared, isFalse);
        expect(result.success, isFalse);
        expect(
          await ResetTombstone(databasePath: databasePath).exists(),
          isTrue,
        );
      },
    );
  });

  group('ClearLocalDataService.clearActivityOnly', () {
    test(
      'reports activityCleared without touching keysDeleted/databaseRemoved',
      () async {
        final service = ClearLocalDataService(
          database: database,
          channel: const NativeSecurityChannel(),
          databasePath: databasePath,
        );

        final result = await service.clearActivityOnly();

        expect(result.activityCleared, isTrue);
        expect(result.epochAdvanced, isFalse);
        expect(result.keysDeleted, isFalse);
        expect(result.databaseRemoved, isFalse);
        expect(deleteKeysCalls, 0);
      },
    );

    test('advances the injected activity-writer generation', () async {
      final generation = ActivityWriterGeneration();
      final service = ClearLocalDataService(
        database: database,
        channel: const NativeSecurityChannel(),
        databasePath: databasePath,
        activityGeneration: generation,
      );

      expect(generation.current, 0);
      await service.clearActivityOnly();
      expect(generation.current, 1);
    });

    test('does not advance the global privacy epoch', () async {
      final row = await (database.select(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      final epochBefore = row.privacyEpoch;

      final service = ClearLocalDataService(
        database: database,
        channel: const NativeSecurityChannel(),
        databasePath: databasePath,
      );
      await service.clearActivityOnly();

      final rowAfter = await (database.select(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(rowAfter.privacyEpoch, epochBefore);
    });
  });
}
