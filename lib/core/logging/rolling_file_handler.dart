import 'dart:async';
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

  /// Tail of the serialized append chain. See [handleLogRecord].
  Future<void> _writes = Future<void>.value();

  void handleLogRecord(LogRecord record) {
    try {
      final message = _format(record);
      // M5.22 WP-F: redact() masks in place and always returns a string. It
      // used to return null to mean "drop this record", which silently
      // discarded every non-allowlisted line and left the log files empty.
      final line = redactionPolicy?.redact(message) ?? message;
      // Serialize appends. handleLogRecord is a synchronous listener, so
      // several records can be in flight at once; concurrent
      // writeAsString(append) calls interleave and tear lines apart
      // ("...de=null)" / " background..."). Chaining keeps one write in
      // flight at a time without blocking the caller.
      _writes = _writes.then((_) => _writeWithRotation(line)).catchError((
        Object e,
      ) {
        stderr.writeln('RollingFileHandler: log write failed: $e');
      });
    } on FileSystemException catch (e) {
      // A logger that cannot write must not crash the app — but it must not be
      // undebuggable either.
      stderr.writeln('RollingFileHandler: log write failed: $e');
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

  Future<void> _writeWithRotation(String line) async {
    try {
      final file = _currentFile;
      if (!await _logDirectory.exists()) {
        await _logDirectory.create(recursive: true);
      }
      if (await file.exists()) {
        final length = await file.length();
        if (length > maxBytes) {
          await _rotate();
        }
      }
      await file.writeAsString('$line\n', mode: FileMode.append);
    } on FileSystemException catch (e) {
      stderr.writeln('RollingFileHandler: rotation/append failed: $e');
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

  /// Waits for any queued appends to reach disk.
  Future<void> close() => _writes;
}
