import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

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
    evaluation: evaluation ?? this.evaluation,
    result: result ?? this.result,
    submitting: submitting ?? this.submitting,
  );
}

class ReviewTransactionController
    extends Notifier<ReviewTransactionViewState> {
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
  Future<void> submit({
    required String encryptedPayload,
    required String senderNormalized,
    required int revision,
  }) async {
    if (state.submitting) return; // double-submit guard
    state = state.copyWith(submitting: true);

    try {
      final context = await _buildContext(senderNormalized: senderNormalized);
      final evaluation = const WalletCreateEligibilityPolicy().evaluate(context);
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
        },
        state: WalletMutationState.queued,
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
        itemPayloadCiphertext: encryptedPayload,
        activityType: ActivityEventCode.walletRecordCreated,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
      );

      log.info('Review submit for message $_smsEventId: ${result.runtimeType}');
      state = state.copyWith(
        submitting: false,
        result: result,
        evaluation: evaluation,
      );
    } catch (e, s) {
      log.error('Review submit failed for message $_smsEventId', e, s);
      state = state.copyWith(
        submitting: false,
        result: const ReviewBlocked(-1, 'Submission failed. Try again.'),
      );
    }
  }

  Future<PreSendContext> _buildContext({required String senderNormalized}) async {
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

    return PreSendContext(
      candidateId: 'candidate-$_smsEventId',
      amountMinor: state.amountMinor,
      currencyCode: 'LKR',
      recordDateUtc: state.dateUtc ?? DateTime.now().toUtc(),
      direction: state.direction,
      paymentType: state.paymentType,
      senderNormalized: senderNormalized,
      confidenceBasisPoints: 9500,
      privacyEpochMatches: true,
      consentCurrent: true,
      connectionConnected: catalog != null && catalog.accounts.isNotEmpty,
      eligibleTargetAccount:
          account != null &&
          account.isWritable &&
          account.eligibility == WalletAccountEligibility.eligible,
      targetAccountEligibility:
          account?.eligibility ?? WalletAccountEligibility.missingRequiredFields,
      mappingResolution: resolution,
      capabilityCanCreate: true,
      hasActiveLineage: false,
      hasOwnedRecordLink: false,
    );
  }
}
