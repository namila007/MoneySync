import 'dart:convert';
import 'dart:io';

/// Durable marker proving a full local-data reset is in progress. Written
/// before any destructive deletion begins and cleared only after every
/// required cleanup step completes, so an interrupted reset (process death,
/// crash, forced kill) can be detected and resumed fail-closed on next boot
/// — before the encrypted database is ever reopened.
final class ResetTombstone {
  const ResetTombstone({required this.databasePath});

  final String databasePath;

  File get _file {
    final dir = File(databasePath).parent;
    return File('${dir.path}/reset_tombstone.marker');
  }

  Future<void> persist() async {
    final file = _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({'startedAtEpochMs': DateTime.now().millisecondsSinceEpoch}),
      flush: true,
    );
  }

  Future<bool> exists() => _file.exists();

  Future<void> clear() async {
    final file = _file;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
