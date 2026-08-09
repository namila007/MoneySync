enum MessageTriage { likelyFinancial, otpOnly, promotional, unrelated }

final class FinancialMessageFilter {
  static final _otpPatterns = [
    RegExp(r'\bOTP\b', caseSensitive: false),
    RegExp(r'\bone\s?time\s?(pass|passw)', caseSensitive: false),
    RegExp(r'verification\s?code', caseSensitive: false),
    RegExp(r'\bdo\snot\sshare\b', caseSensitive: false),
  ];

  static final _currencyPattern = RegExp(
    r'(\b(?:LKR|USD|EUR|GBP|Rs\.?)\s+\d[\d,]*\.?\d{2}\b|\b\d[\d,]*\.?\d{2}\s+(?:LKR|USD|EUR|GBP)\b)',
    caseSensitive: false,
  );

  static final _verbPattern = RegExp(
    r'\b(?:debited?|credited?|purchased?|paid|payment|withdr[ae]w|deposit|transfer|received?)',
    caseSensitive: false,
  );

  static final _maskedInstrumentPattern = RegExp(r'\b(?:\*{2}|\*\*)\d{2,4}\b');

  MessageTriage call(String normalizedBody) {
    final hasAmount = _currencyPattern.hasMatch(normalizedBody);
    final hasOtp = _otpPatterns.any((p) => p.hasMatch(normalizedBody));
    final hasVerb = _verbPattern.hasMatch(normalizedBody);
    final hasInstrument = _maskedInstrumentPattern.hasMatch(normalizedBody);

    if (hasOtp) {
      if (hasAmount && hasVerb) return MessageTriage.likelyFinancial;
      return MessageTriage.otpOnly;
    }

    if (hasAmount && (hasVerb || hasInstrument)) {
      return MessageTriage.likelyFinancial;
    }

    if (hasAmount) {
      return MessageTriage.promotional;
    }

    return MessageTriage.unrelated;
  }
}
