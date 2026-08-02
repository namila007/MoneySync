final class LogRedactionPolicy {
  const LogRedactionPolicy();

  static final RegExp _tokenPattern = RegExp(
    r'(?:bearer\s+|token\s*[:=]|api[_-]?key\s*[:=]|secret\s*[:=])',
    caseSensitive: false,
  );

  static final RegExp _otpPattern = RegExp(r'\b\d{4,8}\b');

  static final RegExp _phonePattern = RegExp(
    r'\b(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b',
  );

  static final _allowedPatterns = <RegExp>[
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
    RegExp(r'^\*{1,2}\d{1,2}'), // instrument tail like **34
  ];

  String? redact(String message) {
    if (_tokenPattern.hasMatch(message)) return null;
    if (_phonePattern.hasMatch(message)) return null;
    if (_allowedPatterns.any((p) => p.hasMatch(message))) return message;
    // Final OTP check: only block bare numeric sequences that aren't part of
    // an otherwise allowlisted message
    if (_otpPattern.hasMatch(message)) return null;
    return null;
  }
}
