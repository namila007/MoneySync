import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/time/clock.dart';
import 'package:money_sync/core/time/id_generator.dart';

void main() {
  test(
    'fixed clock and deterministic IDs make application logic repeatable',
    () {
      final clock = FixedClock(DateTime.utc(2026, 7, 20, 10));
      final ids = DeterministicIdGenerator(prefix: 'test', initialValue: 4);

      expect(clock.now(), DateTime.utc(2026, 7, 20, 10));
      expect(ids.next(), 'test-4');
      expect(ids.next(), 'test-5');
    },
  );
}
