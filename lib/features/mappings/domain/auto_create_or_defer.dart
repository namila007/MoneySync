import 'package:logging/logging.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

final _log = Logger('mappings.auto_create');

/// Outcome of an automatic-creation attempt.
sealed class AutoCreateOutcome {
  const AutoCreateOutcome();
}

/// Written to the outbox — same shape a manual "Create" tap produces.
final class AutoCreated extends AutoCreateOutcome {
  const AutoCreated(this.mutationId, this.ruleName);
  final String mutationId;
  final String ruleName;
}

/// No rule matched, rule wasn't automatic, confidence too low, a gate blocked
/// it, or the global toggle is off — candidate stays needsReview.
final class DeferredToReview extends AutoCreateOutcome {
  const DeferredToReview(this.reason);
  final String reason;
}

/// Builds the [PreSendContext] for a candidate. The caller provides this
/// callback with database/repository access; the domain use case stays pure.
typedef PreSendContextBuilder =
    Future<PreSendContext> Function(TransactionCandidate candidate);

/// Resolves mapping rules for a candidate. The caller provides this callback
/// with repository access; the domain use case stays pure.
typedef MappingRulesResolver =
    Future<List<MappingRule>> Function(TransactionCandidate candidate);

/// Attempts automatic wallet creation for a candidate that matched an
/// automatic mapping rule above its confidence floor. Falls back to review
/// (DeferredToReview) for any deferral condition — never partially writes.
final class AutoCreateOrDefer {
  const AutoCreateOrDefer({
    required this.eligibilityPolicy,
    required this.outboxWriter,
    required this.capabilities,
    required this.autoCreateEnabled,
    required this.resolveRules,
    required this.buildPreSendContext,
  });

  final WalletCreateEligibilityPolicy eligibilityPolicy;
  final ReviewOutboxWriter outboxWriter;
  final AppCapabilities capabilities;
  final bool autoCreateEnabled;
  final MappingRulesResolver resolveRules;
  final PreSendContextBuilder buildPreSendContext;

  Future<AutoCreateOutcome> call(
    TransactionCandidate candidate, {
    required String senderNormalized,
    required int smsEventId,
    required String candidatePayload,
  }) async {
    if (!autoCreateEnabled ||
        !capabilities.isEnabled(AppCapability.automaticSync)) {
      _log.info('Deferred: auto_create_disabled');
      return const DeferredToReview('auto_create_disabled');
    }

    final rules = await resolveRules(candidate);
    final resolver = MappingRuleResolver(rules: rules);
    final resolution = resolver.resolve(
      MappingResolutionInput(
        senderNormalized: senderNormalized,
        confidenceBasisPoints: candidate.confidence.basisPoints,
        merchantNormalized: candidate.counterParty ?? '',
        direction: candidate.direction,
      ),
    );

    MappingRule matchedRule;
    switch (resolution) {
      case MappingUnmatched():
        _log.info('Deferred: mapping_unmatched');
        return const DeferredToReview('mapping_unmatched');
      case MappingAmbiguous():
        _log.info('Deferred: mapping_ambiguous');
        return const DeferredToReview('mapping_ambiguous');
      case MappingResolved(:final rule):
        if (rule.syncMode != MappingSyncMode.automatic) {
          _log.info('Deferred: rule_not_automatic');
          return const DeferredToReview('rule_not_automatic');
        }
        matchedRule = rule;
    }

    final context = await buildPreSendContext(candidate);
    final evaluation = eligibilityPolicy.evaluate(context);
    if (!evaluation.allowed) {
      final reason = evaluation.firstBlockReason ?? 'gate_blocked';
      _log.info('Deferred: $reason');
      return DeferredToReview(reason);
    }

    final intent = WalletMutationIntent(
      id: 'auto-${candidate.id}-${DateTime.now().millisecondsSinceEpoch}',
      candidateId: candidate.id,
      operation: WalletMutationOperation.create,
      operationRevision: 1,
      lineageGeneration: 1,
      createLineageKey: 'lineage-${candidate.id}-1',
      transactionFingerprint: 'fingerprint-${candidate.id}',
      payload: <String, Object?>{
        'accountId': matchedRule.walletAccountId,
        'amountMinor': candidate.originalAmount.minorUnits,
        'currencyCode': candidate.originalAmount.currency.code,
        'kind': candidate.kind.name,
        'direction': candidate.direction.name,
        'paymentType': matchedRule.paymentType,
        if (matchedRule.walletCategoryId != null)
          'categoryId': matchedRule.walletCategoryId,
        if (candidate.counterParty != null)
          'counterParty': candidate.counterParty,
      },
      state: WalletMutationState.queued,
    );

    try {
      await outboxWriter.submitAtomically(
        smsEventId: smsEventId,
        candidateState: CandidateRecordState.retainedLocal,
        encryptedPayload: candidatePayload,
        revision: 1,
        createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: 0,
        intent: intent,
        itemLegRole: WalletItemLegRole.primary,
        itemPayloadCiphertext: candidatePayload,
        activityType: ActivityEventCode.walletRecordQueued,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
        detailMessage: 'Auto-created from mapping rule: ${matchedRule.name}',
      );
      _log.info('AutoCreated: rule=${matchedRule.name}');
      return AutoCreated(intent.id, matchedRule.name);
    } on UniqueLineageViolationException {
      _log.info('Deferred: unique_lineage_violation');
      return const DeferredToReview('unique_lineage_violation');
    } catch (e, s) {
      _log.error('Write failed', e, s);
      return const DeferredToReview('write_failed');
    }
  }
}
