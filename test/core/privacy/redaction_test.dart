import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/redaction.dart';

void main() {
  const redaction = ActivityRedaction();

  test('rejects raw text and token-like values from activity metadata', () {
    expect(
      () => redaction.rejectRawText('synthetic notice body'),
      throwsA(
        isA<RedactionViolation>()
            .having(
              (violation) => violation.kind,
              'kind',
              RedactionViolationKind.rawText,
            )
            .having(
              (violation) => violation.toString(),
              'description',
              'RedactionViolation(rawText)',
            ),
      ),
    );
    expect(
      () => redaction.rejectTokenLikeText('token=syntheticValue123'),
      throwsA(
        isA<RedactionViolation>().having(
          (violation) => violation.kind,
          'kind',
          RedactionViolationKind.tokenLikeText,
        ),
      ),
    );
  });

  test('allows metadata values that have no token-like marker', () {
    expect(
      () => redaction.rejectTokenLikeText('review queued'),
      returnsNormally,
    );
  });

  test('rejects full instrument suffixes and arbitrary metadata maps', () {
    expect(
      () => InstrumentTail('1234'),
      throwsA(
        isA<RedactionViolation>().having(
          (violation) => violation.kind,
          'kind',
          RedactionViolationKind.fullInstrumentSuffix,
        ),
      ),
    );
    expect(
      () => redaction.rejectArbitraryMetadata({'detail': 'synthetic'}),
      throwsA(
        isA<RedactionViolation>().having(
          (violation) => violation.kind,
          'kind',
          RedactionViolationKind.arbitraryMetadata,
        ),
      ),
    );
  });

  test('allows only one or two digit instrument tails with value equality', () {
    final oneDigit = InstrumentTail('7');
    final twoDigit = InstrumentTail('12');

    expect(oneDigit, InstrumentTail('7'));
    expect(oneDigit.hashCode, InstrumentTail('7').hashCode);
    expect(oneDigit, isNot(twoDigit));
    expect(twoDigit.value, '12');
    expect(() => InstrumentTail(''), throwsA(isA<RedactionViolation>()));
    expect(() => InstrumentTail('ab'), throwsA(isA<RedactionViolation>()));
  });
}
