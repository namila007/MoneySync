import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guards: these tests scan the lib/ source tree for forbidden
/// patterns that would break the Modernist design system. If a new file
/// introduces a hardcoded border radius, inline font size, or raw Material
/// color, these tests catch it.
void main() {
  final libDir = Directory('lib');

  List<String> dartFiles() => libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) => f.path)
      .toList();

  test('no non-zero BorderRadius in lib/', () {
    final files = dartFiles();
    final violations = <String>[];
    for (final file in files) {
      final content = File(file).readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('BorderRadius.circular') ||
            line.contains('BorderRadius.all')) {
          violations.add('$file:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Found non-zero BorderRadius:\n${violations.join('\n')}',
    );
  });

  test('no hardcoded Colors.* in lib/', () {
    final files = dartFiles();
    final violations = <String>[];
    for (final file in files) {
      final content = File(file).readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('Colors.orange') ||
            line.contains('Colors.green') ||
            line.contains('Colors.amber') ||
            line.contains('Colors.red') ||
            line.contains('Colors.blue')) {
          violations.add('$file:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Found hardcoded Colors:\n${violations.join('\n')}',
    );
  });

  test('no inline TextStyle(fontSize:) in lib/', () {
    final files = dartFiles();
    final violations = <String>[];
    for (final file in files) {
      final content = File(file).readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('TextStyle(fontSize:')) {
          violations.add('$file:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Found inline TextStyle(fontSize:):\n${violations.join('\n')}',
    );
  });
}
