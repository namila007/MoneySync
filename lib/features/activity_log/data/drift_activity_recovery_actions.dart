import 'package:money_sync/features/activity_log/domain/activity_recovery_actions.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// Production [ActivityRecoveryActions] backed by the outbox DAO (M5.14 gap 5).
///
/// `retryNow` expedites a `retry_scheduled` mutation back to `syncing` so the
/// foreground worker picks it up on its next pass; `verifyInWallet` moves an
/// unknown-delivery/update/delete mutation to `reconciling` so reconciliation
/// can settle it. Both only act on states the transition table allows; a
/// mutation in a terminal or queued state is left untouched.
final class DriftActivityRecoveryActions implements ActivityRecoveryActions {
  DriftActivityRecoveryActions({required this.dao});

  final WalletMutationsDao dao;

  @override
  Future<void> retryNow(String mutationId) async {
    final intent = await dao.byId(mutationId);
    if (intent == null || intent.state != WalletMutationState.retryScheduled) {
      return;
    }
    await dao.transitionTo(intent: intent, next: WalletMutationState.syncing);
  }

  @override
  Future<void> verifyInWallet(String mutationId) async {
    final intent = await dao.byId(mutationId);
    if (intent == null) return;
    const unknown = {
      WalletMutationState.unknownDelivery,
      WalletMutationState.unknownUpdate,
      WalletMutationState.unknownDelete,
    };
    if (!unknown.contains(intent.state)) return;
    await dao.transitionTo(
      intent: intent,
      next: WalletMutationState.reconciling,
    );
  }
}
