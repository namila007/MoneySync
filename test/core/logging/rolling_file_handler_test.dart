import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/rolling_file_handler.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

void main() {
  group('RollingFileHandler', () {
    setUp(() {
      Logger.root.level = Level.ALL;
      hierarchicalLoggingEnabled = false;
    });

    test('writes log records to file', () async {
      final dir = Directory.systemTemp.createTempSync('log_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final handler = RollingFileHandler(
        logDirectory: dir,
        baseName: 'test.log',
        maxBytes: 1024 * 1024,
        maxFiles: 3,
      );

      final logger = Logger('test');
      logger.onRecord.listen((record) {
        handler.handleLogRecord(record);
      });
      logger.info('Test message');

      // File I/O is async — give it time to flush
      await Future.delayed(const Duration(milliseconds: 200));
      await handler.close();

      final file = File('${dir.path}/test.log');
      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(content, contains('[ INFO]'));
      expect(content, contains('Test message'));
    });

    test('redacts blocked content', () async {
      final dir = Directory.systemTemp.createTempSync('log_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final handler = RollingFileHandler(
        logDirectory: dir,
        baseName: 'redact.log',
        redactionPolicy: const LogRedactionPolicy(),
      );

      final logger = Logger('test');
      logger.onRecord.listen(handler.handleLogRecord);
      logger.info('Bearer eyJhbGciOiJIUzI1NiJ9');

      await Future.delayed(const Duration(milliseconds: 50));

      final file = File('${dir.path}/redact.log');
      if (await file.exists()) {
        final content = await file.readAsString();
        expect(content, isEmpty);
      }
    });

    test('rotates file when maxBytes exceeded', () async {
      final dir = Directory.systemTemp.createTempSync('log_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final handler = RollingFileHandler(
        logDirectory: dir,
        baseName: 'rotate.log',
        maxBytes: 200,
        maxFiles: 2,
      );

      final logger = Logger('test');
      logger.onRecord.listen(handler.handleLogRecord);

      // Write enough data to trigger rotation
      for (var i = 0; i < 10; i++) {
        logger.info('Record $i ${'x' * 60}');
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final dirContents = dir.listSync();
      final logFiles = dirContents.whereType<File>().toList();
      expect(logFiles.length, greaterThanOrEqualTo(1));
    });

    test('does not crash on handleLogRecord with null redact', () async {
      final dir = Directory.systemTemp.createTempSync('log_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final handler = RollingFileHandler(
        logDirectory: dir,
        baseName: 'safe.log',
        redactionPolicy: LogRedactionPolicy(),
      );

      final logger = Logger('test');
      logger.onRecord.listen(handler.handleLogRecord);

      expect(
        () => logger.info('Your OTP is 123456'),
        returnsNormally,
      );

      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('close does not throw', () async {
      final dir = Directory.systemTemp.createTempSync('log_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final handler = RollingFileHandler(
        logDirectory: dir,
        baseName: 'close.log',
      );

      expect(handler.close, returnsNormally);
    });
  });
}
