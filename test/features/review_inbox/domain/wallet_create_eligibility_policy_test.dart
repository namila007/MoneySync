import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule resolvedRule() => MappingRule(
    id: 'rule-1',
    name: 'R1',
    enabled: true,
    senderMatcher: SenderMatcher(['BANK ALPHA']),
    walletAccountId: 'account-1',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: 0,
    ruleVersion: 1,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  PreSendContext context({
    bool privacyEpochMatches = true,
    bool consentCurrent = true,
    bool connectionConnected = true,
    bool eligibleTargetAccount = true,
    WalletAccountEligibility targetEligibility = WalletAccountEligibility.eligible,
    MappingResolution mapping =
        const MappingUnmatched(),
    int amountMinor = -4500,
    String currencyCode = 'LKR',
    DateTime? recordDateUtc,
    bool capabilityCanCreate = true,
    bool hasActiveLineage = false,
    bool hasOwnedRecordLink = false,
    int confidenceBasisPoints = 9500,
    TransactionDirection direction = TransactionDirection.debit,
  }) => PreSendContext(
    candidateId: 'candidate-1',
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    recordDateUtc: recordDateUtc ?? DateTime.utc(2026, 7, 18),
    direction: direction,
    paymentType: 'debit_card',
    senderNormalized: 'BANK ALPHA',
    confidenceBasisPoints: confidenceBasisPoints,
    privacyEpochMatches: privacyEpochMatches,
    consentCurrent: consentCurrent,
    connectionConnected: connectionConnected,
    eligibleTargetAccount: eligibleTargetAccount,
    targetAccountEligibility: targetEligibility,
    mappingResolution: mapping,
    capabilityCanCreate: capabilityCanCreate,
    hasActiveLineage: hasActiveLineage,
    hasOwnedRecordLink: hasOwnedRecordLink,
  );

  group('PrivacyEpochGate', () {
    test('passes when epoch matches', () {
      expect(
        const PrivacyEpochGate().check(context(privacyEpochMatches: true)),
        isA<GatePass>(),
      );
    });

    test('blocks on stale epoch', () {
      expect(
        const PrivacyEpochGate().check(context(privacyEpochMatches: false)),
        isA<GateBlock>(),
      );
    });
  });

  group('ConsentGate', () {
    test('passes when consent is current', () {
      expect(
        const ConsentGate().check(context(consentCurrent: true)),
        isA<GatePass>(),
      );
    });

    test('blocks on non-current consent', () {
      expect(
        const ConsentGate().check(context(consentCurrent: false)),
        isA<GateBlock>(),
      );
    });
  });

  group('WalletConnectionGate', () {
    test('passes when connected', () {
      expect(
        const WalletConnectionGate().check(context(connectionConnected: true)),
        isA<GatePass>(),
      );
    });

    test('blocks when disconnected', () {
      expect(
        const WalletConnectionGate().check(context(connectionConnected: false)),
        isA<GateBlock>(),
      );
    });
  });

  group('AccountEligibilityGate', () {
    test('passes for an eligible account', () {
      expect(
        const AccountEligibilityGate().check(context()),
        isA<GatePass>(),
      );
    });

    test('blocks on unwritable account', () {
      final result = const AccountEligibilityGate().check(
        context(
          eligibleTargetAccount: false,
          targetEligibility: WalletAccountEligibility.unwritable,
        ),
      );
      expect(result, isA<GateBlock>());
      expect((result as GateBlock).reason, contains('not writable'));
    });

    test('blocks on bank-synced account even when flagged writable', () {
      expect(
        const AccountEligibilityGate().check(
          context(
            eligibleTargetAccount: true,
            targetEligibility: WalletAccountEligibility.bankSynced,
          ),
        ),
        isA<GateBlock>(),
      );
    });
  });

  group('MappingResolutionGate', () {
    test('passes when a rule resolves (review mode, any confidence)', () {
      final result = const MappingResolutionGate().check(
        context(mapping: MappingResolved(resolvedRule())),
      );
      expect(result, isA<GatePass>());
    });

    test('passes for automatic rule above confidence floor', () {
      final automatic = resolvedRule();
      final rule = MappingRule(
        id: automatic.id,
        name: automatic.name,
        enabled: automatic.enabled,
        senderMatcher: automatic.senderMatcher,
        walletAccountId: automatic.walletAccountId,
        paymentType: automatic.paymentType,
        syncMode: MappingSyncMode.automatic,
        priority: automatic.priority,
        ruleVersion: automatic.ruleVersion,
        createdAtEpochMs: automatic.createdAtEpochMs,
        updatedAtEpochMs: automatic.updatedAtEpochMs,
        minConfidenceBasisPoints: 9000,
      );
      expect(
        const MappingResolutionGate().check(
          context(mapping: MappingResolved(rule), confidenceBasisPoints: 9500),
        ),
        isA<GatePass>(),
      );
    });

    test('blocks automatic rule below confidence floor', () {
      final automatic = resolvedRule();
      final rule = MappingRule(
        id: automatic.id,
        name: automatic.name,
        enabled: automatic.enabled,
        senderMatcher: automatic.senderMatcher,
        walletAccountId: automatic.walletAccountId,
        paymentType: automatic.paymentType,
        syncMode: MappingSyncMode.automatic,
        priority: automatic.priority,
        ruleVersion: automatic.ruleVersion,
        createdAtEpochMs: automatic.createdAtEpochMs,
        updatedAtEpochMs: automatic.updatedAtEpochMs,
        minConfidenceBasisPoints: 9000,
      );
      expect(
        const MappingResolutionGate().check(
          context(mapping: MappingResolved(rule), confidenceBasisPoints: 7000),
        ),
        isA<GateBlock>(),
      );
    });

    test('blocks ambiguous and unmatched', () {
      expect(
        const MappingResolutionGate().check(
          context(
            mapping: MappingAmbiguous([resolvedRule(), resolvedRule()]),
          ),
        ),
        isA<GateBlock>(),
      );
      expect(
        const MappingResolutionGate().check(context(mapping: const MappingUnmatched())),
        isA<GateBlock>(),
      );
    });
  });

  group('CandidateValidationGate', () {
    test('passes valid same-currency candidate', () {
      expect(
        const CandidateValidationGate().check(context()),
        isA<GatePass>(),
      );
    });

    test('blocks zero amount', () {
      expect(
        const CandidateValidationGate().check(context(amountMinor: 0)),
        isA<GateBlock>(),
      );
    });

    test('blocks foreign currency', () {
      expect(
        const CandidateValidationGate().check(context(currencyCode: 'USD')),
        isA<GateBlock>(),
      );
    });

    test('blocks out-of-bounds date', () {
      expect(
        const CandidateValidationGate().check(
          context(recordDateUtc: DateTime.utc(2000)),
        ),
        isA<GateBlock>(),
      );
    });
  });

  group('DuplicateTombstoneGate', () {
    test('passes with no lineage or owned link', () {
      expect(
        const DuplicateTombstoneGate().check(context()),
        isA<GatePass>(),
      );
    });

    test('blocks on active lineage', () {
      expect(
        const DuplicateTombstoneGate().check(context(hasActiveLineage: true)),
        isA<GateBlock>(),
      );
    });

    test('blocks on owned record link', () {
      expect(
        const DuplicateTombstoneGate().check(context(hasOwnedRecordLink: true)),
        isA<GateBlock>(),
      );
    });
  });

  group('CapabilityGate', () {
    test('passes when capability enabled', () {
      expect(
        const CapabilityGate().check(context(capabilityCanCreate: true)),
        isA<GatePass>(),
      );
    });

    test('blocks when capability disabled', () {
      expect(
        const CapabilityGate().check(context(capabilityCanCreate: false)),
        isA<GateBlock>(),
      );
    });
  });

  group('WalletCreateEligibilityPolicy chain', () {
    test('runs gates in fixed order', () {
      expect(
        WalletCreateEligibilityPolicy.gates.map((g) => g.runtimeType).toList(),
        [
          PrivacyEpochGate,
          ConsentGate,
          WalletConnectionGate,
          AccountEligibilityGate,
          MappingResolutionGate,
          CandidateValidationGate,
          DuplicateTombstoneGate,
          CapabilityGate,
        ].map((t) => t).toList(),
      );
    });

    test('all-pass context is allowed with no blocked gate', () {
      final evaluation = const WalletCreateEligibilityPolicy().evaluate(
        context(mapping: MappingResolved(resolvedRule())),
      );

      expect(evaluation.allowed, isTrue);
      expect(evaluation.firstBlockedGateIndex, -1);
      expect(evaluation.outcomes, hasLength(8));
      expect(evaluation.firstBlockReason, isNull);
    });

    test('returns the FULL outcome list even when a gate blocks', () {
      final evaluation = const WalletCreateEligibilityPolicy().evaluate(
        context(
          consentCurrent: false,
          mapping: MappingResolved(resolvedRule()),
        ),
      );

      expect(evaluation.allowed, isFalse);
      expect(evaluation.firstBlockedGateIndex, 1); // ConsentGate
      expect(evaluation.outcomes, hasLength(8)); // full list, not truncated
      // Later gates still evaluated.
      expect(evaluation.outcomes[7], isA<GatePass>());
    });

    test('first block short-circuits the allowed decision at first failure', () {
      final evaluation = const WalletCreateEligibilityPolicy().evaluate(
        context(
          connectionConnected: false,
          mapping: MappingResolved(resolvedRule()),
        ),
      );
      expect(evaluation.allowed, isFalse);
      expect(evaluation.firstBlockedGateIndex, 2);
      expect(evaluation.firstBlockReason, contains('not connected'));
    });
  });
}
