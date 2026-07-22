import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/money/currency.dart';
import 'package:money_sync/core/money/money.dart';
import 'package:money_sync/core/time/source_date_evidence.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

void main() {
  final lkr = Currency(code: 'LKR', decimalDigits: 2);
  final timestamp = DateTime.utc(2026, 7, 22, 6, 30);

  Money amountFor(TransactionDirection direction) => Money(
    minorUnits: switch (direction) {
      TransactionDirection.debit => -4500,
      TransactionDirection.credit => 4500,
      TransactionDirection.neutral => 0,
    },
    currency: lkr,
  );

  CandidateProvenance provenance() => CandidateProvenance(
    parserRuleId: 'synthetic-rule',
    parserRuleVersion: '1.0.0',
    captureCanonicalizationVersion: 1,
    sourceDateEvidence: SourceDateEvidence(
      instantUtc: timestamp,
      source: DateEvidenceSource.receivedAtUtc,
      originalValue: 'synthetic',
      parsingContext: SourceTimeZoneContext.utc,
    ),
  );

  TransactionCandidate candidate({
    String id = 'candidate-1',
    String sourceMessageKey = 'key-1',
    TransactionKind kind = TransactionKind.expense,
    TransactionDirection direction = TransactionDirection.debit,
    FinancialLifecycle lifecycle = FinancialLifecycle.posted,
    Money? originalAmount,
    DateTime? transactionAtUtc,
    CandidateConfidence? confidence,
    Set<ReviewReason> reviewReasons = const <ReviewReason>{},
    CandidateProvenance? candidateProvenance,
  }) => TransactionCandidate(
    id: id,
    sourceMessageKey: sourceMessageKey,
    kind: kind,
    direction: direction,
    lifecycle: lifecycle,
    originalAmount: originalAmount ?? amountFor(direction),
    transactionAtUtc: transactionAtUtc ?? timestamp,
    confidence: confidence ?? CandidateConfidence(basisPoints: 9200),
    reviewReasons: reviewReasons,
    provenance: candidateProvenance ?? provenance(),
  );

  group('CandidateConfidence', () {
    test('accepts inclusive bounds and assigns every confidence band', () {
      expect(CandidateConfidence(basisPoints: 0).band, ConfidenceBand.low);
      expect(CandidateConfidence(basisPoints: 6999).band, ConfidenceBand.low);
      expect(
        CandidateConfidence(basisPoints: 7000).band,
        ConfidenceBand.medium,
      );
      expect(
        CandidateConfidence(basisPoints: 8999).band,
        ConfidenceBand.medium,
      );
      expect(CandidateConfidence(basisPoints: 9000).band, ConfidenceBand.high);
      expect(CandidateConfidence(basisPoints: 10000).band, ConfidenceBand.high);
    });

    test('rejects values outside the inclusive confidence range', () {
      expect(
        () => CandidateConfidence(basisPoints: -1),
        throwsA(isA<InvalidCandidateFailure>()),
      );
      expect(
        () => CandidateConfidence(basisPoints: 10001),
        throwsA(isA<InvalidCandidateFailure>()),
      );
    });

    test('uses value equality', () {
      expect(
        CandidateConfidence(basisPoints: 9200),
        CandidateConfidence(basisPoints: 9200),
      );
      expect(
        CandidateConfidence(basisPoints: 9200),
        isNot(CandidateConfidence(basisPoints: 9199)),
      );
    });
  });

  group('TransactionCandidate semantics', () {
    final validDirections = <TransactionKind, Set<TransactionDirection>>{
      TransactionKind.expense: {TransactionDirection.debit},
      TransactionKind.income: {TransactionDirection.credit},
      TransactionKind.refund: {TransactionDirection.credit},
      TransactionKind.transfer: {
        TransactionDirection.debit,
        TransactionDirection.credit,
      },
      TransactionKind.authorization: {TransactionDirection.debit},
      TransactionKind.settlement: {TransactionDirection.debit},
      TransactionKind.reversal: {TransactionDirection.credit},
      TransactionKind.nonTransaction: {TransactionDirection.neutral},
      TransactionKind.unknown: {TransactionDirection.neutral},
    };
    final validLifecycles = <TransactionKind, Set<FinancialLifecycle>>{
      TransactionKind.expense: {FinancialLifecycle.posted},
      TransactionKind.income: {FinancialLifecycle.posted},
      TransactionKind.refund: {FinancialLifecycle.posted},
      TransactionKind.transfer: {FinancialLifecycle.posted},
      TransactionKind.authorization: {
        FinancialLifecycle.authorized,
        FinancialLifecycle.awaitingSettlement,
      },
      TransactionKind.settlement: {FinancialLifecycle.settled},
      TransactionKind.reversal: {FinancialLifecycle.reversed},
      TransactionKind.nonTransaction: {FinancialLifecycle.unclassified},
      TransactionKind.unknown: {FinancialLifecycle.unclassified},
    };

    test('accepts every legal kind, direction, and lifecycle combination', () {
      for (final kind in TransactionKind.values) {
        for (final direction in validDirections[kind]!) {
          for (final lifecycle in validLifecycles[kind]!) {
            expect(
              () => candidate(
                kind: kind,
                direction: direction,
                lifecycle: lifecycle,
              ),
              returnsNormally,
              reason: '$kind / $direction / $lifecycle should be valid',
            );
          }
        }
      }
    });

    test('rejects every illegal kind-direction combination', () {
      for (final kind in TransactionKind.values) {
        for (final direction in TransactionDirection.values) {
          final isLegal = validDirections[kind]!.contains(direction);
          expect(
            () => candidate(
              kind: kind,
              direction: direction,
              lifecycle: validLifecycles[kind]!.first,
            ),
            isLegal ? returnsNormally : throwsA(isA<InvalidCandidateFailure>()),
            reason:
                '$kind / $direction must be ${isLegal ? 'accepted' : 'rejected'}',
          );
        }
      }
    });

    test('rejects every illegal lifecycle for each transaction kind', () {
      for (final kind in TransactionKind.values) {
        for (final lifecycle in FinancialLifecycle.values) {
          final isLegal = validLifecycles[kind]!.contains(lifecycle);
          expect(
            () => candidate(
              kind: kind,
              direction: validDirections[kind]!.first,
              lifecycle: lifecycle,
            ),
            isLegal ? returnsNormally : throwsA(isA<InvalidCandidateFailure>()),
            reason:
                '$kind / $lifecycle must be ${isLegal ? 'accepted' : 'rejected'}',
          );
        }
      }
    });

    test('rejects amount signs that contradict the direction', () {
      expect(
        () => candidate(originalAmount: amountFor(TransactionDirection.credit)),
        throwsA(isA<InvalidCandidateFailure>()),
      );
      expect(
        () => candidate(
          kind: TransactionKind.income,
          direction: TransactionDirection.credit,
          originalAmount: amountFor(TransactionDirection.neutral),
        ),
        throwsA(isA<InvalidCandidateFailure>()),
      );
      expect(
        () => candidate(
          kind: TransactionKind.unknown,
          direction: TransactionDirection.neutral,
          originalAmount: amountFor(TransactionDirection.debit),
          lifecycle: FinancialLifecycle.unclassified,
        ),
        throwsA(isA<InvalidCandidateFailure>()),
      );
    });

    test('requires review for policy kinds or explicit review reasons', () {
      final policyKinds = <TransactionKind>{
        TransactionKind.authorization,
        TransactionKind.refund,
        TransactionKind.transfer,
        TransactionKind.unknown,
      };

      for (final kind in TransactionKind.values) {
        final value = candidate(
          kind: kind,
          direction: validDirections[kind]!.first,
          lifecycle: validLifecycles[kind]!.first,
        );
        expect(value.requiresReview, policyKinds.contains(kind));
      }

      expect(
        candidate(reviewReasons: {ReviewReason.lowConfidence}).requiresReview,
        isTrue,
      );
    });

    test('validates identity and a UTC transaction timestamp', () {
      expect(() => candidate(id: ''), throwsA(isA<InvalidCandidateFailure>()));
      expect(
        () => candidate(sourceMessageKey: ''),
        throwsA(isA<InvalidCandidateFailure>()),
      );
      expect(
        () => candidate(transactionAtUtc: DateTime(2026, 7, 22)),
        throwsA(isA<InvalidCandidateFailure>()),
      );
    });

    test(
      'copies independently and freezes review reasons at both boundaries',
      () {
        final suppliedReasons = <ReviewReason>{ReviewReason.lowConfidence};
        final original = candidate(reviewReasons: suppliedReasons);
        suppliedReasons.add(ReviewReason.transfer);
        final revised = original.copyWith(
          confidence: CandidateConfidence(basisPoints: 7000),
          reviewReasons: {ReviewReason.ambiguousMapping},
        );

        expect(original.reviewReasons, {ReviewReason.lowConfidence});
        expect(
          () => original.reviewReasons.add(ReviewReason.transfer),
          throwsUnsupportedError,
        );
        expect(revised.reviewReasons, {ReviewReason.ambiguousMapping});
        expect(revised.confidence.band, ConfidenceBand.medium);
        expect(revised, isNot(same(original)));
      },
    );
  });
}
