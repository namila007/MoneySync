import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/retention_policy.dart';

void main() {
  const policy = RetentionPolicy();
  final observedAt = DateTime.utc(2026, 7, 22, 8);

  test('OTP and unrelated app copies are purged immediately', () {
    for (final content in [
      AppOwnedContent.otp,
      AppOwnedContent.unrelated,
      AppOwnedContent.rejected,
    ]) {
      expect(
        policy.decide(content: content, observedAt: observedAt),
        RetentionDecision.purgeAt(observedAt),
      );
    }
  });

  test(
    'processed raw copies purge by default and opt-in is capped at 30 days',
    () {
      expect(
        policy.decide(
          content: AppOwnedContent.processedRaw,
          observedAt: observedAt,
        ),
        RetentionDecision.purgeAt(observedAt),
      );
      expect(
        policy.decide(
          content: AppOwnedContent.processedRaw,
          observedAt: observedAt,
          rawCopyPreference: RawCopyRetention.keepFor(const Duration(days: 30)),
        ),
        RetentionDecision.purgeAt(observedAt.add(const Duration(days: 30))),
      );
      expect(
        () => RawCopyRetention.keepFor(const Duration(days: 31)),
        throwsArgumentError,
      );
      expect(
        () => RawCopyRetention.keepFor(Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => RawCopyRetention.keepFor(const Duration(microseconds: -1)),
        throwsArgumentError,
      );
    },
  );

  test('raw-copy retention permits its maximum boundary and exposes state', () {
    final maximum = RawCopyRetention.keepFor(RawCopyRetention.maximumDuration);

    expect(RawCopyRetention.disabled.isEnabled, isFalse);
    expect(maximum.isEnabled, isTrue);
    expect(maximum.duration, const Duration(days: 30));
  });

  test('activity defaults to a 180 day retention period', () {
    expect(
      policy.decide(content: AppOwnedContent.activity, observedAt: observedAt),
      RetentionDecision.purgeAt(observedAt.add(const Duration(days: 180))),
    );
  });

  test(
    'retention decisions normalize timestamps and compare by purge instant',
    () {
      final localObservedAt = DateTime(2026, 7, 22, 13, 30);
      final decision = policy.decide(
        content: AppOwnedContent.activity,
        observedAt: localObservedAt,
      );
      final sameDecision = RetentionDecision.purgeAt(decision.purgeAt);

      expect(decision.purgeAt.isUtc, isTrue);
      expect(decision, sameDecision);
      expect(decision.hashCode, sameDecision.hashCode);
      expect(
        decision,
        isNot(
          RetentionDecision.purgeAt(
            decision.purgeAt.add(const Duration(days: 1)),
          ),
        ),
      );
    },
  );
}
