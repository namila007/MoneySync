import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/time/clock.dart';
import 'package:money_sync/core/time/id_generator.dart';

void main() {
  testWidgets('shell startup does not invoke injected time or ID ports', (
    tester,
  ) async {
    final clock = _CountingClock();
    final ids = _CountingIdGenerator();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(const AppConfig.playManual()),
          clockProvider.overrideWithValue(clock),
          idGeneratorProvider.overrideWithValue(ids),
        ],
        child: const MoneySyncApp(),
      ),
    );

    expect(clock.calls, isZero);
    expect(ids.calls, isZero);
  });
}

final class _CountingClock implements Clock {
  int calls = 0;

  @override
  DateTime now() {
    calls += 1;
    return DateTime.utc(2026, 7, 20);
  }
}

final class _CountingIdGenerator implements IdGenerator {
  int calls = 0;

  @override
  String next() {
    calls += 1;
    return 'unused';
  }
}
