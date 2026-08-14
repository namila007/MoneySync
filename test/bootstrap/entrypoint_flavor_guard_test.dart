import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flavor/entrypoint guard', () {
    String readEntrypoint(String name) => File('lib/$name').readAsStringSync();

    test('main_private_full.dart boots AppConfig.privateFull', () {
      final source = readEntrypoint('main_private_full.dart');
      expect(source, contains('AppConfig.privateFull()'));
      expect(source, isNot(contains('AppConfig.playManual()')));
    });

    test('main_play_manual.dart boots AppConfig.playManual', () {
      final source = readEntrypoint('main_play_manual.dart');
      expect(source, contains('AppConfig.playManual()'));
      expect(source, isNot(contains('AppConfig.privateFull()')));
    });

    test('default main.dart boots AppConfig.playManual', () {
      // The default target is playManual; privateFull must never be built
      // without its matching entrypoint (M4.10 follow-up 1).
      final source = readEntrypoint('main.dart');
      expect(source, contains('AppConfig.playManual()'));
    });
  });
}
