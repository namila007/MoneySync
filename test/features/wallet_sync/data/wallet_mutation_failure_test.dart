import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutation_failure.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

void main() {
  group('classifyWalletMutationFailure (plan/05 §Retry)', () {
    test('400 is a permanent client failure', () {
      expect(
        classifyWalletMutationFailure(
          statusCode: 400,
          transmissionMayHaveBegun: false,
        ),
        isA<PermanentClientFailure>(),
      );
    });

    test('401/403 require authentication', () {
      for (final code in [401, 403]) {
        expect(
          classifyWalletMutationFailure(
            statusCode: code,
            transmissionMayHaveBegun: false,
          ),
          isA<AuthenticationRequired>(),
        );
      }
    });

    test(
      'initial-sync 409 is retryable conflict honoring retry_after_minutes',
      () {
        final classification = classifyWalletMutationFailure(
          statusCode: 409,
          errorCode: 'init_sync_in_progress',
          retryAfterMinutes: 5,
          transmissionMayHaveBegun: false,
        );
        expect(classification, isA<RetryableConflict>());
        expect((classification as RetryableConflict).retryAfterMinutes, 5);
      },
    );

    test('other 409 is NOT blanket retried', () {
      expect(
        classifyWalletMutationFailure(
          statusCode: 409,
          errorCode: 'other_conflict',
          transmissionMayHaveBegun: false,
        ),
        isA<PermanentClientFailure>(),
      );
    });

    test('429 is rate limited honoring Retry-After', () {
      final classification = classifyWalletMutationFailure(
        statusCode: 429,
        retryAfterSeconds: 30,
        transmissionMayHaveBegun: false,
      );
      expect(classification, isA<RateLimited>());
      expect((classification as RateLimited).retryAfterSeconds, 30);
    });

    test('5xx proven pre-execution is retryable pre-transmission', () {
      expect(
        classifyWalletMutationFailure(
          statusCode: 503,
          transmissionMayHaveBegun: false,
        ),
        isA<RetryablePreTransmission>(),
      );
    });

    test('5xx after send began is ambiguous post-transmission', () {
      expect(
        classifyWalletMutationFailure(
          statusCode: 503,
          transmissionMayHaveBegun: true,
        ),
        isA<AmbiguousPostTransmission>(),
      );
    });

    test(
      'null status (DNS/offline/timeout) classifies by transmission state',
      () {
        expect(
          classifyWalletMutationFailure(
            statusCode: null,
            transmissionMayHaveBegun: false,
          ),
          isA<RetryablePreTransmission>(),
        );
        expect(
          classifyWalletMutationFailure(
            statusCode: null,
            transmissionMayHaveBegun: true,
          ),
          isA<AmbiguousPostTransmission>(),
        );
      },
    );
  });

  group('WalletMutationFailureMapper', () {
    const mapper = WalletMutationFailureMapper();

    test(
      'only AmbiguousPostTransmission maps to post-transmission ambiguity',
      () {
        final mapping = <WalletMutationFailureClassification, Type>{
          const AmbiguousPostTransmission():
              WalletMutationPostTransmissionAmbiguity,
          const PermanentClientFailure(): WalletMutationClientFailure,
          const AuthenticationRequired(): WalletMutationClientFailure,
          const RetryableConflict(): WalletMutationServerFailure,
          const RateLimited(): WalletMutationServerFailure,
          const RetryablePreTransmission(): WalletMutationServerFailure,
        };
        for (final entry in mapping.entries) {
          expect(
            mapper.toPortResult(entry.key),
            isA<WalletMutationResult>().having(
              (r) => r.runtimeType,
              'type',
              entry.value,
            ),
          );
        }
      },
    );
  });

  group('stateForClassification', () {
    test('maps each classification to the domain state', () {
      expect(
        stateForClassification(const AmbiguousPostTransmission()),
        WalletMutationState.unknownDelivery,
      );
      expect(
        stateForClassification(const PermanentClientFailure()),
        WalletMutationState.permanentFailure,
      );
      expect(
        stateForClassification(const AuthenticationRequired()),
        WalletMutationState.permanentFailure,
      );
      expect(
        stateForClassification(const RetryableConflict()),
        WalletMutationState.retryScheduled,
      );
      expect(
        stateForClassification(const RateLimited()),
        WalletMutationState.retryScheduled,
      );
      expect(
        stateForClassification(const RetryablePreTransmission()),
        WalletMutationState.retryScheduled,
      );
    });
  });
}
