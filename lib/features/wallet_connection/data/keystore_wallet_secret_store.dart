import 'dart:convert';

import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

final class KeystoreWalletSecretStore implements WalletSecretStore {
  KeystoreWalletSecretStore({required this.channel});

  final NativeSecurityChannel channel;

  @override
  Future<void> save(WalletToken token) async {
    final bytes = utf8.encode(token.toPersistenceString());
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await channel.storeWalletToken(hex);
  }

  @override
  Future<void> clear() async {
    await channel.deleteWalletToken();
  }

  @override
  Future<T> useSecret<T>(
    Future<T> Function(WalletToken token) operation,
  ) async {
    final hex = await channel.loadWalletToken();
    final bytes = List<int>.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    );
    final tokenStr = utf8.decode(bytes);
    final token = WalletToken.parse(tokenStr);
    try {
      return await operation(token);
    } finally {}
  }
}
