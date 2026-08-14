import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_sync/domain/retry_scheduler.dart';

void main() {
  test('delays grow exponentially from the base', () {
    final scheduler = RetryScheduler(
      baseDelay: const Duration(seconds: 1),
      backoffFor: (attempt) => Duration(seconds: 1 << (attempt - 1)),
      random: Random(1),
    );
    // Jitter range is 0.8..1.2; with a deterministic seed the values are fixed
    // but must stay within ±20% of the exponential base.
    final d1 = scheduler.nextDelay(1).inMilliseconds;
    final d2 = scheduler.nextDelay(2).inMilliseconds;
    final d3 = scheduler.nextDelay(3).inMilliseconds;

    expect(d1, inInclusiveRange(800, 1200));
    expect(d2, inInclusiveRange(1600, 2400));
    expect(d3, inInclusiveRange(3200, 4800));
  });

  test('delays are bounded by maxDelay even for huge attempt counts', () {
    final scheduler = RetryScheduler(
      baseDelay: const Duration(seconds: 1),
      maxDelay: const Duration(minutes: 1),
      backoffFor: (attempt) => Duration(seconds: 1 << (attempt - 1)),
      random: Random(2),
    );
    // 2^30s ≈ 34 years, far beyond maxDelay — must be capped to 60s ± jitter.
    final capped = scheduler.nextDelay(31).inMilliseconds;
    expect(capped, inInclusiveRange(48_000, 72_000));
  });

  test('injected backoffFor fully controls the base (no wall-clock)', () {
    var calls = 0;
    final scheduler = RetryScheduler(
      backoffFor: (attempt) {
        calls++;
        return const Duration(seconds: 10);
      },
      random: Random(3),
    );
    final d = scheduler.nextDelay(7);
    expect(calls, 1);
    expect(d.inMilliseconds, inInclusiveRange(8000, 12000));
  });

  test('rejects attempt < 1', () {
    final scheduler = RetryScheduler(random: Random(4));
    expect(
      () => scheduler.nextDelay(0),
      throwsArgumentError,
    );
  });
}
