import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/log_redaction_policy.dart';

/// M5.22 WP-F. The contract inverted from allowlist-or-drop to deny-list+mask.
///
/// The previous version of this file asserted `redact('some random free text')`
/// was `null` — faithfully encoding a policy that dropped every non-allowlisted
/// record and therefore guaranteed an empty log file. Plan and tests were
/// updated together per AGENTS.md.
///
/// `LogRedactionPolicy` guards on-disk log files only. The strict
/// throw-on-violation guard for the `activity_events` table is
/// `ActivityRedaction`, covered by `redaction_test.dart` and unchanged.
void main() {
  const policy = LogRedactionPolicy();

  group('masks secrets', () {
    test('bearer tokens, consuming the value', () {
      final out = policy.redact(
        'auth: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0',
      );
      expect(out, isNot(contains('eyJhbGciOiJIUzI1NiJ9')));
      expect(out, contains('<redacted:token>'));
    });

    test('token / api key / secret assignments', () {
      for (final marker in ['Token: abc123def456', 'API_KEY=sk-abcdef123456']) {
        final out = policy.redact('config $marker');
        expect(out, contains('<redacted:token>'), reason: marker);
        expect(out, isNot(contains('abc')), reason: marker);
      }
    });

    test('phone numbers', () {
      final out = policy.redact('Call 077-123-4567 for help');
      expect(out, isNot(contains('077-123-4567')));
      expect(out, contains('<redacted:phone>'));
      expect(out, contains('for help'));
    });

    test('OTP digits when introduced by a keyword', () {
      final out = policy.redact('Your OTP is 123456');
      expect(out, isNot(contains('123456')));
      expect(out, contains('<redacted:digits>'));
    });

    test('bare long digit runs (account and card numbers)', () {
      final out = policy.redact('account 123456789012 credited');
      expect(out, isNot(contains('123456789012')));
      expect(out, contains('<redacted:digits>'));
      expect(out, contains('credited'));
    });

    test('every sensitive span in one message, keeping the rest', () {
      final out = policy.redact('user 077-123-4567 sent code 483920 to sync');
      expect(out, contains('<redacted:phone>'));
      expect(out, contains('<redacted:digits>'));
      expect(out, contains('to sync'));
    });
  });

  group('preserves loggable content', () {
    test('ordinary developer prose survives', () {
      const message = 'Loading onboarding state from Drift';
      expect(policy.redact(message), message);
    });

    test('a full formatted log line survives', () {
      const line =
          '2026-08-25T00:00:00.000Z [ INFO] bootstrap: Startup init done';
      expect(policy.redact(line), line);
    });

    test('structured metadata still survives', () {
      for (final message in [
        'SafeErrorCode: DB_KEY_INVALID',
        'CorrelationId: abc-123-def',
        'bank_label: institutionA',
        'Instrument: **34',
        'currency: LKR',
        'state_transition: needsReview',
        'event_code: app.log.info',
        'PRAGMA cipher_version',
      ]) {
        expect(policy.redact(message), message, reason: message);
      }
    });

    test('amount_minor is not eaten by the digit rule', () {
      // Regression guard: an unguarded \d{4,8} mask would destroy this, and
      // the privacy plan explicitly allows amounts.
      const message = 'amount_minor: 1500';
      expect(policy.redact(message), message);
    });

    test('an ISO-8601 year is not mistaken for an OTP', () {
      // Regression guard: an unguarded digit rule would mangle the timestamp
      // on every single line, trading an empty log for an unreadable one.
      final out = policy.redact('2026-08-25 migration v1->v2 applied');
      expect(out, contains('2026'));
      expect(out, contains('migration v1->v2 applied'));
    });

    test('empty message is returned unchanged', () {
      expect(policy.redact(''), '');
    });
  });
}
