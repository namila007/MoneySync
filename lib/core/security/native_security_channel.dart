import 'package:flutter/services.dart';

final class NativeSecurityChannel {
  const NativeSecurityChannel();

  static const _channelName = 'me.namila.money_sync/security';
  static const _channel = MethodChannel(_channelName);

  Future<String> getSensitiveDatabasePath() async {
    final result = await _channel.invokeMethod<String>(
      'getSensitiveDatabasePath',
    );
    if (result == null) throw const NativeChannelUnavailableException();
    return result;
  }

  Future<void> ensureContentKey() async {
    try {
      await _channel.invokeMethod('ensureContentKey');
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  /// Returns the raw content-key bytes unwrapped from the platform Keystore.
  /// Callers must consume this exactly once via [DatabaseKeyHandle] and
  /// never persist, log, or hex-encode it beyond the single point of use.
  Future<Uint8List> acquireContentKeyBytes() async {
    try {
      final result = await _channel.invokeMethod<Uint8List>(
        'acquireContentKeyBytes',
      );
      if (result == null) throw const NativeChannelUnavailableException();
      // The platform channel codec can return a read-only view over its own
      // decode buffer; copy into a fresh, independently mutable buffer so
      // DatabaseKeyHandle.useAndDispose can zeroize it after use.
      return Uint8List.fromList(result);
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  /// Signs a typed, bounded [request] using a non-exportable AndroidKeyStore
  /// HMAC key. Unlike the previous free-form `canonicalInput: String`, every
  /// field here is length/charset-validated in Dart (defense in depth) and
  /// re-validated natively, and the canonical byte encoding is built in
  /// Kotlin — the caller cannot supply an arbitrary pre-built string to sign.
  Future<String> deriveSourceIdentityDigest({
    required SourceIdentityCanonicalizationRequest request,
    required int canonicalizationVersion,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'deriveSourceIdentityDigest',
        request._toChannelArguments(canonicalizationVersion),
      );
      if (result == null) throw const NativeChannelUnavailableException();
      return result;
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  Future<void> deleteKeys() async {
    try {
      await _channel.invokeMethod('deleteKeys');
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  /// Applies FLAG_SECURE on the app window at runtime. Enabling is always
  /// allowed; disabling requires the persisted user preference.
  Future<void> setSecureWindowProtection({required bool enabled}) async {
    try {
      await _channel.invokeMethod('setSecureWindowProtection', {
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  Future<void> storeWalletToken(String tokenHex) async {
    try {
      await _channel.invokeMethod('storeWalletToken', tokenHex);
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  Future<String> loadWalletToken() async {
    try {
      final result = await _channel.invokeMethod<String>('loadWalletToken');
      if (result == null) throw const NativeChannelUnavailableException();
      return result;
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  Future<void> deleteWalletToken() async {
    try {
      await _channel.invokeMethod('deleteWalletToken');
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }
}

/// Bounded, typed fields for source-identity HMAC canonicalization. Every
/// field is validated before it ever reaches the platform channel; native
/// code re-validates independently and never trusts a pre-built string.
/// The canonical byte encoding (length-prefixed fields, version first) is
/// rebuilt natively and mirrors `SourceMessageCanonicalizer` exactly.
final class SourceIdentityCanonicalizationRequest {
  const SourceIdentityCanonicalizationRequest({
    required this.senderAddress,
    required this.body,
    required this.occurredAtEpochMillis,
  });

  final String senderAddress;
  final String body;
  final int occurredAtEpochMillis;

  static const _maxSenderLength = 256;
  static const _maxBodyLength = 2000;

  Map<String, Object?> _toChannelArguments(int canonicalizationVersion) {
    _requireBoundedField(senderAddress, _maxSenderLength, 'senderAddress');
    _requireBoundedField(body, _maxBodyLength, 'body');
    if (occurredAtEpochMillis < 0) {
      throw ArgumentError('occurredAtEpochMillis must not be negative.');
    }
    return {
      'senderAddress': senderAddress,
      'body': body,
      'occurredAtEpochMillis': occurredAtEpochMillis,
      'canonicalizationVersion': canonicalizationVersion,
    };
  }

  static void _requireBoundedField(String value, int maxLength, String field) {
    if (value.isEmpty || value.length > maxLength) {
      throw ArgumentError('$field must be 1-$maxLength characters.');
    }
    if (value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
      throw ArgumentError('$field must not contain control characters.');
    }
  }
}

final class NativeChannelUnavailableException implements Exception {
  const NativeChannelUnavailableException();
}

final class NativeChannelKeyException implements Exception {
  const NativeChannelKeyException(this.code, this.message);
  final String code;
  final String message;
}
