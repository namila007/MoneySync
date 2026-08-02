import 'dart:typed_data';

/// Single-use holder for raw database key bytes unwrapped from the platform
/// Keystore. The key is consumed exactly once via [useAndDispose], which
/// zeroizes the buffer immediately afterward and rejects a second use. There
/// is no accessor that exposes the bytes as a `String`/hex outside that one
/// callback — see docs/adr/0001-native-database-key-boundary.md.
final class DatabaseKeyHandle {
  DatabaseKeyHandle(Uint8List bytes) : _bytes = _validateBytes(bytes);

  Uint8List? _bytes;

  static Uint8List _validateBytes(Uint8List value) {
    if (value.isEmpty) {
      throw ArgumentError('Database key bytes must not be empty.');
    }
    return value;
  }

  /// Consumes the raw key bytes exactly once, zeroizing them afterward.
  /// Throws [StateError] if called more than once.
  T useAndDispose<T>(T Function(Uint8List bytes) action) {
    final bytes = _bytes;
    if (bytes == null) {
      throw StateError('Database key handle has already been consumed.');
    }
    _bytes = null;
    try {
      return action(bytes);
    } finally {
      bytes.fillRange(0, bytes.length, 0);
    }
  }
}

enum DatabaseKeyUnavailableReason { locked, missing, invalidated, lost }

sealed class DatabaseKeyAccess {
  const DatabaseKeyAccess();

  bool get isAvailable;

  DatabaseKeyHandle requireKey();
}

final class DatabaseKeyAvailable extends DatabaseKeyAccess {
  const DatabaseKeyAvailable(this.key);

  final DatabaseKeyHandle key;

  @override
  bool get isAvailable => true;

  @override
  DatabaseKeyHandle requireKey() => key;
}

final class DatabaseKeyUnavailable extends DatabaseKeyAccess {
  const DatabaseKeyUnavailable(this.reason);

  final DatabaseKeyUnavailableReason reason;

  @override
  bool get isAvailable => false;

  @override
  DatabaseKeyHandle requireKey() =>
      throw DatabaseKeyUnavailableException(reason);
}

final class DatabaseKeyUnavailableException implements Exception {
  const DatabaseKeyUnavailableException(this.reason);

  final DatabaseKeyUnavailableReason reason;
}

/// Platform adapters expose only a typed result; there is no plaintext fallback.
abstract interface class DatabaseKeyProvider {
  Future<DatabaseKeyAccess> acquire();
}
