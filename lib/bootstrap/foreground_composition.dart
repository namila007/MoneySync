import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/bootstrap/startup_state.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/database/database_health.dart';
import 'package:money_sync/core/logging/activity_writer_generation.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/core/privacy/clear_local_data.dart';
import 'package:money_sync/core/privacy/retention_policy.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/core/security/foreground_lock.dart';
import 'package:money_sync/core/scheduling/auto_import_scheduler.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/data_control/application/clear_local_data.dart'
    as data_control;
import 'package:money_sync/features/data_control/presentation/data_control_controller.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:money_sync/features/settings/data/drift_configuration_repository.dart';
import 'package:money_sync/features/settings/domain/configuration_repository.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/scan_tracked_senders.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';
import 'package:money_sync/features/sms_tracking/data/drift_tracked_senders_repository.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/mappings/data/drift_mapping_rule_store.dart';
import 'package:money_sync/features/mappings/domain/auto_create_or_defer.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/notifications/domain/notification_service.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/data/keystore_wallet_secret_store.dart';
import 'package:money_sync/features/wallet_connection/data/production_wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/application/wallet_mutation_recovery_service.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_capability_ledger.dart';

final configurationRepositoryProvider = FutureProvider<ConfigurationRepository>(
  (ref) async {
    final db = await ref.watch(appDatabaseProvider.future);
    return DriftConfigurationRepository(database: db);
  },
);

/// Result of interpreting a [WalletConnectionActionResult] from the
/// startup reconnect attempt: what to log, what activity event to record,
/// and whether the stored key must be removed (M5.22 WP-H).
typedef WalletStartupOutcome = ({
  String logMessage,
  bool isError,
  ActivityEventCode activityCode,
  String activityMessage,
  bool removeKey,
});

/// Pure decision logic for [_AwaitingStartupState._connectWalletAtStartup]
/// — kept outside the widget so it is unit-testable without a database or
/// widget tree. Only [WalletReadFailureKind.invalidToken] (an
/// authentication rejection) requests key removal; every other failure
/// kind is a transport/service problem and must keep the stored key.
WalletStartupOutcome walletStartupOutcomeFor(
  WalletConnectionActionResult result,
) => switch (result) {
  WalletConnectionCatalogReady(:final catalog) => (
    logMessage:
        'Wallet reconnected on restart: ${catalog.accounts.length} accounts',
    isError: false,
    activityCode: ActivityEventCode.walletConnected,
    activityMessage: 'Wallet reconnected on app restart',
    removeKey: false,
  ),
  WalletConnectionCatalogOffline() => (
    logMessage: 'Wallet catalog offline on restart (cached data kept)',
    isError: false,
    activityCode: ActivityEventCode.walletRefreshed,
    activityMessage: 'Wallet catalog served from cache on restart',
    removeKey: false,
  ),
  WalletConnectionActionFailure(:final failure)
      when failure.kind == WalletReadFailureKind.invalidToken =>
    (
      logMessage: 'Wallet token rejected on restart, removing key',
      isError: true,
      activityCode: ActivityEventCode.walletDisconnected,
      activityMessage: 'Wallet key rejected on restart and removed',
      removeKey: true,
    ),
  WalletConnectionActionFailure(:final failure) => (
    logMessage:
        'Wallet refresh failed on restart (${failure.kind.name}), key kept',
    isError: true,
    activityCode: ActivityEventCode.walletRefreshed,
    activityMessage: 'Wallet refresh failed on restart (${failure.kind.name})',
    removeKey: false,
  ),
  WalletConnectionFreshAuthenticationRequired() ||
  WalletConnectionActionUnavailable() => (
    logMessage: 'Wallet startup refresh returned an unexpected result',
    isError: true,
    activityCode: ActivityEventCode.walletRefreshed,
    activityMessage: 'Wallet startup refresh returned an unexpected result',
    removeKey: false,
  ),
};

const _contractVersion = 'v1.3.0';

WalletRemoteCapability? _toCapability(String value) =>
    WalletRemoteCapability.values.where((c) => c.name == value).firstOrNull;

WalletCapabilityOutcome _toOutcome(String value) => switch (value) {
  'pass' => WalletCapabilityOutcome.pass,
  'fail' => WalletCapabilityOutcome.fail,
  _ => WalletCapabilityOutcome.unknown,
};

/// Re-arms the periodic WorkManager auto-import job if the user has
/// auto-import enabled. Idempotent — `WorkmanagerAutoImportScheduler`
/// uses `ExistingPeriodicWorkPolicy.update`, so re-calling on an
/// already-registered job is safe and cheap.
Future<void> reArmAutoImportScheduler({
  required AutoImportScheduler scheduler,
  required bool autoImportEnabled,
  required int autoImportIntervalMinutes,
}) async {
  if (!autoImportEnabled) return;
  await scheduler.enable(
    frequency: Duration(minutes: autoImportIntervalMinutes),
  );
}

/// One-shot app-open catch-up sync: runs a single `ScanTrackedSenders`
/// pass gated by `autoImportEnabled` (ScanTrackedSenders internally
/// no-ops if disabled) and using the persisted watermark for scan bounds.
Future<void> runAppOpenCatchUpScan({
  required AppDatabase database,
  required RulePackRegistry registry,
  required SourceIdentitySigner identitySigner,
  required NotificationService notificationService,
}) async {
  final scan = ScanTrackedSenders(
    database: database,
    smsHistoryApi: SmsHistoryHostApi(),
    registry: registry,
    identitySigner: identitySigner,
    notificationService: notificationService,
    trackedSendersRepository: DriftTrackedSendersRepository(database: database),
    candidateHook:
        (candidate, eventId, candidatePayload, normalizedSender) async {
          try {
            final setting = await (database.select(
              database.appSettings,
            )..where((row) => row.singletonId.equals(1))).getSingle();
            if (!setting.autoCreateEnabled) return false;

            final store = DriftMappingRuleStore(database: database);
            final rules = await store.list();
            final caps = AppCapabilities.m6PrivateFull();

            final cache = DriftWalletCatalogCache(database: database);
            final catalog = await cache.read();

            final writer = DriftReviewOutboxWriter(database: database);
            final capabilityRows = await database
                .select(database.capabilityLedger)
                .get();
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

            final event = await database.getSmsEventById(eventId);
            final privacyEpochMatches =
                (event?.privacyEpoch ?? setting.privacyEpoch) ==
                setting.privacyEpoch;

            final candidateId = 'candidate-$eventId';
            final hasActiveLineage = await writer.hasActiveLineage(candidateId);
            final linkRows = await (database.select(
              database.walletRecordLinks,
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
          } catch (e, s) {
            Logger('sms.scan').error('Auto-create hook failed', e, s);
            return false;
          }
        },
  );
  await scan();
}

Future<int> _loadPrivacyEpoch(AppDatabase db) async {
  try {
    final result = await db
        .customSelect(
          'SELECT privacy_epoch FROM app_settings WHERE singleton_id = 1',
        )
        .get();
    if (result.isNotEmpty) {
      return result.first.data['privacy_epoch'] as int;
    }
  } on Exception {
    // best-effort
  }
  return 0;
}

/// Runs [RawBodyRetentionSweep] using the user-configured
/// `app_settings.rawCopyRetentionDays` and records one `rawCopyPurged`
/// activity event when anything was purged. The sweep itself never touches
/// `activity_events` (independent retention domain, see [RawBodyRetentionSweep])
/// — the write happens here, at the call site. Best-effort: a failure is
/// logged and swallowed, never blocking startup.
Future<void> runRawBodyRetentionSweep(AppDatabase db, Logger log) async {
  try {
    final setting = await (db.select(
      db.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
    final retentionDays = setting?.rawCopyRetentionDays ?? 0;

    final sweep = RawBodyRetentionSweep(
      database: db,
      retentionDays: retentionDays,
    );
    final result = await sweep.call(nowUtc: DateTime.now().toUtc());
    if (result.totalPurged > 0) {
      log.info('Retention sweep purged ${result.totalPurged} raw bodies');
      final privacyEpoch = await _loadPrivacyEpoch(db);
      await db.insertActivity(
        activityType: ActivityEventCode.rawCopyPurged,
        safeDetailCode: ActivityStateTransition.rawCopyPurged,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: privacyEpoch,
        count: result.totalPurged,
        detailMessage: 'Stored message copies removed',
      );
    }
  } on Exception catch (e) {
    log.warning('Retention sweep skipped: $e');
  }
}

class BootstrapGate extends ConsumerWidget {
  const BootstrapGate({super.key, required this.config});
  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(appDatabaseProvider);
    final body = dbAsync.when(
      data: (db) => _AwaitingStartup(config: config),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Logger('bootstrap').severe('Database open failed: $e', e, s);
        });
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not open local data'),
                const SizedBox(height: 8),
                Text(
                  'Error: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: () {}, child: const Text('Try again')),
              ],
            ),
          ),
        );
      },
    );
    return Directionality(textDirection: TextDirection.ltr, child: body);
  }
}

class _AwaitingStartup extends ConsumerStatefulWidget {
  const _AwaitingStartup({required this.config});
  final AppConfig config;
  @override
  ConsumerState<_AwaitingStartup> createState() => _AwaitingStartupState();
}

class _AwaitingStartupState extends ConsumerState<_AwaitingStartup>
    with WidgetsBindingObserver {
  data_control.ClearLocalDataUseCase? _useCase;
  final _activityGeneration = ActivityWriterGeneration();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(foregroundLockControllerProvider.notifier).onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(smsPermissionStatusProvider.notifier).refresh();
    }
  }

  Future<void> _initialize() async {
    final log = Logger('startup');
    log.info('Starting startup initialization');
    final startupNotifier = ref.read(startupStateProvider.notifier);
    final db = await ref.read(appDatabaseProvider.future);
    final healthRepo = DatabaseHealthRepository(database: db);
    final onboardingRepo = DriftOnboardingRepository(database: db);

    final channel = ref.read(nativeSecurityChannelProvider);

    // Apply the persisted screenshot-protection preference as early as
    // possible. Kotlin defaults to ON (fail-safe); this resolves to the
    // user's saved choice once Dart can read it.
    try {
      final configRepo = DriftConfigurationRepository(database: db);
      final config = await configRepo.load();
      await channel.setSecureWindowProtection(
        enabled: config.secureWindowEnabled,
      );
    } catch (e, s) {
      log.error('setSecureWindowProtection failed at startup', e, s);
    }

    final databasePath = await channel.getSensitiveDatabasePath();
    final clearService = ClearLocalDataService(
      database: db,
      channel: channel,
      databasePath: databasePath,
      activityGeneration: _activityGeneration,
    );
    _useCase = data_control.ClearLocalDataUseCase(
      database: db,
      clearLocalDataService: clearService,
    );

    // M5.5: recover outbox rows interrupted by process death before any UI
    // reaches the mutation flows. Best-effort — recovery failure must not
    // block startup.
    try {
      final recovery = WalletMutationRecoveryService(
        dao: WalletMutationsDao(database: db),
      );
      final recovered = await recovery.recoverInterrupted();
      if (recovered > 0) {
        log.info('Recovered $recovered interrupted outbox mutation(s)');
      }

      // M5.22 WP-E: recoverInterrupted only parks rows on `reconciling`;
      // without this second half they stayed there forever. Ask Wallet
      // whether each unresolved create actually landed, and settle it.
      // Reconcile-first, never retry-first — plan/05 forbids resending until
      // the API has conclusively proven the original create did not succeed.
      final caps = ref.read(appCapabilitiesProvider);
      if (caps.isEnabled(AppCapability.walletCreate)) {
        final repository = ref.read(walletRepositoryProvider);
        final settled = await recovery.reconcilePending(
          findByMarker: repository.findRecordForReconciliation,
        );
        if (settled > 0) {
          log.info('Reconciled $settled pending mutation(s) to succeeded');
        }
      }
    } on Exception catch (e, s) {
      log.error('Outbox recovery scan failed', e, s);
    }

    // M5.21 WP6/G2: purge encrypted SMS bodies past the configured
    // retention window. Best-effort — a sweep failure must never block
    // startup (mirrors the outbox recovery block above).
    await runRawBodyRetentionSweep(db, log);

    // Auto-connect wallet at startup if a token was previously saved.
    // Awaited so wallet_connection_status/activity are settled before the
    // app reaches ready state, but internally best-effort — never throws.
    await _connectWalletAtStartup(db, log);

    // M6.9 Items 1+2+5: re-arm the periodic auto-import job if enabled,
    // then fire-and-forget a one-shot app-open catch-up scan. SMS tracking
    // is privateFull-only (playManual carries no READ_SMS, no scan task, no
    // auto-import toggle) — gate structurally here too, not just via the
    // Settings UI, so a stray/legacy autoImportEnabled=true can never make
    // playManual touch this path.
    if (widget.config.flavor == AppFlavor.privateFull) {
      try {
        final configRepo = DriftConfigurationRepository(database: db);
        final config = await configRepo.load();
        final scheduler = ref.read(autoImportSchedulerProvider);
        await reArmAutoImportScheduler(
          scheduler: scheduler,
          autoImportEnabled: config.autoImportEnabled,
          autoImportIntervalMinutes: config.autoImportIntervalMinutes,
        );
        log.info(
          'Auto-import scheduler re-armed '
          '(enabled=${config.autoImportEnabled}, '
          'interval=${config.autoImportIntervalMinutes}m)',
        );

        unawaited(_runCatchUpScan(db, config.autoImportEnabled, log));
      } on Exception catch (e, s) {
        log.error('Auto-import startup re-arm failed', e, s);
      }
    }

    log.info('Health check and onboarding repo ready');
    await startupNotifier.initialize(
      healthRepo: healthRepo,
      onboardingRepo: onboardingRepo,
    );
    log.info(
      'Startup init done, status=${ref.read(startupStateProvider).status.name}',
    );
  }

  /// Check if a wallet token was previously saved and refresh the catalog
  /// cache in the background. Non-blocking (awaited by the caller, but
  /// never prevents startup) — every outcome is written to
  /// `wallet_connection_status`, logged, and recorded as an activity event.
  /// Only an authentication rejection (invalid token) removes the stored
  /// key; a transport failure (offline/timeout/tls/service/...) must never
  /// destroy a still-valid credential (M5.22 WP-H).
  Future<void> _connectWalletAtStartup(AppDatabase db, Logger log) async {
    try {
      final channel = ref.read(nativeSecurityChannelProvider);
      final store = KeystoreWalletSecretStore(channel: channel);
      final status = await (db.select(
        db.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
      if (status == null || status.status == 'disconnected') return;

      final actions = ProductionWalletConnectionActions(
        secretStore: store,
        freshAuth: _StubFreshAuth(),
        cache: DriftWalletCatalogCache(database: db),
      );
      if (!actions.isAvailable) return;

      log.info('Wallet token found, refreshing catalog in background...');
      final privacyEpoch = await _loadPrivacyEpoch(db);
      final result = await actions.refresh(lifecycleEpoch: 0);
      final outcome = walletStartupOutcomeFor(result);
      log.info(outcome.logMessage);
      if (outcome.isError) {
        log.error(outcome.logMessage);
      }
      // Credential is genuinely no longer valid — remove it so the user is
      // asked to supply a new key next time they open the wallet
      // connection page (reuses the same disconnect path the page's manual
      // "disconnect" button uses). A transport failure never removes the
      // key — cache.write() inside actions.refresh already flips
      // wallet_connection_status to 'connected' on success and is simply
      // left untouched on a transport failure.
      if (outcome.removeKey) {
        await actions.disconnect(lifecycleEpoch: 0);
      }
      await _recordWalletStartupActivity(
        db,
        outcome.activityCode,
        outcome.activityMessage,
        privacyEpoch,
      );
    } on Exception catch (e) {
      log.warning('Startup wallet connect skipped: $e');
    }
  }

  Future<void> _runCatchUpScan(
    AppDatabase db,
    bool autoImportEnabled,
    Logger log,
  ) async {
    if (!autoImportEnabled) {
      log.debug('App-open catch-up scan skipped: autoImportEnabled is false');
      return;
    }
    try {
      final registry = await ref.read(rulePackRegistryProvider.future);
      final signer = ref.read(sourceIdentitySignerProvider);
      final notificationService = ref.read(notificationServiceProvider);
      await runAppOpenCatchUpScan(
        database: db,
        registry: registry,
        identitySigner: signer,
        notificationService: notificationService,
      );
    } on Exception catch (e, s) {
      log.error('App-open catch-up scan failed', e, s);
    }
  }

  Future<void> _recordWalletStartupActivity(
    AppDatabase db,
    ActivityEventCode code,
    String message,
    int privacyEpoch,
  ) async {
    try {
      await db.insertActivity(
        activityType: code,
        safeDetailCode: ActivityStateTransition.logEvent,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: privacyEpoch,
        detailMessage: message,
      );
    } on Exception catch (e) {
      Logger('startup').warning('Wallet startup activity log failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupStateProvider);

    if (state.status == StartupStatus.onboardingRequired) {
      return _appWithOverrides();
    }
    if (state.status == StartupStatus.ready) {
      return _appWithOverrides();
    }
    if (state.status == StartupStatus.recoveryRequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Logger(
          'startup',
        ).severe('Recovery required: ${state.health?.safeCode ?? "UNKNOWN"}');
      });
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('MoneySync could not open local data'),
                const SizedBox(height: 8),
                Text('Safe code: ${state.health?.safeCode ?? "UNKNOWN"}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _initialize,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _appWithOverrides() {
    final useCase = _useCase;
    if (useCase == null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    // smsPermissionGatewayProvider is deliberately NOT overridden here: it must
    // be hosted by the root container in bootstrap.dart, because the notifier
    // that reads it is not scoped to this ProviderScope and would otherwise
    // resolve the root's throwing default.
    final overrides = [
      clearLocalDataUseCaseProvider.overrideWithValue(useCase),
    ];
    return ProviderScope(overrides: overrides, child: const MoneySyncApp());
  }
}

/// Stub for startup connection — refresh() never calls fresh auth,
/// so this is only needed to satisfy the constructor contract.
class _StubFreshAuth implements FreshAuthPort {
  @override
  Future<bool> isDeviceAuthAvailable() async => false;

  @override
  Future<DeviceAuthOutcome> authenticate({required String purpose}) async =>
      DeviceAuthOutcome.authenticated;
}
