import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/money/money.dart';
import 'package:money_sync/core/time/source_date_evidence.dart';
import 'package:money_sync/features/transaction_parser/domain/money_parser.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

sealed class InterpretationResult {
  const InterpretationResult();
}

final class InterpretedCandidate extends InterpretationResult {
  const InterpretedCandidate(this.candidate);
  final TransactionCandidate candidate;
}

final class InterpretedNonTransaction extends InterpretationResult {
  const InterpretedNonTransaction();
}

final class InterpretedUnrecognised extends InterpretationResult {
  const InterpretedUnrecognised();
}

/// Deterministic offline interpretation of one message.
///
/// Bank/product families are **data**: packs live in the registry and are
/// selected by sender + discriminators. Adding a bank requires only a new
/// pack entry — no pipeline change.
final class InterpretMessage {
  const InterpretMessage({required this.registry});

  final RulePackRegistry registry;

  InterpretationResult call({
    required String rawBody,
    required String sender,
    required DateTime receivedAtUtc,
  }) {
    // 1 normalize
    final body = _normalize(rawBody);
    if (body.length < 12) return const InterpretedUnrecognised();

    // 2 filter — OTP/non-transaction heuristics
    if (_isOtp(body)) return const InterpretedNonTransaction();
    if (!_looksFinancial(body)) return const InterpretedNonTransaction();

    // 3 ruleFamilySelect — abstract registry selection, deterministic
    final selection = registry.select(body: body, sender: sender);
    if (selection is! RulePackSelectionMatch) {
      return const InterpretedUnrecognised();
    }
    final pack = selection.pack;

    // 4 parse — extract fields via the pack's extractors
    final extracted = _extractFields(body, pack);

    // 5 validate — amount + direction must be present and coherent
    final amount = extracted['amount'] as Money?;
    final direction = extracted['direction'] as TransactionDirection?;
    // ignore: avoid_print
    if (amount == null || direction == null) {
      return const InterpretedUnrecognised();
    }

    // 6 classify — kind/lifecycle from defaults and verbs
    final lifecycle = _classifyLifecycle(body, pack.defaultKind);
    final kind = _classifyKind(body, pack.defaultKind, lifecycle);
    final reviewReasons = _reviewReasonsFor(kind);

    // 7 finalize — sign from direction, never from text.
    final signedAmount = direction == TransactionDirection.debit
        ? Money(minorUnits: -amount.minorUnits, currency: amount.currency)
        : amount;
    final confidence = CandidateConfidence(
      basisPoints: reviewReasons.isEmpty ? 9000 : 7500,
    );
    final provenance = CandidateProvenance(
      parserRuleId: pack.id,
      parserRuleVersion: pack.version,
      // Identity function version at capture time. Bumped 1 → 2 by M4.14 WP4;
      // keep in sync with SourceMessageCanonicalizer.canonicalizationVersion.
      captureCanonicalizationVersion: 2,
      sourceDateEvidence: SourceDateEvidence(
        instantUtc: receivedAtUtc.toUtc(),
        source: DateEvidenceSource.receivedAtUtc,
        originalValue: 'received_at_fallback',
        parsingContext: SourceTimeZoneContext.utc,
      ),
    );

    try {
      final candidate = TransactionCandidate(
        id: '${pack.id}-${body.hashCode}',
        sourceMessageKey: body,
        kind: kind,
        direction: direction,
        lifecycle: lifecycle,
        originalAmount: signedAmount,
        transactionAtUtc: receivedAtUtc.toUtc(),
        confidence: confidence,
        reviewReasons: reviewReasons,
        provenance: provenance,
        counterParty: extracted['counterparty'] as String?,
      );
      return InterpretedCandidate(candidate);
    } on InvalidCandidateFailure {
      return const InterpretedUnrecognised();
    }
  }

  String _normalize(String raw) =>
      raw.replaceAll(RegExp(r'\r\n?'), '\n').trim();

  bool _isOtp(String body) => RegExp(
    r'\bOTP\b|\bone[\s-]?time\s?pass(word)?\b|verification code',
    caseSensitive: false,
  ).hasMatch(body);

  // Permissive by design: any currency-coded amount, a payment verb, or a
  // balance marker counts as financial. Bank-specific wording is the pack's
  // discriminators' job, not the filter's.
  bool _looksFinancial(String body) => RegExp(
    r'\b[A-Z]{3}\s?\d|Rs\.?\s?\d|\b(debited|credited|charged|payment|paid|purchase|deposit|withdraw|transfer|received|avl|balance)\b',
    caseSensitive: false,
  ).hasMatch(body);

  Map<String, Object?> _extractFields(String body, RulePack pack) {
    final result = <String, Object?>{};
    for (final rule in pack.fields) {
      result[rule.field.name] = _applyExtractor(rule.extractor, body);
    }
    // VerbClassifier drives direction when present.
    for (final rule in pack.fields) {
      if (rule.extractor is VerbClassifier) {
        final classifier = rule.extractor as VerbClassifier;
        final lowered = body.toLowerCase();
        final isDebit = classifier.debitVerbs
            .map((v) => v.toLowerCase())
            .any(lowered.contains);
        final isCredit = classifier.creditVerbs
            .map((v) => v.toLowerCase())
            .any(lowered.contains);
        // ignore: avoid_print
        if (isDebit != isCredit) {
          result['direction'] = isDebit
              ? TransactionDirection.debit
              : TransactionDirection.credit;
        }
      }
    }
    return result;
  }

  Object? _applyExtractor(Extractor extractor, String body) {
    return switch (extractor) {
      AfterToken(:final token, :final take) => _afterToken(body, token, take),
      BeforeToken(:final token, :final take) => _beforeToken(body, token, take),
      BetweenTokens(:final start, :final end, :final take) => _betweenTokens(
        body,
        start,
        end,
        take,
      ),
      NthOnLine(:final line, :final shape) => _nthOnLine(body, line, shape),
      VerbClassifier() => null,
    };
  }

  Object? _afterToken(String body, String token, TokenShape take) {
    final index = body.indexOf(token);
    if (index < 0) return null;
    return _shapeValue(body.substring(index + token.length), take);
  }

  Object? _beforeToken(String body, String token, TokenShape take) {
    final index = body.indexOf(token);
    if (index < 0) return null;
    return _shapeValue(body.substring(0, index), take);
  }

  Object? _betweenTokens(
    String body,
    String start,
    String end,
    TokenShape take,
  ) {
    final startIndex = body.indexOf(start);
    if (startIndex < 0) return null;
    final from = startIndex + start.length;
    final endIndex = body.indexOf(end, from);
    if (endIndex < 0) return null;
    return _shapeValue(body.substring(from, endIndex), take);
  }

  Object? _nthOnLine(String body, int line, TokenShape shape) {
    final lines = body.split('\n');
    if (line < 0 || line >= lines.length) return null;
    return _shapeValue(lines[line], shape);
  }

  Object? _shapeValue(String raw, TokenShape shape) {
    final trimmed = raw.trim();
    return switch (shape) {
      TokenShape.money => switch (parseMoney(trimmed)) {
        MoneyParsed(:final value) => value,
        MoneyParseFailed() => null,
      },
      TokenShape.currencyCode => RegExp(
        r'\b[A-Z]{3}\b',
      ).firstMatch(trimmed)?.group(0),
      TokenShape.maskedSuffix => RegExp(
        r'\*{2,}\d{2,4}|\d{4}$',
      ).firstMatch(trimmed)?.group(0),
      TokenShape.text => trimmed.isEmpty ? null : trimmed,
      _ => null,
    };
  }

  FinancialLifecycle _classifyLifecycle(
    String body,
    TransactionKind defaultKind,
  ) {
    final lowered = body.toLowerCase();
    return switch (defaultKind) {
      TransactionKind.authorization =>
        lowered.contains('settled')
            ? FinancialLifecycle.settled
            : FinancialLifecycle.authorized,
      TransactionKind.reversal => FinancialLifecycle.reversed,
      _ => FinancialLifecycle.posted,
    };
  }

  TransactionKind _classifyKind(
    String body,
    TransactionKind defaultKind,
    FinancialLifecycle lifecycle,
  ) {
    final lowered = body.toLowerCase();
    if (lowered.contains('tfr') || lowered.contains('transfer')) {
      return TransactionKind.transfer;
    }
    if (defaultKind == TransactionKind.authorization) {
      return lifecycle == FinancialLifecycle.settled
          ? TransactionKind.settlement
          : TransactionKind.authorization;
    }
    return defaultKind;
  }

  Set<ReviewReason> _reviewReasonsFor(TransactionKind kind) => switch (kind) {
    TransactionKind.authorization ||
    TransactionKind.settlement ||
    TransactionKind.reversal ||
    TransactionKind.transfer => {ReviewReason.authorization},
    _ => const {},
  };
}
