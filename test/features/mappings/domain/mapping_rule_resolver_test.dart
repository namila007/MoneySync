import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule rule({
    required String id,
    String sender = 'SAMPATH BANK',
    bool enabled = true,
    String? parserFamily,
    String? instrumentSuffixHash,
    TransactionDirection? direction,
    MerchantMatcher? merchantMatcher,
    int priority = 0,
    int? minConfidenceBasisPoints,
    int ruleVersion = 1,
  }) => MappingRule(
    id: id,
    name: id,
    enabled: enabled,
    senderMatcher: SenderMatcher([sender]),
    parserFamily: parserFamily,
    instrumentSuffixHash: instrumentSuffixHash,
    direction: direction,
    merchantMatcher: merchantMatcher,
    walletAccountId: 'wallet-$id',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: priority,
    minConfidenceBasisPoints: minConfidenceBasisPoints,
    ruleVersion: ruleVersion,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  const input = MappingResolutionInput(
    senderNormalized: 'SAMPATH BANK',
    confidenceBasisPoints: 9500,
    merchantNormalized: 'REDACTED MERCHANT',
  );

  group('MappingRuleResolver precedence (plan/03 §Mapping resolution)', () {
    test('no enabled rule matches -> MappingUnmatched', () {
      final resolver = MappingRuleResolver(
        rules: [rule(id: 'a', sender: 'NDB')],
      );
      expect(resolver.resolve(input), const MappingUnmatched());
    });

    test('sender-only match -> MappingResolved', () {
      final resolver = MappingRuleResolver(rules: [rule(id: 'a')]);
      expect(resolver.resolve(input), isA<MappingResolved>());
    });

    test('disabled rules never match', () {
      final resolver = MappingRuleResolver(
        rules: [rule(id: 'a', enabled: false)],
      );
      expect(resolver.resolve(input), const MappingUnmatched());
    });

    test('rank 4 (sender only) loses to rank 3 (sender + family)', () {
      final resolver = MappingRuleResolver(
        rules: [
          rule(id: 'broad', priority: 100),
          rule(id: 'specific', parserFamily: 'lk.sampath.account'),
        ],
      );
      final resolution = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'X',
          parserFamily: 'lk.sampath.account',
        ),
      );
      final resolved = resolution as MappingResolved;
      expect(resolved.rule.id, 'specific');
    });

    test(
      'rank 3 (sender + direction) loses to rank 2 (sender + instrument)',
      () {
        final resolver = MappingRuleResolver(
          rules: [
            rule(id: 'family', parserFamily: 'lk.sampath.account'),
            rule(
              id: 'instrument',
              instrumentSuffixHash: 'hash-1234',
              parserFamily: 'lk.sampath.account',
            ),
          ],
        );
        final resolution = resolver.resolve(
          const MappingResolutionInput(
            senderNormalized: 'SAMPATH BANK',
            confidenceBasisPoints: 9500,
            merchantNormalized: 'X',
            parserFamily: 'lk.sampath.account',
            instrumentSuffixHash: 'hash-1234',
          ),
        );
        final resolved = resolution as MappingResolved;
        expect(resolved.rule.id, 'instrument');
      },
    );

    test('rank 1 (sender + instrument + family + direction) wins', () {
      final resolver = MappingRuleResolver(
        rules: [
          rule(id: 'instrument', instrumentSuffixHash: 'hash-1234'),
          rule(
            id: 'full',
            parserFamily: 'lk.sampath.account',
            instrumentSuffixHash: 'hash-1234',
            direction: TransactionDirection.debit,
          ),
        ],
      );
      final resolution = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'X',
          parserFamily: 'lk.sampath.account',
          instrumentSuffixHash: 'hash-1234',
          direction: TransactionDirection.debit,
        ),
      );
      final resolved = resolution as MappingResolved;
      expect(resolved.rule.id, 'full');
    });

    test('same bucket -> higher priority wins', () {
      final resolver = MappingRuleResolver(
        rules: [
          rule(id: 'low', priority: 1),
          rule(id: 'high', priority: 50),
        ],
      );
      final resolution = resolver.resolve(input) as MappingResolved;
      expect(resolution.rule.id, 'high');
    });

    test(
      'same bucket + same priority -> MappingAmbiguous (never by createdAt)',
      () {
        final resolver = MappingRuleResolver(
          rules: [
            rule(id: 'a'),
            rule(id: 'b'),
          ],
        );
        final resolution = resolver.resolve(input);
        final ambiguous = resolution as MappingAmbiguous;
        expect(ambiguous.tiedRules.map((r) => r.id).toSet(), {'a', 'b'});
      },
    );

    test('instrument-only rule requires input instrument to match', () {
      final resolver = MappingRuleResolver(
        rules: [rule(id: 'instrument', instrumentSuffixHash: 'hash-1')],
      );
      final noInstrument = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'X',
        ),
      );
      expect(noInstrument, isA<MappingUnmatched>());
    });

    test('merchant matcher filters non-matching merchants', () {
      final resolver = MappingRuleResolver(
        rules: [
          rule(
            id: 'merchant',
            merchantMatcher: const ExactMerchantMatcher('CAFE'),
          ),
        ],
      );
      final unmatched = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'SUPERMARKET',
        ),
      );
      expect(unmatched, isA<MappingUnmatched>());

      final matched = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'CAFE',
        ),
      );
      expect((matched as MappingResolved).rule.id, 'merchant');
    });

    test('confidence floor below threshold blocks resolution', () {
      final resolver = MappingRuleResolver(
        rules: [rule(id: 'a', minConfidenceBasisPoints: 9000)],
      );
      final low = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 7000,
          merchantNormalized: 'X',
        ),
      );
      expect(low, isA<MappingUnmatched>());
    });

    test('direction mismatch excludes rank-3 rule', () {
      final resolver = MappingRuleResolver(
        rules: [rule(id: 'creditOnly', direction: TransactionDirection.credit)],
      );
      final resolution = resolver.resolve(
        const MappingResolutionInput(
          senderNormalized: 'SAMPATH BANK',
          confidenceBasisPoints: 9500,
          merchantNormalized: 'X',
          direction: TransactionDirection.debit,
        ),
      );
      expect(resolution, isA<MappingUnmatched>());
    });
  });
}
