import 'dart:convert';

import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

enum Anchor { anywhere, lineStart, lineEnd }

enum CandidateField {
  amount,
  currency,
  direction,
  instrumentSuffix,
  counterparty,
  eventInstant,
  availableBalance,
  paymentType,
  reference,
}

enum TokenShape {
  money,
  currencyCode,
  maskedSuffix,
  dateDmy,
  dateIso,
  dateDayMon,
  text,
}

final class Discriminator {
  const Discriminator({required this.token, this.anchor = Anchor.anywhere});
  final String token;
  final Anchor anchor;
}

sealed class Extractor {
  const Extractor();
}

final class AfterToken extends Extractor {
  const AfterToken(this.token, this.take);
  final String token;
  final TokenShape take;
}

final class BeforeToken extends Extractor {
  const BeforeToken(this.token, this.take);
  final String token;
  final TokenShape take;
}

final class BetweenTokens extends Extractor {
  const BetweenTokens(this.start, this.end, this.take);
  final String start;
  final String end;
  final TokenShape take;
}

final class NthOnLine extends Extractor {
  const NthOnLine({required this.line, required this.shape});
  final int line;
  final TokenShape shape;
}

final class VerbClassifier extends Extractor {
  const VerbClassifier({required this.debitVerbs, required this.creditVerbs});
  final List<String> debitVerbs;
  final List<String> creditVerbs;
}

final class FieldRule {
  const FieldRule({
    required this.field,
    required this.extractor,
    this.required = false,
  });
  final CandidateField field;
  final Extractor extractor;
  final bool required;
}

final class RulePack {
  const RulePack({
    required this.id,
    required this.version,
    required this.market,
    required this.senderPatterns,
    required this.discriminators,
    required this.fields,
    required this.defaultKind,
    required this.defaultDirection,
  });

  final String id;
  final String version;
  final String market;
  final List<String> senderPatterns;
  final List<Discriminator> discriminators;
  final List<FieldRule> fields;
  final TransactionKind defaultKind;
  final TransactionDirection defaultDirection;

  String get checksum {
    final input =
        '$id-$version-${senderPatterns.join(',')}-'
        '${fields.map((f) => '${f.field.name}:${f.required}').join(',')}';
    final bytes = utf8.encode(input);
    return bytes
        .fold<int>(0, (h, b) => ((h << 5) + h + b) & 0x7FFFFFFF)
        .toRadixString(16);
  }
}
