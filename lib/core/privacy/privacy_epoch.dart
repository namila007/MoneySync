/// A monotonically increasing version for privacy-sensitive local data.
///
/// Work captures this value before it starts and must not commit if a later
/// clear, consent withdrawal, or deletion has advanced the persisted epoch.
final class PrivacyEpoch {
  factory PrivacyEpoch(int value) {
    if (value < 0) {
      throw ArgumentError('Privacy epoch is non-negative.');
    }
    return PrivacyEpoch._(value);
  }

  const PrivacyEpoch._(this.value);

  final int value;

  PrivacyEpoch advance() {
    if (value == 0x7fffffffffffffff) {
      throw StateError('Privacy epoch cannot advance further.');
    }
    return PrivacyEpoch(value + 1);
  }

  @override
  bool operator ==(Object other) =>
      other is PrivacyEpoch && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Applies the fail-closed privacy epoch comparison used by future workers.
abstract final class PrivacyEpochPolicy {
  static bool isCurrent({
    required PrivacyEpoch captured,
    required PrivacyEpoch current,
  }) => captured == current;
}
