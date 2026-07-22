import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// A pure domain boundary for immutable mutation intent persistence.
abstract interface class MutationIntentStore {
  Future<WalletMutationIntent?> findById(String id);

  Future<void> put(WalletMutationIntent intent);
}

/// A connectivity boundary whose implementation stays outside the domain.
abstract interface class ConnectivityAvailability {
  Future<bool> isOnline();
}
