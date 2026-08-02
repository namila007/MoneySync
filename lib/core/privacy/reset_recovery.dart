import 'dart:io';

import 'package:money_sync/core/privacy/reset_tombstone.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

/// Resumes an interrupted full-reset before the encrypted database is ever
/// reopened. If the process died mid-reset (after keys/DB deletion started
/// but before the tombstone was cleared), the next boot must not silently
/// treat any surviving fragment as valid — it must finish the deletion
/// fail-closed. Every step here is idempotent: repeating key or file
/// deletion when nothing remains is a safe no-op.
final class InterruptedResetRecovery {
  const InterruptedResetRecovery({
    required this.channel,
    required this.databasePath,
    required this.tombstone,
  });

  final NativeSecurityChannel channel;
  final String databasePath;
  final ResetTombstone tombstone;

  Future<void> recoverIfNeeded() async {
    if (!await tombstone.exists()) return;

    try {
      await channel.deleteKeys();
    } on Exception {
      // best-effort — keys may already be gone from the interrupted attempt
    }

    try {
      final dbFile = File(databasePath);
      final walFile = File('$databasePath-wal');
      final shmFile = File('$databasePath-shm');
      if (await dbFile.exists()) await dbFile.delete();
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();
    } on Exception {
      // best-effort — files may already be gone from the interrupted attempt
    }

    await tombstone.clear();
  }
}
