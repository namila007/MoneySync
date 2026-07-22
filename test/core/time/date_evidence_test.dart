import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/time/source_date_evidence.dart';

void main() {
  group('SourceDateEvidence', () {
    test('normalizes an explicit offset to UTC while retaining its source', () {
      final evidence = SourceDateEvidence.fromIso8601(
        value: '2026-07-22T12:00:00+05:30',
        source: DateEvidenceSource.messageTimestamp,
      );

      expect(evidence.instantUtc, DateTime.utc(2026, 7, 22, 6, 30));
      expect(evidence.source, DateEvidenceSource.messageTimestamp);
      expect(evidence.originalValue, '2026-07-22T12:00:00+05:30');
      expect(evidence.parsingContext, SourceTimeZoneContext.explicitOffset);
    });

    test('records a Z-suffixed ISO timestamp as UTC evidence', () {
      final evidence = SourceDateEvidence.fromIso8601(
        value: '2026-07-22T06:30:00Z',
        source: DateEvidenceSource.receivedAtUtc,
      );

      expect(evidence.instantUtc, DateTime.utc(2026, 7, 22, 6, 30));
      expect(evidence.parsingContext, SourceTimeZoneContext.utc);
    });

    test('interprets an offset-free SMS time in Asia/Colombo', () {
      final evidence = SourceDateEvidence.fromColomboLocal(
        value: '2026-07-22 12:00:00',
        source: DateEvidenceSource.messageTimestamp,
      );

      expect(evidence.instantUtc, DateTime.utc(2026, 7, 22, 6, 30));
      expect(evidence.parsingContext, SourceTimeZoneContext.asiaColombo);
    });

    test('rejects invalid timestamp text and non-UTC stored instants', () {
      expect(
        () => SourceDateEvidence.fromColomboLocal(
          value: '2026/07/22 12:00',
          source: DateEvidenceSource.messageTimestamp,
        ),
        throwsA(isA<InvalidDateEvidenceFailure>()),
      );
      expect(
        () => SourceDateEvidence(
          instantUtc: DateTime(2026, 7, 22, 6, 30),
          source: DateEvidenceSource.receivedAtUtc,
          originalValue: 'synthetic',
          parsingContext: SourceTimeZoneContext.utc,
        ),
        throwsA(isA<InvalidDateEvidenceFailure>()),
      );
    });

    test('serializes immutable UTC instant and source metadata', () {
      final original = SourceDateEvidence.fromColomboLocal(
        value: '2026-07-22 12:00:00',
        source: DateEvidenceSource.messageTimestamp,
      );

      expect(SourceDateEvidence.fromJson(original.toJson()), original);
    });

    test(
      'rejects an unqualified JSON instant because its timezone is unknown',
      () {
        expect(
          () => SourceDateEvidence.fromJson(<String, Object?>{
            'instantUtc': '2026-07-22T06:30:00',
            'source': 'receivedAtUtc',
            'originalValue': 'synthetic',
            'parsingContext': 'utc',
          }),
          throwsA(isA<InvalidDateEvidenceFailure>()),
        );
      },
    );

    test(
      'rejects ISO values with calendar components that Dart would normalize',
      () {
        expect(
          () => SourceDateEvidence.fromIso8601(
            value: '2026-02-30T06:30:00Z',
            source: DateEvidenceSource.inferredDate,
          ),
          throwsA(isA<InvalidDateEvidenceFailure>()),
        );
      },
    );

    test(
      'rejects invalid local calendar values and malformed JSON metadata',
      () {
        expect(
          () => SourceDateEvidence.fromColomboLocal(
            value: '2026-02-30 12:00:00',
            source: DateEvidenceSource.messageTimestamp,
          ),
          throwsA(isA<InvalidDateEvidenceFailure>()),
        );
        expect(
          () => SourceDateEvidence.fromJson(<String, Object?>{
            'instantUtc': '2026-07-22T06:30:00Z',
            'source': 'unknownSource',
            'originalValue': 'synthetic',
            'parsingContext': 'utc',
          }),
          throwsA(isA<InvalidDateEvidenceFailure>()),
        );
        expect(
          () => SourceDateEvidence.fromJson(<String, Object?>{
            'instantUtc': 42,
            'source': 'receivedAtUtc',
            'originalValue': 'synthetic',
            'parsingContext': 'utc',
          }),
          throwsA(isA<InvalidDateEvidenceFailure>()),
        );
      },
    );
  });
}
