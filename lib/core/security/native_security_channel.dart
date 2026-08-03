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
final class SourceIdentityCanonicalizationRequest {
  const SourceIdentityCanonicalizationRequest({
    required this.senderAddress,
    required this.messageFamily,
    required this.maskedInstrumentEvidence,
    required this.occurredAtEpochSeconds,
  });

  final String senderAddress;
  final String messageFamily;
  final String maskedInstrumentEvidence;
  final int occurredAtEpochSeconds;

  static const _maxFieldLength = 256;

  Map<String, Object?> _toChannelArguments(int canonicalizationVersion) {
    for (final field in [
      senderAddress,
      messageFamily,
      maskedInstrumentEvidence,
    ]) {
      _requireBoundedField(field);
    }
    if (occurredAtEpochSeconds < 0) {
      throw ArgumentError('occurredAtEpochSeconds must not be negative.');
    }
    return {
      'senderAddress': senderAddress,
      'messageFamily': messageFamily,
      'maskedInstrumentEvidence': maskedInstrumentEvidence,
      'occurredAtEpochSeconds': occurredAtEpochSeconds,
      'canonicalizationVersion': canonicalizationVersion,
    };
  }

  static void _requireBoundedField(String value) {
    if (value.isEmpty || value.length > _maxFieldLength) {
      throw ArgumentError(
        'Canonicalization fields must be 1-$_maxFieldLength characters.',
      );
    }
    if (value.codeUnits.any((unit) => unit < 0x20 || unit == 0x7f)) {
      throw ArgumentError(
        'Canonicalization fields must not contain control characters.',
      );
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
