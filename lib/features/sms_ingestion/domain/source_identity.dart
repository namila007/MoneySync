import '../../../core/crypto/keyed_hmac.dart';

/// The only supported origins of a captured source message.
///
/// This is provenance, not identity: both paths must derive the same key for
/// the same provider message.
enum SmsIngestionSource { historySelection, broadcast }

/// Signs one canonical source-message pre-image. Implementations receive the
/// structured fields — never a pre-built string — and rebuild the canonical
/// byte encoding themselves, so callers cannot sign arbitrary bytes. The keyed
/// boundary keeps key material in the platform; Dart only ever sees digests.
typedef SourceIdentitySigner =
    Future<HmacDigest> Function({
      required int canonicalizationVersion,
      required String sender,
      required String body,
      required int receivedAtEpochMs,
    });

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
  const SourceMessageCanonicalizer({required this.signer});

  /// Identity-function version. Bumped when the canonical encoding changes
  /// (v1 → v2 in M4.14 WP4): existing rows keep their v1 keys, new rows get
  /// v2. Duplicate detection across that boundary is lost by design — that is
  /// exactly why the version is in the key.
  static const canonicalizationVersion = 2;

  final SourceIdentitySigner signer;

  Future<SourceMessageKey> identify(SmsSourceMessage message) async {
    final digest = await signer(
      canonicalizationVersion: canonicalizationVersion,
      sender: _normalizeSender(message.sender),
      body: _normalizeBody(message.body),
      receivedAtEpochMs: message.receivedAtUtc.millisecondsSinceEpoch,
    );
    return SourceMessageKey(
      canonicalizationVersion: canonicalizationVersion,
      value: 'v${canonicalizationVersion}_${digest.hex}',
    );
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
