import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';

void main() {
  final canonicalizer = SourceMessageCanonicalizer(
    signer: _inspectableSigner(),
  );

  SmsSourceMessage message({
    String sender = 'BANK-ALERT',
    String body = 'LKR 1,250.00 paid at Sample Store',
    DateTime? receivedAtUtc,
    String? providerRowId = '45',
    SmsIngestionSource source = SmsIngestionSource.historySelection,
  }) => SmsSourceMessage(
    sender: sender,
    body: body,
    receivedAtUtc: receivedAtUtc ?? DateTime.utc(2026, 7, 22, 8, 30),
    providerRowId: providerRowId,
    ingestionSource: source,
  );

  group('SourceMessageCanonicalizer', () {
    test(
      'derives one transport-independent key for history and broadcast',
      () async {
        final history = await canonicalizer.identify(
          message(
            sender: 'bank-alert',
            body: 'LKR 1,250.00\npaid at Sample Store',
            providerRowId: '45',
          ),
        );
        final broadcast = await canonicalizer.identify(
          message(
            sender: 'BANK-ALERT',
            body: 'LKR 1,250.00  paid at Sample Store',
            providerRowId: null,
            source: SmsIngestionSource.broadcast,
          ),
        );

        expect(broadcast, history);
      },
    );

    test('uses a frozen canonicalization version in the key', () async {
      final key = await canonicalizer.identify(message());

      expect(key.canonicalizationVersion, 2);
      expect(key.value, startsWith('v2_'));
      expect(key.value, matches(RegExp(r'^v2_[a-f0-9]{64}$')));
    });

    test('normalizes every supported Unicode whitespace variant', () async {
      const whitespaceRunes = <String>[
        '\t',
        '\n',
        '\r',
        '\u0085',
        '\u00a0',
        '\u1680',
        '\u2000',
        '\u200a',
        '\u2028',
        '\u2029',
        '\u202f',
        '\u205f',
        '\u3000',
      ];
      final baseline = await canonicalizer.identify(
        message(sender: 'bank alert', body: 'LKR 1250 at shop'),
      );

      for (final whitespace in whitespaceRunes) {
        final key = await canonicalizer.identify(
          message(
            sender: 'bank${whitespace}alert',
            body: 'LKR${whitespace}1250${whitespace}at${whitespace}shop',
          ),
        );

        expect(
          key,
          baseline,
          reason: 'failed for U+${whitespace.codeUnitAt(0).toRadixString(16)}',
        );
      }
    });

    test(
      'preserves non-whitespace Unicode while encoding URL-safe digests',
      () async {
        final changed = await canonicalizer.identify(
          message(sender: 'BANK 😁', body: 'Paid at Café'),
        );
        final reference = await canonicalizer.identify(
          message(sender: 'BANK 😀', body: 'Paid at Café'),
        );

        expect(reference, isNot(changed));
      },
    );

    test('does not use provider row ID as canonical identity', () async {
      final first = await canonicalizer.identify(message(providerRowId: '45'));
      final second = await canonicalizer.identify(
        message(providerRowId: '999'),
      );

      expect(second, first);
    });

    test('preserves the key across generated transport-only aliases', () async {
      final baseline = await canonicalizer.identify(message());

      for (var index = 0; index < 30; index += 1) {
        final key = await canonicalizer.identify(
          message(
            sender: index.isEven ? 'bank-alert' : 'BANK-ALERT',
            body: index.isEven
                ? 'LKR 1,250.00\tpaid at Sample Store'
                : 'LKR 1,250.00  paid at Sample Store',
            providerRowId: '$index',
            source: index.isEven
                ? SmsIngestionSource.broadcast
                : SmsIngestionSource.historySelection,
          ),
        );

        expect(key, baseline);
      }
    });

    test(
      'remains unchanged when a parser implementation is upgraded',
      () async {
        final beforeParserUpgrade = await canonicalizer.identify(message());
        final afterParserUpgrade = await canonicalizer.identify(message());

        expect(afterParserUpgrade, beforeParserUpgrade);
      },
    );

    test(
      'is stable across separate canonicalizer instances (restart)',
      () async {
        final first = await canonicalizer.identify(message());
        final second = await SourceMessageCanonicalizer(
          signer: _inspectableSigner(),
        ).identify(message());

        expect(second, first);
      },
    );

    test('separator injection cannot forge a collision', () async {
      // ("A|B", "C") vs ("A", "B|C") share no ambiguity in the length-prefixed
      // encoding: different field boundaries produce different pre-images.
      final first = await canonicalizer.identify(
        SmsSourceMessage(
          sender: 'A|B',
          body: 'C',
          receivedAtUtc: DateTime.utc(2026, 7, 22, 8, 30),
          ingestionSource: SmsIngestionSource.historySelection,
        ),
      );
      final second = await canonicalizer.identify(
        SmsSourceMessage(
          sender: 'A',
          body: 'B|C',
          receivedAtUtc: DateTime.utc(2026, 7, 22, 8, 30),
          ingestionSource: SmsIngestionSource.historySelection,
        ),
      );

      expect(first, isNot(second));
    });

    test('differs when only the timestamp differs', () async {
      final original = await canonicalizer.identify(message());
      final later = await canonicalizer.identify(
        message(receivedAtUtc: DateTime.utc(2026, 7, 22, 8, 31)),
      );

      expect(later, isNot(original));
    });

    test('rejects blank sender or body and non-UTC timestamps', () {
      expect(() => message(sender: '   '), throwsA(isA<ArgumentError>()));
      expect(() => message(body: ' \n '), throwsA(isA<ArgumentError>()));
      expect(
        () => message(receivedAtUtc: DateTime(2026, 7, 22, 8, 30)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('value objects compare complete values and hide digest material', () {
      const key = SourceMessageKey(canonicalizationVersion: 2, value: 'same');
      const evidence = SourceEvidenceKey('evidence');
      const identity = SourceMessageIdentity(
        sourceMessageKey: key,
        sourceEvidenceKey: evidence,
      );

      expect(
        key,
        const SourceMessageKey(canonicalizationVersion: 2, value: 'same'),
      );
      expect(
        key,
        isNot(
          const SourceMessageKey(canonicalizationVersion: 1, value: 'same'),
        ),
      );
      expect(
        key,
        isNot(
          const SourceMessageKey(canonicalizationVersion: 2, value: 'other'),
        ),
      );
      expect(evidence, const SourceEvidenceKey('evidence'));
      expect(evidence, isNot(const SourceEvidenceKey('other')));
      expect(
        identity,
        const SourceMessageIdentity(
          sourceMessageKey: key,
          sourceEvidenceKey: evidence,
        ),
      );
      expect(
        identity,
        isNot(
          const SourceMessageIdentity(
            sourceMessageKey: key,
            sourceEvidenceKey: SourceEvidenceKey('other'),
          ),
        ),
      );
      expect(
        key.hashCode,
        const SourceMessageKey(
          canonicalizationVersion: 2,
          value: 'same',
        ).hashCode,
      );
      expect(evidence.hashCode, const SourceEvidenceKey('evidence').hashCode);
      expect(key.toString(), 'SourceMessageKey(version: 2)');
      expect(evidence.toString(), 'SourceEvidenceKey()');
    });
  });

  group('SourceIdentityComparator', () {
    test('treats equal canonical and source-evidence keys as a duplicate', () {
      const identity = SourceMessageIdentity(
        sourceMessageKey: SourceMessageKey(
          canonicalizationVersion: 2,
          value: 'same',
        ),
        sourceEvidenceKey: SourceEvidenceKey('evidence'),
      );

      expect(
        SourceIdentityComparator.compare(identity, identity),
        const SourceIdentityComparison.duplicate(),
      );
    });

    test('fails safe as a collision when source evidence differs', () {
      const existing = SourceMessageIdentity(
        sourceMessageKey: SourceMessageKey(
          canonicalizationVersion: 2,
          value: 'canonical',
        ),
        sourceEvidenceKey: SourceEvidenceKey('evidence-a'),
      );
      const incoming = SourceMessageIdentity(
        sourceMessageKey: SourceMessageKey(
          canonicalizationVersion: 2,
          value: 'canonical',
        ),
        sourceEvidenceKey: SourceEvidenceKey('evidence-b'),
      );

      final comparison = SourceIdentityComparator.compare(existing, incoming);

      expect(comparison, isA<SourceIdentityCollision>());
      expect(
        (comparison as SourceIdentityCollision).collisionSuffix,
        startsWith('collision-'),
      );
      expect(comparison.canonicalKey, existing.sourceMessageKey);
      expect(
        comparison.collisionSuffix,
        'collision-${incoming.sourceEvidenceKey.value}',
      );
    });

    test('treats different canonical keys as distinct captures', () {
      const first = SourceMessageIdentity(
        sourceMessageKey: SourceMessageKey(
          canonicalizationVersion: 2,
          value: 'one',
        ),
        sourceEvidenceKey: SourceEvidenceKey('evidence'),
      );
      const second = SourceMessageIdentity(
        sourceMessageKey: SourceMessageKey(
          canonicalizationVersion: 2,
          value: 'two',
        ),
        sourceEvidenceKey: SourceEvidenceKey('evidence'),
      );

      expect(
        SourceIdentityComparator.compare(first, second),
        const SourceIdentityComparison.distinct(),
      );
    });
  });
}

/// Deterministic signer: sha256 over the length-prefixed pre-image, stable
/// across instances — exactly what identity stability tests need.
SourceIdentitySigner _inspectableSigner() {
  return ({
    required int canonicalizationVersion,
    required String sender,
    required String body,
    required int receivedAtEpochMs,
  }) async {
    final fields = <String>[sender, body, receivedAtEpochMs.toString()];
    final preimage = StringBuffer('v$canonicalizationVersion');
    for (final field in fields) {
      preimage
        ..write('|')
        ..write(field.length)
        ..write(':')
        ..write(field);
    }
    return HmacDigest(
      sha256.convert(utf8.encode(preimage.toString())).toString(),
    );
  };
}
