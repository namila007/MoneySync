import 'dart:io';

final class LogDirectoryResolver {
  LogDirectoryResolver({Directory? base}) : _base = base;

  final Directory? _base;

  Future<Directory> debugLogDirectory() async {
    final base = _base ?? Directory.systemTemp;
    final dir = Directory('${base.path}/logs/debug');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> appLogDirectory() async {
    final base = _base ?? Directory.systemTemp;
    final dir = Directory('${base.path}/logs/app');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> clearAllLogs() async {
    final base = _base ?? Directory.systemTemp;
    final logsDir = Directory('${base.path}/logs');
    if (await logsDir.exists()) {
      await logsDir.delete(recursive: true);
    }
  }

  Future<void> clearDebugLogs() async {
    final base = _base ?? Directory.systemTemp;
    final debugDir = Directory('${base.path}/logs/debug');
    if (await debugDir.exists()) {
      await debugDir.delete(recursive: true);
    }
  }
}
