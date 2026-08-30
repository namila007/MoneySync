import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/mappings/data/drift_mapping_rule_store.dart';
import 'package:money_sync/features/mappings/domain/auto_create_or_defer.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/sms_ingestion/application/import_sms_history.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_tracking/data/drift_tracked_senders_repository.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_capability_ledger.dart';

final _log = Logger('sms.history');

const _sentinel = Object();

final class HistoryImportState {
  const HistoryImportState({
    this.preset = 7,
    this.customDays,
    this.messageCap = 100,
    this.trackedSenders = const [],
    this.isScanning = false,
    this.imported = 0,
    this.filtered = 0,
    this.duplicates = 0,
    this.terminalResult,
  });

  factory HistoryImportState.initial() => const HistoryImportState();

  final int preset;
  final int? customDays;
  final int messageCap;
  final List<String> trackedSenders;
  final bool isScanning;
  final int imported;
  final int filtered;
  final int duplicates;
  final TerminalResult? terminalResult;

  int get windowDays => customDays ?? preset;

  HistoryImportState copyWith({
    int? preset,
    Object? customDays = _sentinel,
    int? messageCap,
    List<String>? trackedSenders,
    bool? isScanning,
    int? imported,
    int? filtered,
    int? duplicates,
    TerminalResult? terminalResult,
  }) {
    return HistoryImportState(
      preset: preset ?? this.preset,
      customDays: customDays == _sentinel
          ? this.customDays
          : customDays as int?,
      messageCap: messageCap ?? this.messageCap,
      trackedSenders: trackedSenders ?? this.trackedSenders,
      isScanning: isScanning ?? this.isScanning,
      imported: imported ?? this.imported,
      filtered: filtered ?? this.filtered,
      duplicates: duplicates ?? this.duplicates,
      terminalResult: terminalResult ?? this.terminalResult,
    );
  }
}

enum TerminalResult {
  completed,
  cancelled,
  capReached,
  error,
  blocked,
  noTrackedSenders,
}

class HistoryImportController extends Notifier<HistoryImportState> {
  ImportSmsHistory? _activeImport;

  @override
  HistoryImportState build() {
    _loadTrackedSenders();
    return HistoryImportState.initial();
  }

  Future<void> reloadTrackedSenders() => _loadTrackedSenders();

  Future<void> _loadTrackedSenders() async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final repo = DriftTrackedSendersRepository(database: db);
      final senders = await repo.load();
      state = state.copyWith(
        trackedSenders: [for (final s in senders) s.address],
      );
    } catch (_) {
      state = state.copyWith(trackedSenders: const []);
    }
  }

  void selectPreset(int days) {
    state = state.copyWith(preset: days, customDays: null);
  }

  void setCustomDays(int days) {
    state = state.copyWith(customDays: days.clamp(1, 90));
  }

  void setMessageCap(int cap) {
    state = state.copyWith(messageCap: cap.clamp(1, ImportSmsHistory.hardCap));
  }

  Future<void> startImport() async {
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;

    if (state.trackedSenders.isEmpty) {
      state = state.copyWith(
        isScanning: false,
        terminalResult: TerminalResult.noTrackedSenders,
      );
      return;
    }

    final setting = await (db.select(
      db.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();

    final now = DateTime.now();
    final fromEpochMs = now
        .subtract(Duration(days: state.windowDays))
        .millisecondsSinceEpoch;
    final untilEpochMs = now.millisecondsSinceEpoch;

    state = state.copyWith(
      isScanning: true,
      imported: 0,
      filtered: 0,
      duplicates: 0,
    );

    RulePackRegistry registry;
    try {
      registry = await ref.read(rulePackRegistryProvider.future);
    } catch (_) {
      state = state.copyWith(
        isScanning: false,
        terminalResult: TerminalResult.error,
      );
      return;
    }

    final import = ImportSmsHistory(
      database: db,
      smsHistoryApi: SmsHistoryHostApi(),
      registry: registry,
      identitySigner: ref.read(sourceIdentitySignerProvider),
      candidateHook:
          (candidate, eventId, candidatePayload, normalizedSender) async {
            try {
              final setting = await (db.select(
                db.appSettings,
              )..where((row) => row.singletonId.equals(1))).getSingle();
              if (!setting.autoCreateEnabled) return false;

              final store = DriftMappingRuleStore(database: db);
              final rules = await store.list();
              final caps = ref.read(appCapabilitiesProvider);

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
            } catch (e, s) {
              _log.error('Auto-create hook failed', e, s);
              return false;
            }
          },
    );
    _activeImport = import;

    await for (final progress in import.import(
      fromEpochMs: fromEpochMs,
      untilEpochMs: untilEpochMs,
      messageCap: state.messageCap,
      privacyEpoch: setting.privacyEpoch,
      trackedSenders: state.trackedSenders,
    )) {
      if (progress is ImportCompleted) {
        state = state.copyWith(
          isScanning: false,
          imported: progress.imported,
          filtered: progress.filtered,
          duplicates: progress.duplicates,
          terminalResult: TerminalResult.completed,
        );
        return;
      } else if (progress is ImportCancelled) {
        state = state.copyWith(
          isScanning: false,
          imported: progress.imported,
          filtered: progress.filtered,
          duplicates: progress.duplicates,
          terminalResult: TerminalResult.cancelled,
        );
        return;
      } else if (progress is ImportCapReached) {
        state = state.copyWith(
          isScanning: false,
          imported: progress.imported,
          filtered: progress.filtered,
          duplicates: progress.duplicates,
          terminalResult: TerminalResult.capReached,
        );
        return;
      } else if (progress is ImportStatusError) {
        state = state.copyWith(
          isScanning: false,
          terminalResult: TerminalResult.error,
        );
        return;
      } else if (progress is ImportBlockedByEpoch) {
        state = state.copyWith(
          isScanning: false,
          terminalResult: TerminalResult.blocked,
        );
        return;
      } else if (progress is ImportNoTrackedSenders) {
        state = state.copyWith(
          isScanning: false,
          terminalResult: TerminalResult.noTrackedSenders,
        );
        return;
      } else if (progress is ImportInProgress) {
        state = state.copyWith(
          imported: progress.imported,
          filtered: progress.filtered,
          duplicates: progress.duplicates,
        );
      }
    }

    state = state.copyWith(isScanning: false);
  }

  void cancelImport() {
    _activeImport?.cancel();
  }

  void reset() {
    _activeImport?.cancel();
    state = HistoryImportState.initial();
    _loadTrackedSenders();
  }
}

final historyImportProvider =
    NotifierProvider<HistoryImportController, HistoryImportState>(
      HistoryImportController.new,
    );

const _contractVersion = 'v1.3.0';

WalletRemoteCapability? _toCapability(String value) =>
    WalletRemoteCapability.values.where((c) => c.name == value).firstOrNull;

WalletCapabilityOutcome _toOutcome(String value) => switch (value) {
  'pass' => WalletCapabilityOutcome.pass,
  'fail' => WalletCapabilityOutcome.fail,
  _ => WalletCapabilityOutcome.unknown,
};
