/// An opaque Wallet API token. Its value is intentionally never printable.
final class WalletToken {
  WalletToken._(this._value);

  final String _value;

  static WalletToken parse(String value) {
    if (value.isEmpty ||
        value.length > 8192 ||
        value.trim() != value ||
        value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
      throw const FormatException('Token input is invalid.');
    }
    return WalletToken._(value);
  }

  static WalletToken? tryParse(String value) {
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  /// Used only by the audited Wallet request guard after it validates the
  /// final HTTPS origin, path, method, and redirect policy.
  void attachBearerToAuditedRequest(Map<String, dynamic> headers) {
    headers['Authorization'] = 'Bearer $_value';
  }

  /// Used only by the Keystore-backed secret store for native persistence.
  /// Never call this from presentation or application layers.
  String toPersistenceString() => _value;

  @override
  String toString() => 'WalletToken(***)';
}

/// Stores an opaque credential in the platform secure-storage implementation.
abstract interface class WalletSecretStore {
  Future<void> save(WalletToken token);

  Future<T> useSecret<T>(Future<T> Function(WalletToken token) operation);

  Future<void> clear();
}

/// Requires a fresh device-authentication challenge before sensitive changes.
abstract interface class FreshAuthPort {
  Future<bool> authenticateForWalletTokenChange();
}
