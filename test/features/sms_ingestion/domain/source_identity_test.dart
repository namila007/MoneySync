import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/crypto/keyed_hmac.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';

void main() {
  final canonicalizer = SourceMessageCanonicalizer(
    keyedHmac: const _InspectableKeyedHmac(),
    key: HmacKeyHandle('source_identity_test'),
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
    test('derives one transport-independent key for history and broadcast', () {
      final history = canonicalizer.identify(
        message(
          sender: 'bank-alert',
          body: 'LKR 1,250.00\npaid at Sample Store',
          providerRowId: '45',
        ),
      );
      final broadcast = canonicalizer.identify(
        message(
          sender: 'BANK-ALERT',
          body: 'LKR 1,250.00  paid at Sample Store',
          providerRowId: null,
          source: SmsIngestionSource.broadcast,
        ),
      );

      expect(broadcast.sourceMessageKey, history.sourceMessageKey);
      expect(broadcast.sourceEvidenceKey, history.sourceEvidenceKey);
    });

    test('uses a frozen canonicalization version in the key', () {
      final identity = canonicalizer.identify(message());

      expect(identity.sourceMessageKey.canonicalizationVersion, 1);
      expect(identity.sourceMessageKey.value, startsWith('v1_'));
    });

    test('normalizes every supported Unicode whitespace variant', () {
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
      final baseline = canonicalizer.identify(
        message(sender: 'bank alert', body: 'LKR 1250 at shop'),
      );

      for (final whitespace in whitespaceRunes) {
        final identity = canonicalizer.identify(
          message(
            sender: 'bank${whitespace}alert',
            body: 'LKR${whitespace}1250${whitespace}at${whitespace}shop',
          ),
        );

        expect(
          identity,
          baseline,
          reason: 'failed for U+${whitespace.codeUnitAt(0).toRadixString(16)}',
        );
      }
    });

    test(
      'preserves non-whitespace Unicode while encoding URL-safe MAC digests',
      () {
        final byteCanonicalizer = SourceMessageCanonicalizer(
          keyedHmac: const _FixedDigestKeyedHmac(),
          key: HmacKeyHandle('fixed_digest_test'),
        );
        final reference = canonicalizer.identify(
          message(sender: 'BANK 😀', body: 'Paid at Café'),
        );
        final changed = canonicalizer.identify(
          message(sender: 'BANK 😁', body: 'Paid at Café'),
        );
        final encoded = byteCanonicalizer.identify(
          message(sender: 'BANK 😀', body: 'Paid at Café'),
        );

        expect(reference.sourceMessageKey, isNot(changed.sourceMessageKey));
        expect(
          encoded.sourceMessageKey.value,
          matches(RegExp(r'^v1_[A-Za-z0-9_-]+$')),
        );
        expect(
          encoded.sourceEvidenceKey.value,
          matches(RegExp(r'^[A-Za-z0-9_-]+$')),
        );
        expect(encoded.sourceMessageKey.value, isNot(contains('=')));
        expect(encoded.sourceEvidenceKey.value, isNot(contains('=')));
      },
    );

    test('does not use provider row ID as canonical identity', () {
      final first = canonicalizer.identify(message(providerRowId: '45'));
      final second = canonicalizer.identify(message(providerRowId: '999'));

      expect(second, first);
    });

    test('preserves the key across generated transport-only aliases', () {
      final baseline = canonicalizer.identify(message());

      for (var index = 0; index < 30; index += 1) {
        final alias = canonicalizer.identify(
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

        expect(alias, baseline);
      }
    });

    test('remains unchanged when a parser implementation is upgraded', () {
      final beforeParserUpgrade = canonicalizer.identify(message());
      final afterParserUpgrade = canonicalizer.identify(message());

      expect(afterParserUpgrade, beforeParserUpgrade);
    });

    test('does not merge distinct canonical source evidence', () {
      final original = canonicalizer.identify(message());
      final differentBody = canonicalizer.identify(
        message(body: 'LKR 1,251.00 paid at Sample Store'),
      );
      final differentTimestamp = canonicalizer.identify(
        message(receivedAtUtc: DateTime.utc(2026, 7, 22, 8, 31)),
      );

      expect(differentBody.sourceMessageKey, isNot(original.sourceMessageKey));
      expect(
        differentTimestamp.sourceMessageKey,
        isNot(original.sourceMessageKey),
      );
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
      const key = SourceMessageKey(canonicalizationVersion: 1, value: 'same');
      const evidence = SourceEvidenceKey('evidence');
      const identity = SourceMessageIdentity(
        sourceMessageKey: key,
        sourceEvidenceKey: evidence,
      );

      expect(
        key,
        const SourceMessageKey(canonicalizationVersion: 1, value: 'same'),
      );
      expect(
        key,
        isNot(
          const SourceMessageKey(canonicalizationVersion: 2, value: 'same'),
        ),
      );
      expect(
        key,
        isNot(
          const SourceMessageKey(canonicalizationVersion: 1, value: 'other'),
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
          canonicalizationVersion: 1,
          value: 'same',
        ).hashCode,
      );
      expect(evidence.hashCode, const SourceEvidenceKey('evidence').hashCode);
      expect(key.toString(), 'SourceMessageKey(version: 1)');
      expect(evidence.toString(), 'SourceEvidenceKey()');
    });
  });

  group('SourceIdentityComparator', () {
    test('treats equal canonical and source-evidence keys as a duplicate', () {
      final identity = canonicalizer.identify(message());

      expect(
        SourceIdentityComparator.compare(identity, identity),
        const SourceIdentityComparison.duplicate(),
      );
    });

    test('fails safe as a collision when source evidence differs', () {
      final collisionCanonicalizer = SourceMessageCanonicalizer(
        keyedHmac: const _CollidingCanonicalKeyedHmac(),
        key: HmacKeyHandle('collision_test'),
      );
      final existing = collisionCanonicalizer.identify(message(body: 'first'));
      final incoming = collisionCanonicalizer.identify(message(body: 'second'));

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
      final first = canonicalizer.identify(message());
      final second = canonicalizer.identify(message(body: 'different'));

      expect(
        SourceIdentityComparator.compare(first, second),
        const SourceIdentityComparison.distinct(),
      );
    });
  });
}

final class _InspectableKeyedHmac implements KeyedHmac {
  const _InspectableKeyedHmac();

  @override
  HmacDigest digest({required HmacKeyHandle key, required HmacInput input}) {
    var seed = key.id.codeUnits.fold<int>(0, (sum, byte) => sum + byte);
    for (final byte in input.bytes) {
      seed = ((seed * 31) + byte) & 0x7fffffff;
    }
    final bytes = List<int>.generate(
      32,
      (index) => (seed + (index * 37)) & 0xff,
    );
    return HmacDigest(_hex(bytes));
  }
}

final class _CollidingCanonicalKeyedHmac implements KeyedHmac {
  const _CollidingCanonicalKeyedHmac();

  @override
  HmacDigest digest({required HmacKeyHandle key, required HmacInput input}) {
    final text = utf8.decode(input.bytes);
    if (text.startsWith('money-sync/source-message-key/')) {
      return HmacDigest('00' * 32);
    }
    return const _InspectableKeyedHmac().digest(key: key, input: input);
  }
}

final class _FixedDigestKeyedHmac implements KeyedHmac {
  const _FixedDigestKeyedHmac();

  @override
  HmacDigest digest({required HmacKeyHandle key, required HmacInput input}) =>
      HmacDigest('ff' * 32);
}

String _hex(Iterable<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
