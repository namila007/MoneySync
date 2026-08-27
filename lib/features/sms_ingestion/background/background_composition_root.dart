import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/core/database/app_database.dart'
    hide TransactionCandidate;
import 'package:money_sync/core/database/encrypted_database_opener.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/core/security/keystore_database_key_provider.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/mappings/data/drift_mapping_rule_store.dart';
import 'package:money_sync/features/mappings/domain/auto_create_or_defer.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/notifications/data/flutter_local_notifications_service.dart';
import 'package:money_sync/features/notifications/domain/notification_service.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/sms_ingestion/data/native_source_identity_signer.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/scan_tracked_senders.dart';
import 'package:money_sync/features/sms_tracking/data/drift_tracked_senders_repository.dart';
import 'package:money_sync/features/transaction_parser/data/rule_pack_registry_repository.dart';
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_capability_ledger.dart';
import 'package:logging/logging.dart';

final _log = Logger('sms.background');

/// Builds an isolate-local [ScanTrackedSenders] instance for background
/// execution. Each call opens its own encrypted database connection and
/// notification service — nothing is shared with the foreground engine.
///
/// In tests, call [buildFromDatabase] to inject an in-memory database and
/// skip the platform-dependent opener.
class BackgroundCompositionRoot {
  BackgroundCompositionRoot({
    NativeSecurityChannel? channel,
    this._keyProvider,
    this._notificationService,
  }) : _channel = channel ?? const NativeSecurityChannel();

  final NativeSecurityChannel _channel;
  final DatabaseKeyProvider? _keyProvider;
  final NotificationService? _notificationService;

  /// Opens a fresh encrypted database, sets WAL + busy_timeout, and
  /// wires all dependencies into [ScanTrackedSenders].
  Future<ScanTrackedSenders> build() async {
    final keyProvider =
        _keyProvider ?? WrappedDatabaseKeyProvider(channel: _channel);
    final opener = ProductionEncryptedDatabaseOpener(
      channel: _channel,
      keyProvider: keyProvider,
    );
    final db = await opener.open();
    await _configureDatabase(db);
    return _buildFromDatabase(db);
  }

  /// Builds [ScanTrackedSenders] from an already-opened [AppDatabase].
  /// Use in tests to inject an in-memory database.
  Future<ScanTrackedSenders> buildFromDatabase(AppDatabase db) async {
    return _buildFromDatabase(db);
  }

  Future<ScanTrackedSenders> _buildFromDatabase(AppDatabase db) async {
    final notifications =
        _notificationService ?? await _createNotificationService();

    final signer = NativeSourceIdentitySigner(channel: _channel).digest;
    final registry = await RulePackRegistryRepository(
      database: db,
    ).loadActiveRegistry();

    return ScanTrackedSenders(
      database: db,
      smsHistoryApi: SmsHistoryHostApi(),
      registry: registry,
      identitySigner: signer,
      notificationService: notifications,
      trackedSendersRepository: DriftTrackedSendersRepository(database: db),
      candidateHook:
          (candidate, eventId, candidatePayload, normalizedSender) async {
            try {
              final setting = await (db.select(
                db.appSettings,
              )..where((row) => row.singletonId.equals(1))).getSingle();
              if (!setting.autoCreateEnabled) return false;

              final store = DriftMappingRuleStore(database: db);
              final rules = await store.list();
              const caps = AppCapabilities.m6PrivateFull();

              final cache = DriftWalletCatalogCache(database: db);
              final catalog = await cache.read();

              final writer = DriftReviewOutboxWriter(database: db);
              final capabilityRows = await db.select(db.capabilityLedger).get();
              final evidence = <WalletCapabilityEvidence>[
                for (final row in capabilityRows)
                  if (_toCapability(row.capability) case final c?)
                    WalletCapabilityEvidence(
                      capability: c,
                      outcome: _toOutcome(row.status),
                      observedAt:
                          DateTime.tryParse(row.observedOn) ?? DateTime.now(),
                      contractVersion: _contractVersion,
                    ),
              ];
              final capabilityCanCreate =
                  WalletCapabilityLedger(evidence: evidence).canCreate(
                    now: DateTime.now().toUtc(),
                    compatibleContractVersion: _contractVersion,
                  );

              final event = await db.getSmsEventById(eventId);
              final privacyEpochMatches =
                  (event?.privacyEpoch ?? setting.privacyEpoch) ==
                  setting.privacyEpoch;

              final candidateId = 'candidate-$eventId';
              final hasActiveLineage = await writer.hasActiveLineage(
                candidateId,
              );
              final linkRows = await (db.select(
                db.walletRecordLinks,
              )..where((row) => row.candidateId.equals(candidateId))).get();

              final resolver = MappingRuleResolver(rules: rules);
              final resolution = resolver.resolve(
                MappingResolutionInput(
                  senderNormalized: normalizedSender,
                  confidenceBasisPoints: candidate.confidence.basisPoints,
                  merchantNormalized: candidate.counterParty ?? '',
                  direction: candidate.direction,
                ),
              );

              WalletAccount? targetAccount;
              if (resolution case MappingResolved(:final rule)) {
                if (catalog != null) {
                  for (final a in catalog.accounts) {
                    if (a.id == rule.walletAccountId) {
                      targetAccount = a;
                      break;
                    }
                  }
                }
              }

              final autoCreate = AutoCreateOrDefer(
                eligibilityPolicy: const WalletCreateEligibilityPolicy(),
                outboxWriter: writer,
                capabilities: caps,
                autoCreateEnabled: true,
                resolveRules: (_) async => rules,
                buildPreSendContext: (_) async => PreSendContext(
                  candidateId: candidateId,
                  amountMinor: candidate.originalAmount.minorUnits,
                  currencyCode: candidate.originalAmount.currency.code,
                  recordDateUtc: candidate.transactionAtUtc,
                  direction: candidate.direction,
                  paymentType: 'debit_card',
                  senderNormalized: normalizedSender,
                  confidenceBasisPoints: candidate.confidence.basisPoints,
                  privacyEpochMatches: privacyEpochMatches,
                  consentCurrent:
                      setting.disclosureAccepted && setting.onboardingCompleted,
                  connectionConnected:
                      catalog != null && catalog.accounts.isNotEmpty,
                  eligibleTargetAccount:
                      targetAccount != null &&
                      targetAccount.isWritable &&
                      targetAccount.eligibility ==
                          WalletAccountEligibility.eligible,
                  targetAccountEligibility:
                      targetAccount?.eligibility ??
                      WalletAccountEligibility.missingRequiredFields,
                  mappingResolution: resolution,
                  capabilityCanCreate: capabilityCanCreate,
                  hasActiveLineage: hasActiveLineage,
                  hasOwnedRecordLink: linkRows.isNotEmpty,
                ),
              );
              final outcome = await autoCreate(
                candidate,
                senderNormalized: normalizedSender,
                smsEventId: eventId,
                candidatePayload: candidatePayload,
              );
              return outcome is AutoCreated;
            } catch (e) {
              _log.warning('Auto-create hook failed', e);
              return false;
            }
          },
    );
  }

  Future<NotificationService> _createNotificationService() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final service = FlutterLocalNotificationsService(plugin: plugin);
    await service.initialize(androidDefaultIcon: '@mipmap/ic_launcher');
    return service;
  }

  Future<void> _configureDatabase(AppDatabase db) async {
    await db.customStatement('PRAGMA journal_mode = WAL');
    await db.customStatement('PRAGMA busy_timeout = 5000');
  }
}

const _contractVersion = 'v1.3.0';

WalletRemoteCapability? _toCapability(String value) =>
    WalletRemoteCapability.values.where((c) => c.name == value).firstOrNull;

WalletCapabilityOutcome _toOutcome(String value) => switch (value) {
  'pass' => WalletCapabilityOutcome.pass,
  'fail' => WalletCapabilityOutcome.fail,
  _ => WalletCapabilityOutcome.unknown,
};
