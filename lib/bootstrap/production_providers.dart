import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/database/encrypted_database_opener.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/core/security/keystore_database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';

final nativeSecurityChannelProvider = Provider<NativeSecurityChannel>((ref) {
  return const NativeSecurityChannel();
});

final databaseKeyProvider = Provider<DatabaseKeyProvider>((ref) {
  final channel = ref.watch(nativeSecurityChannelProvider);
  return WrappedDatabaseKeyProvider(channel: channel);
});

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final channel = ref.watch(nativeSecurityChannelProvider);
  final keyProvider = ref.watch(databaseKeyProvider);
  final opener = ProductionEncryptedDatabaseOpener(
    channel: channel,
    keyProvider: keyProvider,
  );
  final db = await opener.open();
  ref.onDispose(() => db.close());
  return db;
});

final freshAuthPortProvider = FutureProvider<FreshAuthPort>((ref) async {
  return LocalAuthDeviceAuthenticator(auth: LocalAuthentication());
});
