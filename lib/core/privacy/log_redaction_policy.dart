/// Redaction for on-disk log files (M3.4; contract inverted in M5.22 WP-F).
///
/// This guards **log files only**. The strict, throw-on-violation guard for the
/// encrypted `activity_events` table is `ActivityRedaction` in `redaction.dart`
/// and is deliberately unchanged — structured activity metadata stays on an
/// allowlist.
///
/// Contract: **deny-list + mask**. Sensitive spans are replaced in place and the
/// surrounding message survives.
///
/// It previously worked the other way round — an allowlist over the entire
/// formatted line, returning `null` (drop the record) for anything unmatched.
/// Because log files are created lazily on first write and an ordinary
/// `log.info('Loading onboarding state')` matched none of the allowed patterns,
/// every record was dropped and `logs/app/info.log` was never created at all.
final class LogRedactionPolicy {
  const LogRedactionPolicy();

  /// `bearer <value>`, `token=<value>`, `api_key: <value>`, `secret=<value>`.
  /// The value is consumed along with the marker so the secret cannot survive
  /// by sitting just past the match.
  static final RegExp _tokenPattern = RegExp(
    r'(?:bearer\s+|token\s*[:=]\s*|api[_-]?key\s*[:=]\s*|secret\s*[:=]\s*)\S+',
    caseSensitive: false,
  );

  static final RegExp _phonePattern = RegExp(
    r'(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}',
  );

  /// A 4-8 digit run is only treated as a secret when an OTP-ish keyword
  /// introduces it.
  ///
  /// Masking every 4-8 digit run unconditionally — as the old blocklist did —
  /// would, under a masking contract, destroy the year in every ISO-8601
  /// timestamp, every `amount_minor: 1500`, and every schema version. All three
  /// are explicitly loggable per the privacy plan, so an unguarded rule would
  /// trade an empty log file for an unreadable one.
  ///
  /// This is defence in depth: OTP digits only ever reach a log through an SMS
  /// body, and call sites are already forbidden from logging bodies.
  /// The keyword and the digits are allowed to be separated by short filler
  /// ("Your OTP is 123456"), not just punctuation. Requiring them to be
  /// adjacent let that exact phrasing — the single most likely way an OTP
  /// reaches a log — slip through unmasked.
  static final RegExp _otpPattern = RegExp(
    r'\b(otp|code|pin|passcode|password|cvv)\b([^0-9\n]{0,12}?)\d{4,8}\b',
    caseSensitive: false,
  );

  /// Bare runs of 9+ digits — account and card numbers. Never legitimate in a
  /// log line.
  static final RegExp _longDigitRun = RegExp(r'\b\d{9,}\b');

  /// The original allowlist, preserved for the **`activity_events` table only**.
  ///
  /// M5.22 WP-F loosened [redact] from allowlist-or-drop to deny-list+mask so
  /// that log *files* stop coming out empty. The activity table is a different
  /// sink with a different rule — plan/07 requires it to carry an allowlist of
  /// sanitized metadata — and `ActivityEventWriter` previously depended on
  /// `redact()` returning null to enforce exactly that. Without this predicate,
  /// relaxing the file policy would have silently relaxed the database policy
  /// with it.
  ///
  /// Returns true only when [message] matches a known-safe structured pattern.
  bool isAllowedForActivityLog(String message) {
    if (_tokenPattern.hasMatch(message)) return false;
    if (_phonePattern.hasMatch(message)) return false;
    if (_allowedActivityPatterns.any((p) => p.hasMatch(message))) return true;
    return false;
  }

  static final _allowedActivityPatterns = <RegExp>[
    RegExp(r'SafeErrorCode:\s*\w+'),
    RegExp(r'CorrelationId:\s*[\w-]+'),
    RegExp(r'entity_type:?\s*\w+'),
    RegExp(r'bank_label:?\s*\w+'),
    RegExp(r'Instrument:\s*\*{1,2}\d{1,2}'),
    RegExp(r'amount_minor:\s*\d+'),
    RegExp(r'currency:\s*[A-Z]{3}'),
    RegExp(r'state_transition:\s*\w+'),
    RegExp(r'event_code:\s*[\w.]+'),
    RegExp(r'app\.(info|error)\b'),
    RegExp(r'code=\w+'),
    RegExp(r'PRAGMA|retry|delete|epoch|migration|schema'),
    RegExp(r'DB_KEY_INVALID|CIPHER_UNSUPPORTED|EMPTY_SCHEMA|DB_ERROR'),
    RegExp(r'^\*{1,2}\d{1,2}'),
  ];

  /// Returns [message] with every sensitive span masked.
  ///
  /// Never returns null: dropping whole records is what left the log files
  /// empty. A record that cannot be made safe is masked, not discarded.
  String redact(String message) {
    if (message.isEmpty) return message;
    var out = message;
    out = out.replaceAll(_tokenPattern, '<redacted:token>');
    // Order matters: a bare 12-digit account number also satisfies the phone
    // shape, so the long-run rule claims it first and labels it correctly.
    // Either way it is masked — this only keeps the label honest.
    out = out.replaceAll(_longDigitRun, '<redacted:digits>');
    out = out.replaceAll(_phonePattern, '<redacted:phone>');
    out = out.replaceAllMapped(
      _otpPattern,
      (m) => '${m[1]}${m[2]}<redacted:digits>',
    );
    return out;
  }
}
