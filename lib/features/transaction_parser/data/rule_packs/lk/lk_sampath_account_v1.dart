import 'package:money_sync/features/transaction_parser/domain/rule_pack.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

/// Sampath account debit/transfer family.
///
/// Matches messages like:
/// "LKR 1,500.00 debited from AC **6126 for namila …"
const RulePack lkSampathAccountV1 = RulePack(
  id: 'lk.sampath.account',
  version: '1.0.0',
  market: 'LK',
  senderPatterns: ['SAMPATH'],
  discriminators: [
    Discriminator(token: 'debited'),
    Discriminator(token: 'AC **'),
  ],
  fields: [
    FieldRule(
      field: CandidateField.amount,
      extractor: BeforeToken('debited', TokenShape.money),
      required: true,
    ),
    FieldRule(
      field: CandidateField.counterparty,
      extractor: BetweenTokens('for ', '\n', TokenShape.text),
    ),
    FieldRule(
      field: CandidateField.direction,
      extractor: VerbClassifier(
        debitVerbs: ['debited', 'withdrawn'],
        creditVerbs: ['credited', 'deposited'],
      ),
    ),
  ],
  defaultKind: TransactionKind.expense,
  defaultDirection: TransactionDirection.debit,
);
