/// The reason an unsafe value was rejected. It intentionally contains no value.
enum RedactionViolationKind {
  rawText,
  tokenLikeText,
  fullInstrumentSuffix,
  arbitraryMetadata,
}

/// A safe exception suitable for an activity event; never includes input text.
final class RedactionViolation implements Exception {
  const RedactionViolation(this.kind);

  final RedactionViolationKind kind;

  @override
  String toString() => 'RedactionViolation(${kind.name})';
}

/// An instrument display value restricted to at most two digits.
final class InstrumentTail {
  InstrumentTail(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    if (!RegExp(r'^[0-9]{1,2}$').hasMatch(value)) {
      throw const RedactionViolation(
        RedactionViolationKind.fullInstrumentSuffix,
      );
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      other is InstrumentTail && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Keeps activity logging allowlisted: untyped text and maps have no safe path.
final class ActivityRedaction {
  const ActivityRedaction();

  static final RegExp _tokenPattern = RegExp(
    r'(?:bearer\s+|token\s*[:=]|api[_-]?key\s*[:=])',
    caseSensitive: false,
  );

  Never rejectRawText(String value) =>
      throw const RedactionViolation(RedactionViolationKind.rawText);

  void rejectTokenLikeText(String value) {
    if (_tokenPattern.hasMatch(value)) {
      throw const RedactionViolation(RedactionViolationKind.tokenLikeText);
    }
  }

  Never rejectArbitraryMetadata(Map<String, Object?> metadata) =>
      throw const RedactionViolation(RedactionViolationKind.arbitraryMetadata);
}
