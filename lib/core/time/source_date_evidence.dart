import 'package:money_sync/core/errors/domain_failure.dart';

enum DateEvidenceSource { messageTimestamp, receivedAtUtc, inferredDate }

enum SourceTimeZoneContext { utc, asiaColombo, explicitOffset }

/// An immutable parsed instant plus the evidence used to interpret it.
final class SourceDateEvidence {
  SourceDateEvidence({
    required DateTime instantUtc,
    required this.source,
    required this.originalValue,
    required this.parsingContext,
  }) : instantUtc = instantUtc {
    if (!instantUtc.isUtc || originalValue.isEmpty) {
      throw const InvalidDateEvidenceFailure();
    }
  }

  final DateTime instantUtc;
  final DateEvidenceSource source;
  final String originalValue;
  final SourceTimeZoneContext parsingContext;

  factory SourceDateEvidence.fromIso8601({
    required String value,
    required DateEvidenceSource source,
  }) {
    if (!RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$').hasMatch(value)) {
      throw const InvalidDateEvidenceFailure();
    }
    if (!_hasValidIsoDateTimeComponents(value)) {
      throw const InvalidDateEvidenceFailure();
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw const InvalidDateEvidenceFailure();
    return SourceDateEvidence(
      instantUtc: parsed.toUtc(),
      source: source,
      originalValue: value,
      parsingContext: value.endsWith('Z')
          ? SourceTimeZoneContext.utc
          : SourceTimeZoneContext.explicitOffset,
    );
  }

  factory SourceDateEvidence.fromColomboLocal({
    required String value,
    required DateEvidenceSource source,
  }) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$',
    ).firstMatch(value);
    if (match == null) throw const InvalidDateEvidenceFailure();
    final values = List<int>.generate(
      6,
      (index) => int.parse(match.group(index + 1)!),
    );
    try {
      final localAsUtc = DateTime.utc(
        values[0],
        values[1],
        values[2],
        values[3],
        values[4],
        values[5],
      );
      if (localAsUtc.year != values[0] ||
          localAsUtc.month != values[1] ||
          localAsUtc.day != values[2] ||
          localAsUtc.hour != values[3] ||
          localAsUtc.minute != values[4] ||
          localAsUtc.second != values[5]) {
        throw const InvalidDateEvidenceFailure();
      }
      return SourceDateEvidence(
        instantUtc: localAsUtc.subtract(const Duration(hours: 5, minutes: 30)),
        source: source,
        originalValue: value,
        parsingContext: SourceTimeZoneContext.asiaColombo,
      );
    } on ArgumentError {
      throw const InvalidDateEvidenceFailure();
    }
  }

  Map<String, Object> toJson() => <String, Object>{
    'instantUtc': instantUtc.toIso8601String(),
    'source': source.name,
    'originalValue': originalValue,
    'parsingContext': parsingContext.name,
  };

  factory SourceDateEvidence.fromJson(Map<String, Object?> value) {
    final instant = value['instantUtc'];
    final source = value['source'];
    final originalValue = value['originalValue'];
    final context = value['parsingContext'];
    if (instant is! String ||
        source is! String ||
        originalValue is! String ||
        context is! String) {
      throw const InvalidDateEvidenceFailure();
    }
    if (!RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$').hasMatch(instant)) {
      throw const InvalidDateEvidenceFailure();
    }
    if (!_hasValidIsoDateTimeComponents(instant)) {
      throw const InvalidDateEvidenceFailure();
    }
    final parsedInstant = DateTime.tryParse(instant);
    if (parsedInstant == null) throw const InvalidDateEvidenceFailure();
    try {
      return SourceDateEvidence(
        instantUtc: parsedInstant.toUtc(),
        source: DateEvidenceSource.values.byName(source),
        originalValue: originalValue,
        parsingContext: SourceTimeZoneContext.values.byName(context),
      );
    } on ArgumentError {
      throw const InvalidDateEvidenceFailure();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is SourceDateEvidence &&
      other.instantUtc == instantUtc &&
      other.source == source &&
      other.originalValue == originalValue &&
      other.parsingContext == parsingContext;

  @override
  int get hashCode =>
      Object.hash(instantUtc, source, originalValue, parsingContext);

  static bool _hasValidIsoDateTimeComponents(String value) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[Tt ](\d{2}):(\d{2})(?::(\d{2})(?:[.,]\d+)?)?',
    ).firstMatch(value);
    if (match == null) return false;
    final values = List<int>.generate(
      6,
      (index) => int.parse(match.group(index + 1) ?? '0'),
    );
    final normalized = DateTime.utc(
      values[0],
      values[1],
      values[2],
      values[3],
      values[4],
      values[5],
    );
    return normalized.year == values[0] &&
        normalized.month == values[1] &&
        normalized.day == values[2] &&
        normalized.hour == values[3] &&
        normalized.minute == values[4] &&
        normalized.second == values[5];
  }
}
