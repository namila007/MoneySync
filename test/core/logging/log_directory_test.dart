import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogDirectory', () {
    test('temp directory can be created and cleared', () async {
      final dir = Directory.systemTemp.createTempSync('log_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      final debugDir = Directory('${dir.path}/logs/debug');
      await debugDir.create(recursive: true);
      expect(await debugDir.exists(), isTrue);

      final appDir = Directory('${dir.path}/logs/app');
      await appDir.create(recursive: true);
      expect(await appDir.exists(), isTrue);

      // Clear all
      await Directory('${dir.path}/logs').delete(recursive: true);
      expect(await Directory('${dir.path}/logs').exists(), isFalse);
    });
  });
}
