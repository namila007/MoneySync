import 'dart:convert';

import '../../../core/crypto/keyed_hmac.dart';

/// The only supported origins of a captured source message.
///
/// This is provenance, not identity: both paths must derive the same key for
/// the same provider message.
enum SmsIngestionSource { historySelection, broadcast }

/// A read-only copy of the fields required to identify an Android SMS source.
///
/// [providerRowId] is retained as an alias for diagnostics and paging only. It
/// is deliberately excluded from every identity calculation.
final class SmsSourceMessage {
  SmsSourceMessage({
    required this.sender,
    required this.body,
    required this.receivedAtUtc,
    required this.ingestionSource,
    this.providerRowId,
  }) {
    if (sender.trim().isEmpty) {
      throw ArgumentError.value(sender, 'sender', 'must not be blank');
    }
    if (body.trim().isEmpty) {
      throw ArgumentError.value(body, 'body', 'must not be blank');
    }
    if (!receivedAtUtc.isUtc) {
      throw ArgumentError.value(
        receivedAtUtc,
        'receivedAtUtc',
        'must be a UTC instant',
      );
    }
  }

  final String sender;
  final String body;
  final DateTime receivedAtUtc;
  final String? providerRowId;
  final SmsIngestionSource ingestionSource;
}

/// Versioned, opaque HMAC identity for one source message.
final class SourceMessageKey {
  const SourceMessageKey({
    required this.canonicalizationVersion,
    required this.value,
  });

  final int canonicalizationVersion;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is SourceMessageKey &&
      other.canonicalizationVersion == canonicalizationVersion &&
      other.value == value;

  @override
  int get hashCode => Object.hash(canonicalizationVersion, value);

  @override
  String toString() => 'SourceMessageKey(version: $canonicalizationVersion)';
}

/// Opaque evidence used only to fail safe when a canonical HMAC collision is
/// detected. It is not a provider ID and is never shown to the user.
final class SourceEvidenceKey {
  const SourceEvidenceKey(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is SourceEvidenceKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SourceEvidenceKey()';
}

/// The stable key plus independently MACed source evidence.
final class SourceMessageIdentity {
  const SourceMessageIdentity({
    required this.sourceMessageKey,
    required this.sourceEvidenceKey,
  });

  final SourceMessageKey sourceMessageKey;
  final SourceEvidenceKey sourceEvidenceKey;

  @override
  bool operator ==(Object other) =>
      other is SourceMessageIdentity &&
      other.sourceMessageKey == sourceMessageKey &&
      other.sourceEvidenceKey == sourceEvidenceKey;

  @override
  int get hashCode => Object.hash(sourceMessageKey, sourceEvidenceKey);
}

/// Derives the frozen transport-independent SMS identity.
///
/// Parser identifiers, parsing rules, provider row IDs, SIM hints, and capture
/// path are excluded by construction so later parser work cannot create a
/// duplicate source event.
final class SourceMessageCanonicalizer {
  const SourceMessageCanonicalizer({
    required this.keyedHmac,
    required this.key,
  });

  static const canonicalizationVersion = 1;

  final KeyedHmac keyedHmac;
  final HmacKeyHandle key;

  SourceMessageIdentity identify(SmsSourceMessage message) {
    final canonicalBytes = _canonicalBytes(message);
    final sourceMac = keyedHmac.digest(
      key: key,
      input: HmacInput(<int>[
        ...utf8.encode(
          'money-sync/source-message-key/v$canonicalizationVersion\n',
        ),
        ...canonicalBytes,
      ]),
    );
    final evidenceMac = keyedHmac.digest(
      key: key,
      input: HmacInput(<int>[
        ...utf8.encode(
          'money-sync/source-evidence/v$canonicalizationVersion\n',
        ),
        ...canonicalBytes,
      ]),
    );

    return SourceMessageIdentity(
      sourceMessageKey: SourceMessageKey(
        canonicalizationVersion: canonicalizationVersion,
        value: 'v${canonicalizationVersion}_${sourceMac.hex}',
      ),
      sourceEvidenceKey: SourceEvidenceKey(evidenceMac.hex),
    );
  }

  List<int> _canonicalBytes(SmsSourceMessage message) {
    final fields = <String>[
      _normalizeSender(message.sender),
      _normalizeBody(message.body),
      message.receivedAtUtc.millisecondsSinceEpoch.toString(),
    ];
    final payload = StringBuffer('v$canonicalizationVersion');
    for (final field in fields) {
      payload
        ..write('|')
        ..write(field.length)
        ..write(':')
        ..write(field);
    }
    return utf8.encode(payload.toString());
  }

  String _normalizeSender(String sender) =>
      _normalizeWhitespace(sender).toLowerCase();

  String _normalizeBody(String body) => _normalizeWhitespace(body);

  String _normalizeWhitespace(String value) {
    final normalized = StringBuffer();
    var previousWasWhitespace = true;

    for (final rune in value.runes) {
      if (_isWhitespace(rune)) {
        if (!previousWasWhitespace) {
          normalized.write(' ');
        }
        previousWasWhitespace = true;
      } else {
        normalized.writeCharCode(rune);
        previousWasWhitespace = false;
      }
    }
    return normalized.toString().trim();
  }

  bool _isWhitespace(int rune) =>
      (rune >= 0x0009 && rune <= 0x000d) ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x00a0 ||
      rune == 0x1680 ||
      (rune >= 0x2000 && rune <= 0x200a) ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202f ||
      rune == 0x205f ||
      rune == 0x3000;
}

sealed class SourceIdentityComparison {
  const SourceIdentityComparison();

  const factory SourceIdentityComparison.duplicate() = SourceIdentityDuplicate;
  const factory SourceIdentityComparison.distinct() = SourceIdentityDistinct;
}

final class SourceIdentityDuplicate extends SourceIdentityComparison {
  const SourceIdentityDuplicate();

  @override
  bool operator ==(Object other) => other is SourceIdentityDuplicate;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class SourceIdentityDistinct extends SourceIdentityComparison {
  const SourceIdentityDistinct();

  @override
  bool operator ==(Object other) => other is SourceIdentityDistinct;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// A collision must be retained for review with this opaque suffix rather than
/// being silently treated as a duplicate.
final class SourceIdentityCollision extends SourceIdentityComparison {
  const SourceIdentityCollision({
    required this.canonicalKey,
    required this.collisionSuffix,
  });

  final SourceMessageKey canonicalKey;
  final String collisionSuffix;
}

final class SourceIdentityComparator {
  const SourceIdentityComparator._();

  static SourceIdentityComparison compare(
    SourceMessageIdentity existing,
    SourceMessageIdentity incoming,
  ) {
    if (existing.sourceMessageKey != incoming.sourceMessageKey) {
      return const SourceIdentityComparison.distinct();
    }
    if (existing.sourceEvidenceKey == incoming.sourceEvidenceKey) {
      return const SourceIdentityComparison.duplicate();
    }
    return SourceIdentityCollision(
      canonicalKey: existing.sourceMessageKey,
      collisionSuffix: 'collision-${incoming.sourceEvidenceKey.value}',
    );
  }
}
