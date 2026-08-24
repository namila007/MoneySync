import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_capability_ledger.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_success_view.dart'
    show succeededMutationsProvider;
import 'package:money_sync/features/wallet_sync/presentation/wallet_waiting_view.dart'
    show waitingMutationsProvider;

final log = Logger('review');

/// Editing state for one review action, submitted through M5.9's atomic
/// use case. [submitting] flips to true before the transaction opens, so the
/// Create button cannot double-fire (M5.9/M5.10 UI guard).
final reviewTransactionControllerProvider =
    NotifierProvider.family<
      ReviewTransactionController,
      ReviewTransactionViewState,
      int
    >(ReviewTransactionController.new);

final class ReviewTransactionViewState {
  const ReviewTransactionViewState({
    this.amountMinor = 0,
    this.kind = TransactionKind.expense,
    this.direction = TransactionDirection.debit,
    this.dateUtc,
    this.accountId,
    this.categoryId,
    this.paymentType = 'debit_card',
    this.counterParty = '',
    this.note = '',
    this.labelIds = const [],
    this.evaluation,
    this.result,
    this.submitting = false,
  });

  final int amountMinor;
  final TransactionKind kind;
  final TransactionDirection direction;
  final DateTime? dateUtc;
  final String? accountId;
  final String? categoryId;
  final String paymentType;
  final String counterParty;
  final String note;
  final List<String> labelIds;
  final GateEvaluation? evaluation;
  final ReviewSubmissionResult? result;
  final bool submitting;

  ReviewTransactionViewState copyWith({
    int? amountMinor,
    TransactionKind? kind,
    TransactionDirection? direction,
    DateTime? dateUtc,
    String? accountId,
    String? categoryId,
    String? paymentType,
    String? counterParty,
    String? note,
    List<String>? labelIds,
    GateEvaluation? evaluation,
    ReviewSubmissionResult? result,
    bool? submitting,
  }) => ReviewTransactionViewState(
    amountMinor: amountMinor ?? this.amountMinor,
    kind: kind ?? this.kind,
    direction: direction ?? this.direction,
    dateUtc: dateUtc ?? this.dateUtc,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId ?? this.categoryId,
    paymentType: paymentType ?? this.paymentType,
    counterParty: counterParty ?? this.counterParty,
    note: note ?? this.note,
    labelIds: labelIds ?? this.labelIds,
    evaluation: evaluation ?? this.evaluation,
    result: result ?? this.result,
    submitting: submitting ?? this.submitting,
  );
}

class ReviewTransactionController extends Notifier<ReviewTransactionViewState> {
  ReviewTransactionController(int smsEventId) : _smsEventId = smsEventId;

  final int _smsEventId;

  @override
  ReviewTransactionViewState build() => const ReviewTransactionViewState();

  void update({
    int? amountMinor,
    TransactionKind? kind,
    TransactionDirection? direction,
    DateTime? dateUtc,
    String? accountId,
    String? categoryId,
    String? paymentType,
    String? counterParty,
    String? note,
    List<String>? labelIds,
  }) {
    state = state.copyWith(
      amountMinor: amountMinor,
      kind: kind,
      direction: direction,
      dateUtc: dateUtc,
      accountId: accountId,
      categoryId: categoryId,
      paymentType: paymentType,
      counterParty: counterParty,
      note: note,
      labelIds: labelIds,
    );
  }

  /// Evaluates the M5.8 gate chain for the current edits and stores the full
  /// ordered outcome list for display.
  Future<void> evaluate({
    required String encryptedPayload,
    required String senderNormalized,
  }) async {
    final context = await _buildContext(senderNormalized: senderNormalized);
    final evaluation = const WalletCreateEligibilityPolicy().evaluate(context);
    state = state.copyWith(evaluation: evaluation);
  }

  /// Runs the atomic review->outbox write with the UI double-submit guard.
  /// When [deferred] is true, writes `queued` instead of `succeeded` (WP3).
  Future<void> submit({
    required String encryptedPayload,
    required String senderNormalized,
    required int revision,
    bool deferred = false,
  }) async {
    if (state.submitting) return; // double-submit guard
    state = state.copyWith(submitting: true);

    try {
      final context = await _buildContext(senderNormalized: senderNormalized);
      final evaluation = const WalletCreateEligibilityPolicy().evaluate(
        context,
      );
      if (!evaluation.allowed) {
        state = state.copyWith(
          evaluation: evaluation,
          submitting: false,
          result: ReviewBlocked(
            evaluation.firstBlockedGateIndex,
            evaluation.firstBlockReason ?? 'Blocked by pre-send gate.',
          ),
        );
        return;
      }

      final db = await ref.read(appDatabaseProvider.future);
      final writer = DriftReviewOutboxWriter(database: db);
      final useCase = ReviewTransactionUseCase(
        writer: writer,
        policy: const WalletCreateEligibilityPolicy(),
      );

      // M5.14 gap 3: the immutable create payload goes through the M5.6
      // serializer (compile-time allowlist / structural redaction), never a
      // hand-built map. The serialized single-item body is both the mutation
      // payload snapshot and the per-item ciphertext.
      final noteWithMarker = _buildNoteWithMarker(state.note);
      final snapshot = TransactionCandidateSnapshot(
        accountId: state.accountId ?? '',
        amountMinor: state.amountMinor,
        currencyCode: 'LKR',
        recordDateUtc: state.dateUtc ?? DateTime.now().toUtc(),
        paymentType: _wirePaymentType(state.paymentType),
        recordState: WalletRecordState.cleared,
        counterParty: state.counterParty.isEmpty ? null : state.counterParty,
        categoryId: state.categoryId,
        note: noteWithMarker,
        labelIds: state.labelIds,
      );
      log.fine(
        '[create] Snapshot: account=${snapshot.accountId} '
        'amount=${snapshot.amountMinor} ${snapshot.currencyCode} '
        'date=${snapshot.recordDateUtc} payment=${snapshot.paymentType.wireName} '
        'category=${snapshot.categoryId} counterparty=${snapshot.counterParty}',
      );
      final serializedBody = jsonEncode(
        const WalletRecordPayloadSerializer().serialize(snapshot),
      );

      final intent = WalletMutationIntent(
        id: 'mutation-$_smsEventId-${DateTime.now().millisecondsSinceEpoch}',
        candidateId: 'candidate-$_smsEventId',
        operation: WalletMutationOperation.create,
        operationRevision: 1,
        lineageGeneration: 1,
        createLineageKey: 'lineage-$_smsEventId-1',
        transactionFingerprint: 'fingerprint-$_smsEventId',
        payload: <String, Object?>{
          'accountId': state.accountId,
          'amountMinor': state.amountMinor,
          'currencyCode': 'LKR',
          'kind': state.kind.name,
          'direction': state.direction.name,
          'paymentType': state.paymentType,
          if (state.categoryId != null) 'categoryId': state.categoryId,
        },
        state: deferred
            ? WalletMutationState.queued
            : WalletMutationState.succeeded,
      );
      log.fine(
        '[create] Intent: id=${intent.id} candidateId=${intent.candidateId} '
        'state=${intent.state.name} deferred=$deferred',
      );

      final result = await useCase.submit(
        context: context,
        smsEventId: _smsEventId,
        candidateState: CandidateRecordState.retainedLocal,
        encryptedPayload: encryptedPayload,
        revision: revision,
        createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: 0,
        intent: intent,
        itemLegRole: WalletItemLegRole.primary,
        itemPayloadCiphertext: serializedBody,
        activityType: ActivityEventCode.walletRecordCreated,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
        detailMessage: 'Wallet record created',
      );

      log.info('Review submit for message $_smsEventId: ${result.runtimeType}');
      if (result is ReviewBlocked) {
        log.warning(
          'Review blocked for message $_smsEventId: '
          'gate ${result.gateIndex} — ${result.reason}',
        );
      } else if (result is ReviewDuplicate) {
        log.warning(
          'Review duplicate for message $_smsEventId: '
          'active lineage already exists',
        );
      }
      state = state.copyWith(
        submitting: false,
        result: result,
        evaluation: evaluation,
      );

      // Invalidate activity log so the new event appears immediately.
      ref.invalidate(filteredActivityLogProvider);
      // Invalidate waiting/success views so the new mutation appears.
      ref.invalidate(waitingMutationsProvider);
      ref.invalidate(succeededMutationsProvider);
    } catch (e, s) {
      log.error('Review submit failed for message $_smsEventId', e, s);
      state = state.copyWith(
        submitting: false,
        result: const ReviewBlocked(-1, 'Submission failed. Try again.'),
      );
    }
  }

  Future<PreSendContext> _buildContext({
    required String senderNormalized,
  }) async {
    final catalog = await ref.read(walletCatalogProvider.future);
    final selectedAccountId = state.accountId;
    WalletAccount? account;
    if (selectedAccountId != null && catalog != null) {
      for (final candidate in catalog.accounts) {
        if (candidate.id == selectedAccountId) {
          account = candidate;
          break;
        }
      }
    }

    final rules = await ref.read(mappingRuleListProvider.future);
    final resolver = MappingRuleResolver(rules: rules);
    final resolution = resolver.resolve(
      MappingResolutionInput(
        senderNormalized: senderNormalized,
        confidenceBasisPoints: 9500,
        merchantNormalized: state.counterParty,
        direction: state.direction,
      ),
    );

    // M5.14 gap 2: gates 1/2/7/8 read REAL state instead of hardcoded pass.
    // Privacy epoch / consent / capability come from the DB; lineage and owned
    // record link are real queries against the outbox and record-link tables.
    final db = await ref.read(appDatabaseProvider.future);
    final setting = await (db.select(
      db.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
    final event = await db.getSmsEventById(_smsEventId);
    final currentPrivacyEpoch = setting?.privacyEpoch ?? 0;
    final privacyEpochMatches =
        (event?.privacyEpoch ?? currentPrivacyEpoch) == currentPrivacyEpoch;

    final consentCurrent =
        (setting?.disclosureAccepted ?? false) &&
        (setting?.onboardingCompleted ?? false);

    final capabilityCanCreate = await _capabilityCanCreate(db);

    final writer = DriftReviewOutboxWriter(database: db);
    final candidateId = 'candidate-$_smsEventId';
    final hasActiveLineage = await writer.hasActiveLineage(candidateId);

    final linkRows = await (db.select(
      db.walletRecordLinks,
    )..where((row) => row.candidateId.equals(candidateId))).get();
    final hasOwnedRecordLink = linkRows.isNotEmpty;

    return PreSendContext(
      candidateId: candidateId,
      amountMinor: state.amountMinor,
      currencyCode: 'LKR',
      recordDateUtc: state.dateUtc ?? DateTime.now().toUtc(),
      direction: state.direction,
      paymentType: state.paymentType,
      senderNormalized: senderNormalized,
      confidenceBasisPoints: 9500,
      privacyEpochMatches: privacyEpochMatches,
      consentCurrent: consentCurrent,
      connectionConnected: catalog != null && catalog.accounts.isNotEmpty,
      eligibleTargetAccount:
          account != null &&
          account.isWritable &&
          account.eligibility == WalletAccountEligibility.eligible,
      targetAccountEligibility:
          account?.eligibility ??
          WalletAccountEligibility.missingRequiredFields,
      mappingResolution: resolution,
      capabilityCanCreate: capabilityCanCreate,
      hasActiveLineage: hasActiveLineage,
      hasOwnedRecordLink: hasOwnedRecordLink,
    );
  }

  /// Wallet create capability from the capability_ledger table, mapped onto
  /// the domain [WalletCapabilityLedger]. Empty ledger -> no evidence -> false
  /// (fail-closed; M5.7 spike not closed). Contract version matches the
  /// v1.3.0 catalog contract the reader targets.
  Future<bool> _capabilityCanCreate(AppDatabase db) async {
    final rows = await db.select(db.capabilityLedger).get();
    final evidence = <WalletCapabilityEvidence>[
      for (final row in rows)
        if (_toCapability(row.capability) case final capability?)
          WalletCapabilityEvidence(
            capability: capability,
            outcome: _toOutcome(row.status),
            observedAt: DateTime.tryParse(row.observedOn) ?? DateTime.now(),
            contractVersion: _contractVersion,
          ),
    ];
    return WalletCapabilityLedger(evidence: evidence).canCreate(
      now: DateTime.now().toUtc(),
      compatibleContractVersion: _contractVersion,
    );
  }

  static const _contractVersion = 'v1.3.0';

  static WalletRemoteCapability? _toCapability(String value) =>
      WalletRemoteCapability.values.where((c) => c.name == value).firstOrNull;

  static WalletCapabilityOutcome _toOutcome(String value) => switch (value) {
    'pass' => WalletCapabilityOutcome.pass,
    'fail' => WalletCapabilityOutcome.fail,
    _ => WalletCapabilityOutcome.unknown,
  };

  static WalletPaymentType _wirePaymentType(String value) => switch (value) {
    'cash' => WalletPaymentType.cash,
    'credit_card' => WalletPaymentType.creditCard,
    'transfer' => WalletPaymentType.transfer,
    'voucher' => WalletPaymentType.voucher,
    'mobile_payment' => WalletPaymentType.mobilePayment,
    'web_payment' => WalletPaymentType.webPayment,
    _ => WalletPaymentType.debitCard,
  };

  /// Builds the `note` field for the Wallet API: `[sw:<marker>] <userNote>`.
  /// The marker is never truncated; user text is truncated to fit 255 chars.
  static String? _buildNoteWithMarker(String userNote) {
    final marker = 'sw:${_generateMarker()}';
    final prefix = '[$marker] ';
    if (userNote.isEmpty) return prefix.trimRight();
    final maxUserLength = 255 - prefix.length;
    if (maxUserLength <= 0) return prefix.trimRight();
    final truncated = userNote.length > maxUserLength
        ? userNote.substring(0, maxUserLength)
        : userNote;
    return '$prefix$truncated';
  }

  /// Short alphanumeric marker for source reconciliation. Derived from the
  /// current timestamp — not cryptographic, just a stable traceable id.
  static String _generateMarker() {
    final now = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return now.toUpperCase().padLeft(16, '0');
  }
}
