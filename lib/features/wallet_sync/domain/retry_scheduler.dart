import 'dart:math';

/// Bounded exponential backoff with ±20% jitter for Wallet outbox retries
/// (plan/03 §wallet_mutation `attempt_count`, `next_attempt_at`; M5.5).
///
/// Pure Dart and independent of wall-clock time: the exponential base for a
/// given attempt is injectable, so tests are deterministic.
final class RetryScheduler {
  RetryScheduler({
    this.baseDelay = const Duration(seconds: 30),
    this.maxDelay = const Duration(hours: 4),
    Duration Function(int attempt)? backoffFor,
    Random? random,
  }) : _backoffFor = backoffFor ?? _exponentialBackoff(baseDelay),
       _random = random ?? Random();

  /// Delay before the first retry attempt.
  final Duration baseDelay;

  /// Hard ceiling on any single retry delay.
  final Duration maxDelay;

  final Duration Function(int attempt) _backoffFor;
  final Random _random;

  /// Delay before retry [attempt] (1-based), with ±20% jitter applied around
  /// the exponential base and bounded by [maxDelay].
  Duration nextDelay(int attempt) {
    if (attempt < 1) throw ArgumentError.value(attempt, 'attempt', '>= 1');
    final base = _backoffFor(attempt);
    final boundedMs = min(base.inMilliseconds, maxDelay.inMilliseconds);
    final jitter = 0.8 + (_random.nextDouble() * 0.4);
    return Duration(milliseconds: (boundedMs * jitter).round());
  }

  static Duration Function(int attempt) _exponentialBackoff(Duration base) {
    return (int attempt) {
      // 2^(attempt-1) * base; shift avoids pow().
      final shift = min(attempt - 1, 62);
      return Duration(milliseconds: base.inMilliseconds << shift);
    };
  }
}
