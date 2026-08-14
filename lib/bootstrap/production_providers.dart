import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/database/encrypted_database_opener.dart';
import 'package:money_sync/core/privacy/reset_recovery.dart';
import 'package:money_sync/core/privacy/reset_tombstone.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/core/security/keystore_database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_repository.dart';
import 'package:money_sync/features/sms_ingestion/data/native_source_identity_signer.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/transaction_parser/data/rule_pack_registry_repository.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/wallet_sync/data/fake_wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';

final nativeSecurityChannelProvider = Provider<NativeSecurityChannel>((ref) {
  return const NativeSecurityChannel();
});

/// Keystore-backed keyed HMAC for canonical source identity (M4.14 WP4).
final sourceIdentitySignerProvider = Provider<SourceIdentitySigner>((ref) {
  final channel = ref.watch(nativeSecurityChannelProvider);
  return NativeSourceIdentitySigner(channel: channel).digest;
});

final databaseKeyProvider = Provider<DatabaseKeyProvider>((ref) {
  final channel = ref.watch(nativeSecurityChannelProvider);
  return WrappedDatabaseKeyProvider(channel: channel);
});

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final channel = ref.watch(nativeSecurityChannelProvider);
  final keyProvider = ref.watch(databaseKeyProvider);

  // Recover from an interrupted reset before ever attempting to reopen the
  // encrypted database — if a prior reset died after keys were deleted but
  // before the tombstone was cleared, opening now would otherwise surface
  // as an opaque "could not open local data" error rather than a
  // recognized, resumable interruption. See reset_recovery.dart.
  final databasePath = await channel.getSensitiveDatabasePath();
  final recovery = InterruptedResetRecovery(
    channel: channel,
    databasePath: databasePath,
    tombstone: ResetTombstone(databasePath: databasePath),
  );
  await recovery.recoverIfNeeded();

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

final onboardingRepositoryProvider = FutureProvider<OnboardingRepository>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftOnboardingRepository(database: db);
});

/// Active rule packs as data: the `rule_packs` table's `enabled` flag decides
/// selection; packs absent from the table are registered on first run
/// (M4.14 WP5). No use case constructs a [RulePackRegistry] directly.
final rulePackRegistryProvider = FutureProvider<RulePackRegistry>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return RulePackRegistryRepository(database: db).loadActiveRegistry();
});

/// The Wallet create/reconcile repository. M5 ships against the fake data
/// source — the live contract spike (M5.7) has not closed, so real network
/// calls stay disabled (`ProductionDisabledWalletMutationPort` remains the
/// `WalletMutationPort`; this provider feeds the outbox flows with the fake).
/// Swap the `FakeWalletApiDataSource` for the live implementation here when
/// M5.7 closes behind a feature flag.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(dataSource: FakeWalletApiDataSource());
});
