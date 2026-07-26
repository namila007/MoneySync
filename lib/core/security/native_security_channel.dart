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

  Future<String> acquireContentKeyHex() async {
    try {
      final result = await _channel.invokeMethod<String>(
        'acquireContentKeyHex',
      );
      if (result == null) throw const NativeChannelUnavailableException();
      return result;
    } on PlatformException catch (e) {
      throw NativeChannelKeyException(e.code, e.message ?? '');
    }
  }

  Future<String> deriveSourceIdentityDigest({
    required String canonicalInput,
    required int canonicalizationVersion,
  }) async {
    try {
      final result = await _channel
          .invokeMethod<String>('deriveSourceIdentityDigest', {
            'canonicalInput': canonicalInput,
            'canonicalizationVersion': canonicalizationVersion,
          });
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

final class NativeChannelUnavailableException implements Exception {
  const NativeChannelUnavailableException();
}

final class NativeChannelKeyException implements Exception {
  const NativeChannelKeyException(this.code, this.message);
  final String code;
  final String message;
}
