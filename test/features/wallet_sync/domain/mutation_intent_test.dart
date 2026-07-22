import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

void main() {
  WalletMutationIntent intent({
    String id = 'mutation-1',
    String candidateId = 'candidate-1',
    WalletMutationState state = WalletMutationState.queued,
    WalletMutationOperation operation = WalletMutationOperation.create,
    int operationRevision = 1,
    int lineageGeneration = 1,
    String createLineageKey = 'lineage-key-1',
    String transactionFingerprint = 'fingerprint-1',
    Map<String, Object?> payload = const <String, Object?>{
      'amountMinor': -4500,
      'currency': 'LKR',
    },
  }) => WalletMutationIntent(
    id: id,
    candidateId: candidateId,
    operation: operation,
    operationRevision: operationRevision,
    lineageGeneration: lineageGeneration,
    createLineageKey: createLineageKey,
    transactionFingerprint: transactionFingerprint,
    payload: payload,
    state: state,
  );

  final legalTransitions = <WalletMutationState, Set<WalletMutationState>>{
    WalletMutationState.queued: {
      WalletMutationState.syncing,
      WalletMutationState.supersededBeforeSend,
    },
    WalletMutationState.syncing: {
      WalletMutationState.reconciling,
      WalletMutationState.unknownDelivery,
      WalletMutationState.unknownUpdate,
      WalletMutationState.unknownDelete,
      WalletMutationState.retryScheduled,
      WalletMutationState.succeeded,
      WalletMutationState.permanentFailure,
    },
    WalletMutationState.reconciling: {
      WalletMutationState.succeeded,
      WalletMutationState.retryScheduled,
      WalletMutationState.permanentFailure,
    },
    WalletMutationState.unknownDelivery: {WalletMutationState.reconciling},
    WalletMutationState.unknownUpdate: {WalletMutationState.reconciling},
    WalletMutationState.unknownDelete: {WalletMutationState.reconciling},
    WalletMutationState.retryScheduled: {WalletMutationState.syncing},
    WalletMutationState.succeeded: {},
    WalletMutationState.permanentFailure: {},
    WalletMutationState.supersededBeforeSend: {},
  };

  group('WalletMutationState transitions', () {
    test(
      'permits exactly every documented transition and rejects every other',
      () {
        for (final from in WalletMutationState.values) {
          for (final to in WalletMutationState.values) {
            final isLegal = legalTransitions[from]!.contains(to);
            expect(
              from.canTransitionTo(to),
              isLegal,
              reason: '$from -> $to must be ${isLegal ? 'legal' : 'illegal'}',
            );
          }
        }
      },
    );

    test('creates a separate immutable value for every legal transition', () {
      for (final entry in legalTransitions.entries) {
        for (final next in entry.value) {
          final original = intent(state: entry.key);
          final transitioned = original.transitionTo(next);

          expect(transitioned.state, next);
          expect(original.state, entry.key);
          expect(transitioned, isNot(same(original)));
          expect(transitioned.payload, original.payload);
        }
      }
    });

    test('throws a typed failure for every illegal transition', () {
      for (final from in WalletMutationState.values) {
        for (final to in WalletMutationState.values) {
          if (legalTransitions[from]!.contains(to)) {
            continue;
          }
          expect(
            () => intent(state: from).transitionTo(to),
            throwsA(
              isA<InvalidStateTransitionFailure>()
                  .having((failure) => failure.from, 'from', from.name)
                  .having((failure) => failure.to, 'to', to.name),
            ),
          );
        }
      }
    });
  });

  group('WalletMutationIntent', () {
    test('preserves every operation and stable identity field', () {
      for (final operation in WalletMutationOperation.values) {
        final value = intent(operation: operation);

        expect(value.operation, operation);
        expect(value.operationRevision, 1);
        expect(value.lineageGeneration, 1);
        expect(value.createLineageKey, 'lineage-key-1');
        expect(value.transactionFingerprint, 'fingerprint-1');
      }
    });

    test('rejects invalid identity, revision, and lineage invariants', () {
      final invalidValues = <WalletMutationIntent Function()>[
        () => intent(id: ''),
        () => intent(candidateId: ''),
        () => intent(operationRevision: 0),
        () => intent(lineageGeneration: 0),
        () => intent(createLineageKey: ''),
        () => intent(transactionFingerprint: ''),
      ];

      for (final createInvalidIntent in invalidValues) {
        expect(
          createInvalidIntent,
          throwsA(isA<InvalidMutationIntentFailure>()),
        );
      }
    });

    test('does not permit source identity or lineage generation to change', () {
      final queued = intent();

      expect(
        () => queued.copyWith(candidateId: 'candidate-2'),
        throwsA(isA<InvalidMutationIntentFailure>()),
      );
      expect(
        () => queued.copyWith(lineageGeneration: 2),
        throwsA(isA<InvalidMutationIntentFailure>()),
      );
    });

    test('deep freezes supplied nested maps and lists', () {
      final suppliedPayload = <String, Object?>{
        'mapping': <String, Object?>{'category': 'food'},
        'tags': <Object?>['synthetic'],
      };
      final value = intent(payload: suppliedPayload);
      (suppliedPayload['mapping']! as Map<String, Object?>)['category'] =
          'travel';
      (suppliedPayload['tags']! as List<Object?>).add('changed');

      final frozenMapping = value.payload['mapping']! as Map<dynamic, dynamic>;
      final frozenTags = value.payload['tags']! as List<dynamic>;
      expect(frozenMapping['category'], 'food');
      expect(frozenTags, ['synthetic']);
      expect(() => value.payload['currency'] = 'USD', throwsUnsupportedError);
      expect(
        () => frozenMapping['category'] = 'travel',
        throwsUnsupportedError,
      );
      expect(() => frozenTags.add('changed'), throwsUnsupportedError);
    });

    test('copies payload independently while retaining immutable lineage', () {
      final original = intent();
      final revised = original.copyWith(
        payload: <String, Object?>{'currency': 'USD', 'amountMinor': -9000},
      );

      expect(original.payload, {'amountMinor': -4500, 'currency': 'LKR'});
      expect(revised.payload, {'currency': 'USD', 'amountMinor': -9000});
      expect(revised.candidateId, original.candidateId);
      expect(revised.lineageGeneration, original.lineageGeneration);
      expect(revised, isNot(same(original)));
    });
  });
}
