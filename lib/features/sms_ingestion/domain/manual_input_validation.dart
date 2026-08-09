const int kMinBodyLength = 12;
const int kMaxBodyLength = 2000;
const int kMaxSenderLength = 32;

enum ManualInputRejection {
  empty,
  tooShort,
  tooLong,
  unsupportedMimeType,
  controlCharacters,
  senderTooLong,
  rateLimited,
  notPlausiblyFinancial,
}

sealed class ManualInputResult {
  const ManualInputResult();
}

final class ManualInputAccepted extends ManualInputResult {
  const ManualInputAccepted({
    required this.normalizedBody,
    required this.normalizedSender,
    required this.redactedPreview,
  });

  final String normalizedBody;
  final String normalizedSender;
  final String redactedPreview;
}

final class ManualInputRejected extends ManualInputResult {
  const ManualInputRejected(this.reason);
  final ManualInputRejection reason;
}

String normalizeManualBody(String raw, {String? mimeType}) {
  if (mimeType != null && mimeType != 'text/plain') {
    return 'rejected:unsupportedMimeType';
  }
  var text = raw;
  text = _nfcNormalize(text);
  text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  text = _stripControlChars(text);
  text = _collapseSpacesAndTabs(text);
  final lines = text.split('\n').map((line) => line.trim()).toList();
  text = lines.join('\n').trim();
  return text;
}

ManualInputResult validateManualInput(
  String raw, {
  String? rawSender,
  String? mimeType,
}) {
  final normalized = normalizeManualBody(raw, mimeType: mimeType);
  if (normalized.startsWith('rejected:')) {
    return const ManualInputRejected(ManualInputRejection.unsupportedMimeType);
  }
  if (normalized.isEmpty) {
    return const ManualInputRejected(ManualInputRejection.empty);
  }
  if (normalized.length < kMinBodyLength) {
    return const ManualInputRejected(ManualInputRejection.tooShort);
  }
  if (normalized.length > kMaxBodyLength) {
    return const ManualInputRejected(ManualInputRejection.tooLong);
  }
  final trimmedSender = (rawSender ?? '').trim();
  if (trimmedSender.length > kMaxSenderLength) {
    return const ManualInputRejected(ManualInputRejection.senderTooLong);
  }
  final sender = trimmedSender.isEmpty
      ? 'UNKNOWN'
      : trimmedSender.toUpperCase();
  final redacted = _buildRedactedPreview(normalized);
  return ManualInputAccepted(
    normalizedBody: normalized,
    normalizedSender: sender,
    redactedPreview: redacted,
  );
}

String _nfcNormalize(String text) {
  final runes = runesToNormalize(text);
  if (runes.isEmpty) return text;
  final normalized = String.fromCharCodes(runes);
  return normalized;
}

List<int> runesToNormalize(String text) {
  return text.runes.toList();
}

String _stripControlChars(String text) {
  final buf = StringBuffer();
  for (final code in text.runes) {
    if (code == 0x0A || code == 0x09) {
      buf.writeCharCode(code);
      continue;
    }
    if (code >= 0x200B && code <= 0x200D) continue;
    if (code == 0xFEFF) continue;
    if (code < 0x20 || (code >= 0x7F && code <= 0x9F)) continue;
    buf.writeCharCode(code);
  }
  return buf.toString();
}

String _collapseSpacesAndTabs(String text) {
  final result = StringBuffer();
  var inWhitespace = false;
  for (final code in text.runes) {
    if (code == 0x20 || code == 0x09) {
      if (!inWhitespace) {
        result.writeCharCode(0x20);
        inWhitespace = true;
      }
    } else {
      result.writeCharCode(code);
      inWhitespace = false;
    }
  }
  return result.toString();
}

String _buildRedactedPreview(String normalizedBody) {
  var preview = normalizedBody;
  preview = _redactAmounts(preview);
  preview = _redactDates(preview);
  preview = _redactPhoneNumbers(preview);
  if (preview.length > 300) {
    preview = '${preview.substring(0, 297)}...';
  }
  return preview;
}

String _redactAmounts(String text) {
  return text.replaceAll(
    RegExp(r'\b[A-Z]{3}\s[\d,]+\.\d{2}\b'),
    'XXX ••,••0.00',
  );
}

String _redactDates(String text) {
  var result = text.replaceAll(RegExp(r'\d{1,2}-\w{3}'), '[date]');
  result = result.replaceAll(
    RegExp(r'\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}'),
    '[datetime]',
  );
  result = result.replaceAll(
    RegExp(r'\d{2}/\d{2}/\d{4}\s\d{2}:\d{2}:\d{2}'),
    '[datetime]',
  );
  return result;
}

String _redactPhoneNumbers(String text) {
  return text.replaceAll(RegExp(r'\b\d{7,}\b'), '•••••••');
}
