import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule rule() => MappingRule(
    id: 'rule-1',
    name: 'R1',
    enabled: true,
    senderMatcher: SenderMatcher(['BANK ALPHA', 'BANK BETA']),
    instrumentSuffixHash: '••56',
    walletAccountId: 'wallet-1',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: 0,
    ruleVersion: 3,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  group('matcher value semantics', () {
    test('sender matcher normalizes and matches exact aliases', () {
      final matcher = SenderMatcher(['bank alpha', 'BANK BETA']);
      expect(matcher.aliases, ['BANK ALPHA', 'BANK BETA']);
      expect(matcher.matches('BANK ALPHA'), isTrue);
      expect(matcher.matches('bank beta'), isTrue);
      expect(matcher.matches('OTHER BANK'), isFalse);
    });

    test('sender matcher rejects an empty alias set', () {
      expect(() => SenderMatcher([]), throwsA(isA<Exception>()));
    });

    test('exact merchant matcher matches case-insensitively', () {
      const matcher = ExactMerchantMatcher('CAFE');
      expect(matcher.matches('cafe'), isTrue);
      expect(matcher.matches('CAFÉ'), isFalse);
      expect(const ExactMerchantMatcher('CAFE'), const ExactMerchantMatcher('CAFE'));
      expect(
        const ExactMerchantMatcher('CAFE').hashCode,
        const ExactMerchantMatcher('CAFE').hashCode,
      );
    });

    test('contains merchant matcher matches substrings case-insensitively', () {
      const matcher = ContainsMerchantMatcher('cafe');
      expect(matcher.matches('REDACTED CAFE X'), isTrue);
      expect(matcher.matches('CAFETERIA'), isTrue);
      expect(matcher.matches('STORE'), isFalse);
      expect(
        const ContainsMerchantMatcher('cafe'),
        const ContainsMerchantMatcher('cafe'),
      );
      expect(
        const ContainsMerchantMatcher('cafe').hashCode,
        const ContainsMerchantMatcher('cafe').hashCode,
      );
    });
  });

  group('MappingRule', () {
    test('nextVersion increments ruleVersion and clears superseded link', () {
      final next = rule().nextVersion(supersededByRuleId: 'rule-1');
      expect(next.ruleVersion, 4);
      expect(next.supersededByRuleId, 'rule-1');
      expect(next.enabled, rule().enabled);
      expect(next.walletAccountId, 'wallet-1');
      expect(rule().ruleVersion, 3); // original unchanged
    });

    test('rejects invalid rule fields', () {
      expect(
        () => MappingRule(
          id: '',
          name: 'x',
          enabled: true,
          senderMatcher: SenderMatcher(['A']),
          walletAccountId: 'w',
          paymentType: 'p',
          syncMode: MappingSyncMode.review,
          priority: 0,
          ruleVersion: 1,
          createdAtEpochMs: now,
          updatedAtEpochMs: now,
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => MappingRule(
          id: 'r',
          name: 'x',
          enabled: true,
          senderMatcher: SenderMatcher(['A']),
          walletAccountId: 'w',
          paymentType: 'p',
          syncMode: MappingSyncMode.review,
          priority: 0,
          ruleVersion: 0,
          createdAtEpochMs: now,
          updatedAtEpochMs: now,
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => MappingRule(
          id: 'r',
          name: 'x',
          enabled: true,
          senderMatcher: SenderMatcher(['A']),
          walletAccountId: 'w',
          paymentType: 'p',
          syncMode: MappingSyncMode.review,
          priority: 0,
          ruleVersion: 1,
          minConfidenceBasisPoints: 10001,
          createdAtEpochMs: now,
          updatedAtEpochMs: now,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
