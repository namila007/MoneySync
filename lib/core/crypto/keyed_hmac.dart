import 'dart:collection';

/// Opaque reference to keystore-backed HMAC material; it is never key bytes.
final class HmacKeyHandle {
  HmacKeyHandle(String id) : id = _validateId(id);

  final String id;

  static String _validateId(String value) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(value)) {
      throw ArgumentError('Key handle IDs must be opaque safe IDs.');
    }
    return value;
  }
}

/// Immutable bytes supplied to an HMAC implementation for one calculation.
final class HmacInput {
  HmacInput(Iterable<int> bytes)
    : bytes = UnmodifiableListView(List<int>.of(bytes)) {
    if (this.bytes.any((byte) => byte < 0 || byte > 255)) {
      throw ArgumentError('HMAC input must contain byte values.');
    }
  }

  final List<int> bytes;
}

/// The fixed hexadecimal representation of an HMAC-SHA-256 digest.
final class HmacDigest {
  HmacDigest(String hex) : hex = _validateHex(hex);

  final String hex;

  static String _validateHex(String value) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
      throw ArgumentError('Digest must be 64 lowercase hex characters.');
    }
    return value;
  }
}

/// A cryptographic boundary; platform implementations must use the key handle.
/// Async because platform key material is reached through asynchronous
/// channels; implementations must never materialize the key in Dart.
abstract interface class KeyedHmac {
  Future<HmacDigest> digest({
    required HmacKeyHandle key,
    required HmacInput input,
  });
}
