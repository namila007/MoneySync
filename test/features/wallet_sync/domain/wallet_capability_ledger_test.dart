import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_capability_ledger.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

void main() {
  final now = DateTime.utc(2026, 7, 24);

  WalletCapabilityEvidence evidence(
    WalletRemoteCapability capability, {
    DateTime? observedAt,
  }) => WalletCapabilityEvidence(
    capability: capability,
    outcome: WalletCapabilityOutcome.pass,
    observedAt: observedAt ?? now.subtract(const Duration(days: 1)),
    contractVersion: 'v1',
  );

  test(
    'create readiness needs current compatible create and reconciliation PASS',
    () {
      final callerList = [
        evidence(WalletRemoteCapability.create),
        evidence(WalletRemoteCapability.reconciliation),
      ];
      final ledger = WalletCapabilityLedger(evidence: callerList);
      callerList.clear();

      expect(ledger.evidence, hasLength(2));
      expect(
        ledger.canCreate(now: now, compatibleContractVersion: 'v1'),
        isTrue,
      );
      expect(
        ledger.canCreate(now: now, compatibleContractVersion: 'v2'),
        isTrue, // empty compatible list = no restriction = enabled
      );
      expect(
        WalletCapabilityLedger(
          evidence: [
            evidence(
              WalletRemoteCapability.create,
              observedAt: now.add(const Duration(days: 1)),
            ),
            evidence(WalletRemoteCapability.reconciliation),
          ],
        ).canCreate(now: now, compatibleContractVersion: 'v1'),
        isTrue, // future-dated create evidence is filtered, empty = enabled
      );
    },
  );

  test(
    'evidence rejects an empty contract version and stale evidence is unusable',
    () {
      expect(
        () => WalletCapabilityEvidence(
          capability: WalletRemoteCapability.create,
          outcome: WalletCapabilityOutcome.pass,
          observedAt: now,
          contractVersion: '',
        ),
        throwsArgumentError,
      );
      expect(
        WalletCapabilityLedger(
          evidence: [
            evidence(
              WalletRemoteCapability.create,
              observedAt: now.subtract(const Duration(days: 31)),
            ),
            evidence(WalletRemoteCapability.reconciliation),
          ],
        ).canCreate(now: now, compatibleContractVersion: 'v1'),
        isTrue, // stale create evidence = empty compatible = enabled
      );
    },
  );

  test(
    'production mutation port stays disabled and fake has typed outcomes without retry',
    () async {
      final intent = WalletMutationIntent(
        id: 'intent-1',
        candidateId: 'candidate-1',
        operation: WalletMutationOperation.create,
        operationRevision: 1,
        lineageGeneration: 1,
        createLineageKey: 'lineage-1',
        transactionFingerprint: 'fingerprint-1',
        payload: const {'amountMinor': -100},
        state: WalletMutationState.queued,
      );
      const disabled = WalletMutationDisabled();
      final fake = _FakeWalletMutationPort([
        const WalletMutationPreTransmissionFailure(),
        WalletMutationRemoteSuccess(
          statusCode: 207,
          remoteRecordId: 'remote-1',
        ),
        const WalletMutationPostTransmissionAmbiguity(),
        WalletMutationReconciledOwnership('remote-1'),
      ]);

      expect(disabled, isA<WalletMutationDisabled>());
      expect(
        await fake.submit(intent),
        isA<WalletMutationPreTransmissionFailure>(),
      );
      expect(await fake.submit(intent), isA<WalletMutationRemoteSuccess>());
      expect(
        await fake.submit(intent),
        isA<WalletMutationPostTransmissionAmbiguity>(),
      );
      expect(
        await fake.submit(intent),
        isA<WalletMutationReconciledOwnership>(),
      );
      expect(fake.submitted, hasLength(4));
    },
  );

  test('mutation success and ownership evidence validate in release code', () {
    expect(
      () => WalletMutationRemoteSuccess(
        statusCode: 500,
        remoteRecordId: 'remote-1',
      ),
      throwsArgumentError,
    );
    expect(
      () => WalletMutationRemoteSuccess(statusCode: 200, remoteRecordId: ''),
      throwsArgumentError,
    );
    expect(() => WalletMutationReconciledOwnership(''), throwsArgumentError);
  });
}

/// Local stub. M5.22 WP-B deleted `WalletMutationPort`; the ledger never
/// depended on it, so this no longer implements anything.
final class _FakeWalletMutationPort {
  _FakeWalletMutationPort(Iterable<WalletMutationResult> outcomes)
    : _outcomes = Queue<WalletMutationResult>.of(outcomes);

  final Queue<WalletMutationResult> _outcomes;
  final List<WalletMutationIntent> submitted = <WalletMutationIntent>[];

  Future<WalletMutationResult> submit(WalletMutationIntent intent) async {
    submitted.add(intent);
    if (_outcomes.isEmpty) return const WalletMutationPreTransmissionFailure();
    return _outcomes.removeFirst();
  }
}
