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
import 'package:money_sync/features/sms_ingestion/data/share_intent_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/manual_input_validation.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart'
    show CandidateRecordState;
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_capability_ledger.dart';

import 'share_intent_controller.dart';

final _log = Logger('manual.import');

enum ManualImportStep { input, preview, result }

final class ManualImportState {
  const ManualImportState({
    this.body = '',
    this.sender = '',
    this.step = ManualImportStep.input,
    this.isShareIntent = false,
    this.isSubmitting = false,
    this.resultMessage,
    this.resultType,
  });

  factory ManualImportState.initial() => const ManualImportState();

  factory ManualImportState.shareReceived(SharedTextPayload payload) =>
      ManualImportState(
        body: payload.text,
        step: ManualImportStep.input,
        isShareIntent: true,
      );

  final String body;
  final String sender;
  final ManualImportStep step;
  final bool isShareIntent;
  final bool isSubmitting;
  final String? resultMessage;
  final ImportResultType? resultType;

  int get bodyLength => body.length;
  bool get canSubmit =>
      bodyLength >= kMinBodyLength && bodyLength <= kMaxBodyLength;

  ManualImportState copyWith({
    String? body,
    String? sender,
    ManualImportStep? step,
    bool? isShareIntent,
    bool? isSubmitting,
    String? resultMessage,
    ImportResultType? resultType,
  }) {
    return ManualImportState(
      body: body ?? this.body,
      sender: sender ?? this.sender,
      step: step ?? this.step,
      isShareIntent: isShareIntent ?? this.isShareIntent,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resultMessage: resultMessage ?? this.resultMessage,
      resultType: resultType ?? this.resultType,
    );
  }
}

enum ImportResultType { success, alreadyPresent, filtered, rejected, error }

class ManualImportController extends Notifier<ManualImportState> {
  // ponytail: in-memory sliding window; resets on process death — fine for
  // the anti-spam rate limit. Move to Drift if it must survive restarts.
  static const _rateWindow = Duration(minutes: 1);
  static const _maxImportsPerWindow = 20;

  final List<int> _recentIngestEpochMs = [];

  @override
  ManualImportState build() {
    ref.listen(shareIntentProvider, (_, next) {
      if (next != null) {
        state = ManualImportState.shareReceived(next);
      }
    });
    return ManualImportState.initial();
  }

  void updateBody(String value) => state = state.copyWith(body: value);
  void updateSender(String value) => state = state.copyWith(sender: value);

  bool get _isRateLimited {
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentIngestEpochMs.removeWhere(
      (t) => now - t > _rateWindow.inMilliseconds,
    );
    return _recentIngestEpochMs.length >= _maxImportsPerWindow;
  }

  void submit() {
    final body = state.body;
    final result = validateManualInput(
      body,
      rawSender: state.sender,
      mimeType: 'text/plain',
    );
    if (result is ManualInputRejected) {
      state = state.copyWith(
        step: ManualImportStep.result,
        resultMessage: _rejectionMessage(result.reason),
        resultType: ImportResultType.rejected,
      );
      return;
    }
    state = state.copyWith(step: ManualImportStep.preview);
  }

  void backToInput() => state = state.copyWith(step: ManualImportStep.input);

  Future<void> confirm() async {
    if (_isRateLimited) {
      state = state.copyWith(
        step: ManualImportStep.result,
        resultMessage: _rejectionMessage(ManualInputRejection.rateLimited),
        resultType: ImportResultType.rejected,
      );
      return;
    }

    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) {
      state = state.copyWith(
        step: ManualImportStep.result,
        resultMessage: 'Service unavailable',
        resultType: ImportResultType.error,
      );
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      final body = state.body;
      final sender = state.sender;
      final isShareIntent = state.isShareIntent;
      final ingest = IngestManualMessage(
        database: db,
        identitySigner: ref.read(sourceIdentitySignerProvider),
        candidateHook:
            (candidate, eventId, candidatePayload, normalizedSender) async {
              try {
                final hookSetting = await (db.select(
                  db.appSettings,
                )..where((row) => row.singletonId.equals(1))).getSingle();
                if (!hookSetting.autoCreateEnabled) return false;

                final store = DriftMappingRuleStore(database: db);
                final rules = await store.list();
                final caps = ref.read(appCapabilitiesProvider);

                final cache = DriftWalletCatalogCache(database: db);
                final catalog = await cache.read();

                final writer = DriftReviewOutboxWriter(database: db);
                final capabilityRows = await db
                    .select(db.capabilityLedger)
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

                final event = await db.getSmsEventById(eventId);
                final privacyEpochMatches =
                    (event?.privacyEpoch ?? hookSetting.privacyEpoch) ==
                    hookSetting.privacyEpoch;

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

                final walletRepository = ref.read(walletRepositoryProvider);
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
                        hookSetting.disclosureAccepted &&
                        hookSetting.onboardingCompleted,
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
                  ensureDefaultLabels: (selected) async {
                    final ids = {...selected};
                    for (final name in [
                      'money_sync',
                      if (const bool.fromEnvironment('E2E_LABEL')) 'test',
                    ]) {
                      final id = await walletRepository.ensureLabel(name);
                      if (id == null) {
                        Logger('auto_create').error(
                          'Could not resolve or create label: SafeErrorCode: $name',
                        );
                        continue;
                      }
                      ids.add(id);
                    }
                    return ids.toList(growable: false);
                  },
                  notificationService: ref.read(notificationServiceProvider),
                  resolveReviewCount: () async {
                    final candidates = await db
                        .select(db.transactionCandidates)
                        .get();
                    return candidates
                        .where(
                          (r) => r.state == CandidateRecordState.needsReview,
                        )
                        .length;
                  },
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
      final outcome = await ingest(
        rawBody: body,
        rawSender: sender,
        source: isShareIntent
            ? IngestionSource.shareIntent
            : IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: setting.privacyEpoch,
      );
      _recentIngestEpochMs.add(DateTime.now().millisecondsSinceEpoch);

      switch (outcome) {
        case ManualIngestStored(:final duplicateSuspected):
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: duplicateSuspected
                ? 'Message imported, but it looks like a message you '
                      'already imported.'
                : 'Message imported and queued for review.',
            resultType: ImportResultType.success,
          );
        case ManualIngestAlreadyPresent():
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: 'This message was already imported.',
            resultType: ImportResultType.alreadyPresent,
          );
        case ManualIngestFiltered(:final triage):
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: 'Message filtered: ${triage.name}.',
            resultType: ImportResultType.filtered,
          );
        case ManualIngestRejected(:final reason):
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: _rejectionMessage(reason),
            resultType: ImportResultType.rejected,
          );
        case ManualIngestBlockedByEpoch():
          state = state.copyWith(
            step: ManualImportStep.result,
            isSubmitting: false,
            resultMessage: 'Operation blocked by privacy policy.',
            resultType: ImportResultType.error,
          );
      }
    } catch (e) {
      state = state.copyWith(
        step: ManualImportStep.result,
        isSubmitting: false,
        resultMessage: 'Error: $e',
        resultType: ImportResultType.error,
      );
    }
  }

  void discard() {
    state = ManualImportState.initial();
    ref.read(shareIntentProvider.notifier).clear();
  }

  void tryAgain() => state = state.copyWith(
    step: ManualImportStep.input,
    resultMessage: null,
    resultType: null,
  );

  static String _rejectionMessage(ManualInputRejection reason) {
    return switch (reason) {
      ManualInputRejection.empty => 'Message body is empty.',
      ManualInputRejection.tooShort =>
        'Message is too short (minimum 12 characters).',
      ManualInputRejection.tooLong =>
        'Message is too long (maximum 2000 characters).',
      ManualInputRejection.unsupportedMimeType => 'Unsupported file type.',
      ManualInputRejection.controlCharacters => 'Invalid characters detected.',
      ManualInputRejection.senderTooLong =>
        'Sender name is too long (max 32 characters).',
      ManualInputRejection.rateLimited => 'Too many imports. Please wait.',
      ManualInputRejection.notPlausiblyFinancial =>
        'Does not appear to be a financial message.',
    };
  }
}

final manualImportProvider =
    NotifierProvider<ManualImportController, ManualImportState>(
      ManualImportController.new,
    );

const _contractVersion = 'v1.3.0';

WalletRemoteCapability? _toCapability(String value) =>
    WalletRemoteCapability.values.where((c) => c.name == value).firstOrNull;

WalletCapabilityOutcome _toOutcome(String value) => switch (value) {
  'pass' => WalletCapabilityOutcome.pass,
  'fail' => WalletCapabilityOutcome.fail,
  _ => WalletCapabilityOutcome.unknown,
};
