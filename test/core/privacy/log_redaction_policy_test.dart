import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

void main() {
  final policy = const LogRedactionPolicy();

  group('LogRedactionPolicy', () {
    test('blocks raw SMS text', () {
      expect(policy.redact('Your OTP is 123456'), isNull);
    });

    test('blocks bearer token pattern', () {
      expect(
        policy.redact(
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0',
        ),
        isNull,
      );
    });

    test('blocks token-like values', () {
      expect(policy.redact('Token: abc123def456'), isNull);
      expect(policy.redact('API_KEY=sk-abcdef123456'), isNull);
    });

    test('blocks phone numbers', () {
      expect(policy.redact('Call 077-123-4567 for help'), isNull);
      expect(policy.redact('+94 77 123 4567'), isNull);
    });

    test('allows SafeErrorCode', () {
      expect(policy.redact('SafeErrorCode: DB_KEY_INVALID'), isNotNull);
    });

    test('allows CorrelationId', () {
      expect(policy.redact('CorrelationId: abc-123-def'), isNotNull);
    });

    test('allows bank labels', () {
      expect(policy.redact('bank_label: institutionA'), isNotNull);
    });

    test('allows instrument tail', () {
      expect(policy.redact('Instrument: **34'), isNotNull);
    });

    test('allows amount and currency', () {
      expect(policy.redact('amount_minor: 1500'), isNotNull);
      expect(policy.redact('currency: LKR'), isNotNull);
    });

    test('allows state transitions', () {
      expect(policy.redact('state_transition: needsReview'), isNotNull);
    });

    test('allows event codes', () {
      expect(policy.redact('event_code: app.log.info'), isNotNull);
    });

    test('blocks anything not on the allowlist', () {
      expect(policy.redact('some random free text'), isNull);
    });

    test('allows schema-related terms', () {
      expect(policy.redact('migration v1->v2 applied'), isNotNull);
      expect(policy.redact('PRAGMA cipher_version'), isNotNull);
      expect(policy.redact('epoch advanced to 3'), isNotNull);
    });
  });
}
