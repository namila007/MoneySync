import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/transaction_parser/data/rule_packs/lk/lk_sampath_account_v1.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

void main() {
  final interpret = InterpretMessage(
    registry: RulePackRegistry(packs: [lkSampathAccountV1]),
  );
  final receivedAt = DateTime.utc(2026, 8, 12, 10, 0);

  group('lk.sampath.account golden', () {
    test('parses a debit into a candidate', () {
      final result = interpret(
        rawBody:
            'LKR 1,500.00 debited from AC **6126 for SYNTHETIC CAFE '
            'Avl Bal: LKR 48,500.00',
        sender: 'SAMPATHTX',
        receivedAtUtc: receivedAt,
      );

      expect(result, isA<InterpretedCandidate>());
      final candidate = (result as InterpretedCandidate).candidate;
      expect(candidate.kind, TransactionKind.expense);
      expect(candidate.direction, TransactionDirection.debit);
      expect(candidate.lifecycle, FinancialLifecycle.posted);
      expect(candidate.originalAmount.minorUnits, -150000);
      expect(candidate.requiresReview, isFalse);
    });

    test('classifies TFR as a mandatory-review transfer', () {
      final result = interpret(
        rawBody:
            'LKR 2,000.00 debited from AC **6126 TFR to 0777000000 '
            'Avl Bal: LKR 46,500.00',
        sender: 'SAMPATHTX',
        receivedAtUtc: receivedAt,
      );

      expect(result, isA<InterpretedCandidate>());
      final candidate = (result as InterpretedCandidate).candidate;
      expect(candidate.kind, TransactionKind.transfer);
      expect(candidate.requiresReview, isTrue);
    });

    test('OTP messages produce no candidate', () {
      final result = interpret(
        rawBody: 'Your Sampath OTP is 482913. Do not share.',
        sender: 'SAMPATHTX',
        receivedAtUtc: receivedAt,
      );

      expect(result, isA<InterpretedNonTransaction>());
    });

    test('unmatched sender and discriminators are unrecognised', () {
      final result = interpret(
        rawBody:
            'LKR 500.00 debited at SYNTHETIC MALL checkout. '
            'Avl Bal: LKR 48,000.00',
        sender: 'UNKNOWN',
        receivedAtUtc: receivedAt,
      );

      expect(result, isA<InterpretedUnrecognised>());
    });

    test('missing amount yields no candidate', () {
      final result = interpret(
        rawBody: 'Your account activity is available. Avl Bal: LKR 48,500.00',
        sender: 'SAMPATHTX',
        receivedAtUtc: receivedAt,
      );

      expect(result, isNot(isA<InterpretedCandidate>()));
    });
  });
}
