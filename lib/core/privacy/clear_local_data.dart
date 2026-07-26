import 'dart:io';

import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

final class ClearLocalDataResult {
  const ClearLocalDataResult({
    required this.epochAdvanced,
    required this.keysDeleted,
    required this.databaseRemoved,
  });

  final bool epochAdvanced;
  final bool keysDeleted;
  final bool databaseRemoved;

  bool get success => epochAdvanced && keysDeleted && databaseRemoved;
}

final class ClearLocalDataService {
  ClearLocalDataService({
    required this.database,
    required this.channel,
    required this.databasePath,
  });

  final AppDatabase database;
  final NativeSecurityChannel channel;
  final String databasePath;

  Future<ClearLocalDataResult> clearAllAppData() async {
    var epochAdvanced = false;
    var keysDeleted = false;
    var databaseRemoved = false;

    final currentEpoch = (await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle()).privacyEpoch;

    try {
      await database.advancePrivacyEpoch(expectedCurrent: currentEpoch);
      epochAdvanced = true;
    } catch (_) {
      // Epoch advance failure is not blocking
    }

    await database.close();

    try {
      await channel.deleteKeys();
      keysDeleted = true;
    } catch (_) {
      // Key deletion failure is not blocking
    }

    try {
      final dbFile = File(databasePath);
      final walFile = File('$databasePath-wal');
      final shmFile = File('$databasePath-shm');

      if (await dbFile.exists()) await dbFile.delete();
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();

      databaseRemoved = true;
    } catch (_) {
      // File deletion failure is not blocking
    }

    return ClearLocalDataResult(
      epochAdvanced: epochAdvanced,
      keysDeleted: keysDeleted,
      databaseRemoved: databaseRemoved,
    );
  }

  Future<ClearLocalDataResult> clearActivityOnly() async {
    final currentEpoch = (await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle()).privacyEpoch;

    try {
      await database.advancePrivacyEpoch(expectedCurrent: currentEpoch);
    } catch (_) {
      return const ClearLocalDataResult(
        epochAdvanced: false,
        keysDeleted: false,
        databaseRemoved: false,
      );
    }

    await database.transaction(() async {
      await database.delete(database.activityEvents).go();
      await database.delete(database.decisionTraces).go();
    });

    return const ClearLocalDataResult(
      epochAdvanced: true,
      keysDeleted: false,
      databaseRemoved: false,
    );
  }
}
