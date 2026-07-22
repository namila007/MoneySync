/// App-owned content governed by the short-retention privacy policy.
enum AppOwnedContent { otp, unrelated, rejected, processedRaw, activity }

/// A user choice for retaining encrypted, app-owned raw copies.
final class RawCopyRetention {
  const RawCopyRetention._(this.duration);

  static const disabled = RawCopyRetention._(Duration.zero);
  static const maximumDuration = Duration(days: 30);

  final Duration duration;

  factory RawCopyRetention.keepFor(Duration duration) {
    if (duration <= Duration.zero || duration > maximumDuration) {
      throw ArgumentError(
        'Raw-copy retention must be greater than zero and no more than 30 days.',
      );
    }
    return RawCopyRetention._(duration);
  }

  bool get isEnabled => duration > Duration.zero;
}

/// The outcome for a single app-owned item. It never controls a source SMS.
final class RetentionDecision {
  const RetentionDecision.purgeAt(this.purgeAt);

  final DateTime purgeAt;

  @override
  bool operator ==(Object other) =>
      other is RetentionDecision && other.purgeAt == purgeAt;

  @override
  int get hashCode => purgeAt.hashCode;
}

/// Deterministic default retention policy for app-owned data only.
final class RetentionPolicy {
  const RetentionPolicy();

  static const activityRetention = Duration(days: 180);

  RetentionDecision decide({
    required AppOwnedContent content,
    required DateTime observedAt,
    RawCopyRetention rawCopyPreference = RawCopyRetention.disabled,
  }) {
    final timestamp = observedAt.toUtc();
    return switch (content) {
      AppOwnedContent.otp ||
      AppOwnedContent.unrelated ||
      AppOwnedContent.rejected => RetentionDecision.purgeAt(timestamp),
      AppOwnedContent.processedRaw => RetentionDecision.purgeAt(
        timestamp.add(rawCopyPreference.duration),
      ),
      AppOwnedContent.activity => RetentionDecision.purgeAt(
        timestamp.add(activityRetention),
      ),
    };
  }
}
