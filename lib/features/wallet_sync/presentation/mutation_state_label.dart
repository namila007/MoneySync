import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// Maps a [WalletMutationState] to its stored SQL string representation.
/// Used by the success/waiting/retry presentation views for DB queries.
String storedMutationState(WalletMutationState s) => switch (s) {
  WalletMutationState.queued => 'queued',
  WalletMutationState.syncing => 'syncing',
  WalletMutationState.reconciling => 'reconciling',
  WalletMutationState.unknownDelivery => 'unknown_delivery',
  WalletMutationState.unknownUpdate => 'unknown_update',
  WalletMutationState.unknownDelete => 'unknown_delete',
  WalletMutationState.retryScheduled => 'retry_scheduled',
  WalletMutationState.succeeded => 'succeeded',
  WalletMutationState.permanentFailure => 'permanent_failure',
  WalletMutationState.supersededBeforeSend => 'superseded_before_send',
};
