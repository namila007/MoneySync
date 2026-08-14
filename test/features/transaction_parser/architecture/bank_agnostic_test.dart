import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Structural bank-agnosticism gate (M4.14 WP5 / §3.5): the only place a
/// bank, market, or issuer may be named is `data/rule_packs/`. Any hit
/// outside it is a leak that makes adding a bank require a code change in an
/// application-layer file. Word boundaries avoid false positives on ordinary
/// identifiers (`findById`, `destinations`); `LKR` counts only when used as
/// a literal default argument, per the milestone's wording.
void main() {
  const excludedDir = 'lib/features/transaction_parser/data/rule_packs/';
  final bankTokens = RegExp(
    r'\b(sampath|ndb|nations)\b|lk\.',
    caseSensitive: false,
  );
  // An assignment default (`= 'LKR'`), not a comparison (`!= 'LKR'`), which
  // is the milestone's wording for the currency-default leak.
  final lkrDefault = RegExp(r"(?<![!=])\s*=\s*'LKR'");

  test('no bank, market, or issuer name appears outside data/rule_packs/', () {
    final lib = Directory('lib');
    final hits = <String>[];

    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.contains(excludedDir)) continue;
      final content = entity.readAsStringSync();
      for (final match in bankTokens.allMatches(content)) {
        hits.add('${entity.path} → "${match.group(0)}"');
      }
      if (lkrDefault.hasMatch(content)) {
        hits.add('${entity.path} → "LKR literal default"');
      }
    }

    expect(hits, isEmpty, reason: 'bank names leak outside the pack directory');
  });

  test('no use case constructs a RulePackRegistry directly', () {
    final lib = Directory('lib');
    final hits = <String>[];

    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      if (!content.contains('RulePackRegistry(')) continue;
      final allowed =
          entity.path.endsWith('rule_pack_registry.dart') ||
          entity.path.endsWith('rule_pack_registry_repository.dart');
      if (!allowed) {
        hits.add(entity.path);
      }
    }

    expect(
      hits,
      isEmpty,
      reason: 'activation must flow through rulePackRegistryProvider',
    );
  });
}
