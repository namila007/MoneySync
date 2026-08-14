import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

// A hypothetical non-Sri-Lankan bank — proves the pipeline is bank-agnostic:
// the pack is data, the interpreter never mentions a bank name.
final _genericPack = RulePack(
  id: 'xx.generic.bank',
  version: '1.0.0',
  market: 'XX',
  senderPatterns: ['GENBANK'],
  discriminators: [
    Discriminator(token: 'PAYMENT'),
    Discriminator(token: 'CARD **'),
  ],
  fields: [
    FieldRule(
      field: CandidateField.amount,
      extractor: BeforeToken('PAYMENT', TokenShape.money),
      required: true,
    ),
    FieldRule(
      field: CandidateField.direction,
      extractor: VerbClassifier(
        debitVerbs: ['PAYMENT', 'CHARGED'],
        creditVerbs: ['CREDIT'],
      ),
    ),
  ],
  defaultKind: TransactionKind.expense,
  defaultDirection: TransactionDirection.debit,
);

void main() {
  group('RulePackRegistry (bank-agnostic)', () {
    test('interpreter parses a generic bank with the same pipeline', () {
      final interpret = InterpretMessage(
        registry: RulePackRegistry(packs: [_genericPack]),
      );

      final result = interpret(
        rawBody:
            'GENBANK 750.00 PAYMENT at SYNTHETIC MALL '
            'CARD **8888 Avl: 9999.00',
        sender: 'GENBANK',
        receivedAtUtc: DateTime.utc(2026, 8, 13),
      );

      expect(result, isA<InterpretedCandidate>());
      final candidate = (result as InterpretedCandidate).candidate;
      expect(candidate.kind, TransactionKind.expense);
      expect(candidate.direction, TransactionDirection.debit);
      expect(candidate.originalAmount.minorUnits, -75000);
      expect(candidate.provenance.parserRuleId, 'xx.generic.bank');
    });

    test('selects the pack with more discriminators on overlap', () {
      final overlapPack = RulePack(
        id: 'zz.overlap',
        version: '1.0.0',
        market: 'ZZ',
        senderPatterns: ['GENBANK'],
        discriminators: [Discriminator(token: 'PAYMENT')],
        fields: const [],
        defaultKind: TransactionKind.expense,
        defaultDirection: TransactionDirection.debit,
      );
      final registry = RulePackRegistry(packs: [_genericPack, overlapPack]);

      final selection = registry.select(
        body: 'GENBANK PAYMENT 100.00',
        sender: 'GENBANK',
      );

      expect(selection, isA<RulePackSelectionMatch>());
      expect((selection as RulePackSelectionMatch).pack.id, 'xx.generic.bank');
    });

    test('identical packs produce a tie, never an arbitrary pick', () {
      final twin = RulePack(
        id: 'xx.generic.bank',
        version: '2.0.0',
        market: 'XX',
        senderPatterns: ['GENBANK'],
        discriminators: [
          Discriminator(token: 'PAYMENT'),
          Discriminator(token: 'CARD **'),
        ],
        fields: const [],
        defaultKind: TransactionKind.expense,
        defaultDirection: TransactionDirection.debit,
      );
      final registry = RulePackRegistry(packs: [_genericPack, twin]);

      final selection = registry.select(
        body: 'GENBANK PAYMENT 100.00 CARD **8888',
        sender: 'GENBANK',
      );

      expect(selection, isA<RulePackSelectionTie>());
    });

    test('no match returns none', () {
      final registry = RulePackRegistry(packs: [_genericPack]);

      final selection = registry.select(body: 'hello world', sender: 'UNKNOWN');

      expect(selection, isA<RulePackSelectionNone>());
    });

    test('interpreter rejects a tie as unrecognised (never guesses)', () {
      final twin = RulePack(
        id: 'xx.generic.bank',
        version: '2.0.0',
        market: 'XX',
        senderPatterns: ['GENBANK'],
        discriminators: [
          Discriminator(token: 'PAYMENT'),
          Discriminator(token: 'CARD **'),
        ],
        fields: const [],
        defaultKind: TransactionKind.expense,
        defaultDirection: TransactionDirection.debit,
      );
      final interpret = InterpretMessage(
        registry: RulePackRegistry(packs: [_genericPack, twin]),
      );

      final result = interpret(
        rawBody: 'GENBANK PAYMENT 100.00 CARD **8888',
        sender: 'GENBANK',
        receivedAtUtc: DateTime.utc(2026, 8, 13),
      );

      expect(result, isA<InterpretedUnrecognised>());
    });
  });
}
