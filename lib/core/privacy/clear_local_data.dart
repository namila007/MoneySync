import 'dart:io';

import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/logging/activity_writer_generation.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/core/privacy/reset_tombstone.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

final class ClearLocalDataResult {
  const ClearLocalDataResult({
    required this.epochAdvanced,
    required this.keysDeleted,
    required this.databaseRemoved,
    this.activityCleared = false,
    this.tombstoneCleared = false,
  });

  final bool epochAdvanced;
  final bool keysDeleted;
  final bool databaseRemoved;

  /// True when [ClearLocalDataService.clearActivityOnly] removed activity
  /// rows. Distinct from [epochAdvanced], which only [clearAllAppData] sets
  /// — clearing activity never touches the global privacy epoch.
  final bool activityCleared;

  /// True when the reset tombstone was cleared after every destructive step
  /// completed. False does not necessarily mean reset failed — it means an
  /// interrupted-reset recovery will run on next boot to finish cleanup,
  /// which is safe because every step is idempotent.
  final bool tombstoneCleared;

  bool get success => epochAdvanced && keysDeleted && databaseRemoved;
}

final class ClearLocalDataService {
  ClearLocalDataService({
    required this.database,
    required this.channel,
    required this.databasePath,
    this._activityGeneration,
  }) : _tombstone = ResetTombstone(databasePath: databasePath);

  final AppDatabase database;
  final NativeSecurityChannel channel;
  final String databasePath;
  final ResetTombstone _tombstone;
  final ActivityWriterGeneration? _activityGeneration;

  Future<ClearLocalDataResult> clearAllAppData() async {
    var epochAdvanced = false;
    var keysDeleted = false;
    var databaseRemoved = false;
    var tombstoneCleared = false;

    final currentEpoch = (await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle()).privacyEpoch;

    try {
      await database.advancePrivacyEpoch(expectedCurrent: currentEpoch);
      epochAdvanced = true;
    } on Exception {
      // Epoch advance failure is not blocking
    }

    // Quiesce-then-destroy ordering: persist the tombstone before any
    // destructive deletion begins, so an interrupted reset is detectable
    // and resumable fail-closed on next boot (see reset_recovery.dart).
    try {
      await _tombstone.persist();
    } on Exception {
      // If the tombstone itself can't be written, proceed best-effort —
      // an unrecorded interruption is no worse than pre-M3.7 behavior.
    }

    await database.close();

    try {
      await channel.deleteKeys();
      keysDeleted = true;
    } on Exception {
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
    } on Exception {
      // File deletion failure is not blocking
    }

    if (keysDeleted && databaseRemoved) {
      try {
        await _tombstone.clear();
        tombstoneCleared = true;
      } on Exception {
        // Leave the tombstone in place; next boot's recovery will retry.
      }
    }

    return ClearLocalDataResult(
      epochAdvanced: epochAdvanced,
      keysDeleted: keysDeleted,
      databaseRemoved: databaseRemoved,
      tombstoneCleared: tombstoneCleared,
    );
  }

  /// Clears only the activity log and decision traces. Uses a dedicated
  /// activity-writer generation fence instead of the global privacy epoch —
  /// clearing activity must never invalidate other epoch-gated writes, and
  /// must never delete diagnostic log files (only full reset does that).
  Future<ClearLocalDataResult> clearActivityOnly() async {
    _activityGeneration?.advance();

    try {
      await database.transaction(() async {
        await database.delete(database.activityEvents).go();
        await database.delete(database.decisionTraces).go();
      });
    } on Object catch (e, s) {
      final logger = Logger('ClearLocalDataService');
      logger.error('Failed to clear activity events and decision traces', e, s);
      return const ClearLocalDataResult(
        epochAdvanced: false,
        keysDeleted: false,
        databaseRemoved: false,
        activityCleared: false,
      );
    }

    return const ClearLocalDataResult(
      epochAdvanced: false,
      keysDeleted: false,
      databaseRemoved: false,
      activityCleared: true,
    );
  }
}
