import 'dart:io';

import 'package:logging/logging.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

final class RollingFileHandler {
  RollingFileHandler({
    required this._logDirectory,
    required this._baseName,
    this.maxBytes = 10 * 1024 * 1024,
    this.maxFiles = 3,
    this.redactionPolicy,
  });

  final Directory _logDirectory;
  final String _baseName;
  final int maxBytes;
  final int maxFiles;
  final LogRedactionPolicy? redactionPolicy;

  File get _currentFile => File('${_logDirectory.path}/$_baseName');

  void handleLogRecord(LogRecord record) {
    try {
      final message = _format(record);
      if (redactionPolicy != null) {
        final redacted = redactionPolicy!.redact(message);
        if (redacted == null) return;
        _writeWithRotation(redacted);
      } else {
        _writeWithRotation(message);
      }
    } on FileSystemException {
      // best-effort: log write failures never crash the app
    }
  }

  String _format(LogRecord record) {
    final time = record.time.toUtc().toIso8601String();
    final level = record.level.name.padLeft(5);
    final msg = record.message.toString();
    if (record.error != null) {
      final trace = record.stackTrace != null
          ? record.stackTrace!.toString().split('\n').take(3).join(' | ')
          : record.error.toString();
      return '$time [$level] ${record.loggerName}: $msg | error=$trace';
    }
    return '$time [$level] ${record.loggerName}: $msg';
  }

  void _writeWithRotation(String line) async {
    try {
      final file = _currentFile;
      if (await file.exists()) {
        final length = await file.length();
        if (length > maxBytes) {
          await _rotate();
        }
      }
      await file.writeAsString('$line\n', mode: FileMode.append);
    } on FileSystemException {
      // best-effort
    }
  }

  Future<void> _rotate() async {
    for (var i = maxFiles - 1; i >= 0; i--) {
      final source = i == 0
          ? _currentFile
          : File('${_logDirectory.path}/$_baseName.$i');
      if (await source.exists()) {
        if (i == maxFiles - 1) {
          await source.delete();
        } else {
          await source.rename('${_logDirectory.path}/$_baseName.${i + 1}');
        }
      }
    }
  }

  Future<void> close() async {
    // no open resources to close
  }
}
