/// Opaque reference to a keystore-backed database key, never plaintext bytes.
final class DatabaseKeyHandle {
  DatabaseKeyHandle(String id) : id = _validateId(id);

  final String id;

  static String _validateId(String value) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(value)) {
      throw ArgumentError('Key handle IDs must be opaque safe IDs.');
    }
    return value;
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
