import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

/// G4.4 — Timeout classification: pre-transmission failure must map to
/// `RetryablePreTransmission` and post-transmission ambiguity must map to
/// `AmbiguousPostTransmission`.
///
/// This distinction is critical because only pre-transmission failures may
/// be retried safely. Post-transmission ambiguities must go through
/// reconciliation first — retrying blindly would risk creating a duplicate
/// financial record (plan/05 §Retry; M5.6).
///
/// The mapper maps these onto the state space: `RetryablePreTransmission`
/// -> `retryScheduled` (safe to resend), `AmbiguousPostTransmission` ->
/// `unknownDelivery` (must reconcile before any retry).
void main() {
  const mapper = WalletMutationFailureMapper();

  group('classifyWalletMutationFailure', () {
    test(
      'null statusCode before transmission maps to RetryablePreTransmission',
      () {
        // DNS failure, offline, or connection refused before the request
        // left the device. No bytes hit the wire, so resending is safe.
        final classification = classifyWalletMutationFailure(
          statusCode: null,
          transmissionMayHaveBegun: false,
        );
        expect(
          classification,
          isA<RetryablePreTransmission>(),
          reason:
              'pre-transmission failure must be retryable without '
              'reconciliation — the server never saw the request',
        );
      },
    );

    test(
      'null statusCode after transmission maps to AmbiguousPostTransmission',
      () {
        // The request was handed to the transport but we got no response
        // (timeout, connection reset after send). The server may or may not
        // have applied it. Reconcile before retry.
        final classification = classifyWalletMutationFailure(
          statusCode: null,
          transmissionMayHaveBegun: true,
        );
        expect(
          classification,
          isA<AmbiguousPostTransmission>(),
          reason:
              'post-transmission timeout must not auto-retry; the '
              'server may have applied the create',
        );
      },
    );

    test('500 before transmission maps to RetryablePreTransmission', () {
      final classification = classifyWalletMutationFailure(
        statusCode: 500,
        transmissionMayHaveBegun: false,
      );
      expect(classification, isA<RetryablePreTransmission>());
    });

    test('500 after transmission maps to AmbiguousPostTransmission', () {
      // The 5xx came back, but we cannot prove the server did not apply
      // the create before failing. Reconcile first.
      final classification = classifyWalletMutationFailure(
        statusCode: 500,
        transmissionMayHaveBegun: true,
      );
      expect(classification, isA<AmbiguousPostTransmission>());
    });

    test('503 before transmission maps to RetryablePreTransmission', () {
      final classification = classifyWalletMutationFailure(
        statusCode: 503,
        transmissionMayHaveBegun: false,
      );
      expect(classification, isA<RetryablePreTransmission>());
    });

    test('503 after transmission maps to AmbiguousPostTransmission', () {
      final classification = classifyWalletMutationFailure(
        statusCode: 503,
        transmissionMayHaveBegun: true,
      );
      expect(classification, isA<AmbiguousPostTransmission>());
    });

    test('200 maps to AmbiguousPostTransmission (malformed success body)', () {
      // A 200 with a malformed body is treated defensively as ambiguous.
      // The caller must reconcile, not retry.
      final classification = classifyWalletMutationFailure(
        statusCode: 200,
        transmissionMayHaveBegun: true,
      );
      expect(
        classification,
        isA<AmbiguousPostTransmission>(),
        reason:
            'a 200 with bad body must not auto-retry; the record '
            'may exist in Wallet',
      );
    });
  });

  group('WalletMutationFailureMapper.toPortResult', () {
    test('RetryablePreTransmission maps to WalletMutationServerFailure', () {
      final result = mapper.toPortResult(const RetryablePreTransmission());
      expect(result, isA<WalletMutationServerFailure>());
    });

    test(
      'AmbiguousPostTransmission maps to WalletMutationPostTransmissionAmbiguity',
      () {
        final result = mapper.toPortResult(const AmbiguousPostTransmission());
        expect(result, isA<WalletMutationPostTransmissionAmbiguity>());
      },
    );
  });

  group('stateForClassification', () {
    test('RetryablePreTransmission maps to retryScheduled', () {
      final state = stateForClassification(const RetryablePreTransmission());
      expect(
        state,
        WalletMutationState.retryScheduled,
        reason: 'pre-transmission failures are safe to retry immediately',
      );
    });

    test('AmbiguousPostTransmission maps to unknownDelivery', () {
      final state = stateForClassification(const AmbiguousPostTransmission());
      expect(
        state,
        WalletMutationState.unknownDelivery,
        reason:
            'ambiguous post-transmission must enter reconciliation, '
            'not a blind retry',
      );
    });

    test('unknownDelivery cannot transition back to syncing directly', () {
      // The state table routes unknownDelivery -> reconciling only.
      // This is the structural guard against blind retry.
      expect(
        WalletMutationState.unknownDelivery.canTransitionTo(
          WalletMutationState.syncing,
        ),
        isFalse,
        reason:
            'unknownDelivery must not jump to syncing; it must go '
            'through reconciling first',
      );
      expect(
        WalletMutationState.unknownDelivery.canTransitionTo(
          WalletMutationState.reconciling,
        ),
        isTrue,
        reason: 'reconciling is the only legal exit from unknownDelivery',
      );
    });
  });
}
