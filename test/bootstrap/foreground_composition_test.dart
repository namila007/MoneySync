import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/core/scheduling/auto_import_scheduler.dart';

void main() {
  group('reArmAutoImportScheduler', () {
    test(
      'calls enable() with correct duration when autoImportEnabled is true',
      () async {
        final fake = _FakeAutoImportScheduler();
        await reArmAutoImportScheduler(
          scheduler: fake,
          autoImportEnabled: true,
          autoImportIntervalMinutes: 30,
        );

        expect(fake.enableCalls, 1);
        expect(fake.lastFrequency, const Duration(minutes: 30));
      },
    );

    test('does NOT call enable() when autoImportEnabled is false', () async {
      final fake = _FakeAutoImportScheduler();
      await reArmAutoImportScheduler(
        scheduler: fake,
        autoImportEnabled: false,
        autoImportIntervalMinutes: 15,
      );

      expect(fake.enableCalls, 0);
    });

    test(
      'uses default 15-minute interval when persisted value is 15',
      () async {
        final fake = _FakeAutoImportScheduler();
        await reArmAutoImportScheduler(
          scheduler: fake,
          autoImportEnabled: true,
          autoImportIntervalMinutes: 15,
        );

        expect(fake.lastFrequency, const Duration(minutes: 15));
      },
    );

    test('propagates scheduler exceptions', () async {
      final fake = _FailingAutoImportScheduler();
      expect(
        () => reArmAutoImportScheduler(
          scheduler: fake,
          autoImportEnabled: true,
          autoImportIntervalMinutes: 15,
        ),
        throwsException,
      );
    });
  });
}

class _FakeAutoImportScheduler implements AutoImportScheduler {
  int enableCalls = 0;
  Duration? lastFrequency;

  @override
  Future<void> enable({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    enableCalls++;
    lastFrequency = frequency;
  }

  @override
  Future<void> disable() async {}
}

class _FailingAutoImportScheduler implements AutoImportScheduler {
  @override
  Future<void> enable({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    throw Exception('scheduler failure');
  }

  @override
  Future<void> disable() async {}
}
