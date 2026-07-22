import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_sync_ports.dart';

void main() {
  test(
    'injected domain ports can be implemented with deterministic fakes',
    () async {
      final store = _InMemoryMutationIntentStore();
      final availability = _FixedConnectivityAvailability(false);
      final intent = WalletMutationIntent(
        id: 'mutation-1',
        candidateId: 'candidate-1',
        operation: WalletMutationOperation.create,
        operationRevision: 1,
        lineageGeneration: 1,
        createLineageKey: 'lineage-key-1',
        transactionFingerprint: 'fingerprint-1',
        payload: const <String, Object?>{},
        state: WalletMutationState.queued,
      );

      await store.put(intent);

      expect(await store.findById('mutation-1'), intent);
      expect(await availability.isOnline(), isFalse);
    },
  );
}

final class _InMemoryMutationIntentStore implements MutationIntentStore {
  final Map<String, WalletMutationIntent> _values =
      <String, WalletMutationIntent>{};

  @override
  Future<WalletMutationIntent?> findById(String id) async => _values[id];

  @override
  Future<void> put(WalletMutationIntent intent) async {
    _values[intent.id] = intent;
  }
}

final class _FixedConnectivityAvailability implements ConnectivityAvailability {
  const _FixedConnectivityAvailability(this._isOnline);

  final bool _isOnline;

  @override
  Future<bool> isOnline() async => _isOnline;
}
