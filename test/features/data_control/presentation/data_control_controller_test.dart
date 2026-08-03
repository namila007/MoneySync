import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/data_control/application/clear_local_data.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';
import 'package:money_sync/features/data_control/presentation/data_control_controller.dart';

class _FakeClearLocalDataUseCase implements IClearLocalDataUseCase {
  _FakeClearLocalDataUseCase({
    this.clearActivityResult = const ClearActivityResult(success: true),
    this.resetResult = const ResetAllDataResult(
      success: true,
      epochAdvanced: true,
      keysDeleted: true,
      databaseRemoved: true,
    ),
  });

  ClearActivityResult clearActivityResult;
  ResetAllDataResult resetResult;
  int clearActivityCalls = 0;
  int resetCalls = 0;

  @override
  Future<ClearActivityResult> clearActivity() async {
    clearActivityCalls++;
    return clearActivityResult;
  }

  @override
  Future<ResetAllDataResult> resetAllLocalData() async {
    resetCalls++;
    return resetResult;
  }
}

ProviderContainer _containerWith(IClearLocalDataUseCase useCase) {
  final container = ProviderContainer(
    overrides: [clearLocalDataUseCaseProvider.overrideWithValue(useCase)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('DataControlController', () {
    test('initial state is DataControlIdle', () {
      final container = _containerWith(_FakeClearLocalDataUseCase());
      final state = container.read(dataControlControllerProvider);
      expect(state, isA<DataControlIdle>());
    });

    test('clearActivity transitions to Busy then Success', () async {
      final fake = _FakeClearLocalDataUseCase();
      final container = _containerWith(fake);

      final future = container
          .read(dataControlControllerProvider.notifier)
          .clearActivity();

      expect(
        container.read(dataControlControllerProvider),
        isA<DataControlBusy>(),
      );
      await future;
      expect(
        container.read(dataControlControllerProvider),
        isA<DataControlSuccess>(),
      );
      final success =
          container.read(dataControlControllerProvider) as DataControlSuccess;
      expect(success.scope, DataClearScope.clearActivity);
      expect(fake.clearActivityCalls, equals(1));
    });

    test('clearActivity handles failure', () async {
      final fake = _FakeClearLocalDataUseCase(
        clearActivityResult: const ClearActivityResult(
          success: false,
          errorMessage: 'Clear failed',
        ),
      );
      final container = _containerWith(fake);

      await container
          .read(dataControlControllerProvider.notifier)
          .clearActivity();

      final state = container.read(dataControlControllerProvider);
      expect(state, isA<DataControlFailure>());
      final failure = state as DataControlFailure;
      expect(failure.scope, DataClearScope.clearActivity);
      expect(failure.errorMessage, equals('Clear failed'));
      expect(fake.clearActivityCalls, equals(1));
    });

    test('resetAllLocalData transitions to Busy then Success', () async {
      final fake = _FakeClearLocalDataUseCase();
      final container = _containerWith(fake);

      final future = container
          .read(dataControlControllerProvider.notifier)
          .resetAllLocalData();

      expect(
        container.read(dataControlControllerProvider),
        isA<DataControlBusy>(),
      );
      await future;
      expect(
        container.read(dataControlControllerProvider),
        isA<DataControlSuccess>(),
      );
      final success =
          container.read(dataControlControllerProvider) as DataControlSuccess;
      expect(success.scope, DataClearScope.resetAllLocalData);
      expect(fake.resetCalls, equals(1));
    });

    test('resetAllLocalData handles partial failure with details', () async {
      final fake = _FakeClearLocalDataUseCase(
        resetResult: const ResetAllDataResult(
          success: false,
          epochAdvanced: true,
          keysDeleted: false,
          databaseRemoved: false,
        ),
      );
      final container = _containerWith(fake);

      await container
          .read(dataControlControllerProvider.notifier)
          .resetAllLocalData();

      final state = container.read(dataControlControllerProvider);
      expect(state, isA<DataControlPartialFailure>());
      final failure = state as DataControlPartialFailure;
      expect(failure.succeeded, equals(1));
      expect(failure.failed, equals(2));
      expect(failure.details, isNotEmpty);
      expect(failure.recoveryMessage, contains('1 step'));
      expect(failure.recoveryMessage, contains('2 steps'));
      expect(fake.resetCalls, equals(1));
    });

    test('resetAllLocalData handles complete failure', () async {
      final fake = _FakeClearLocalDataUseCase(
        resetResult: const ResetAllDataResult(
          success: false,
          errorMessage: 'Reset failed completely',
        ),
      );
      final container = _containerWith(fake);

      await container
          .read(dataControlControllerProvider.notifier)
          .resetAllLocalData();

      final state = container.read(dataControlControllerProvider);
      expect(state, isA<DataControlFailure>());
      final failure = state as DataControlFailure;
      expect(failure.scope, DataClearScope.resetAllLocalData);
      expect(failure.errorMessage, equals('Reset failed completely'));
      expect(fake.resetCalls, equals(1));
    });

    test('resetToIdle returns to idle state', () async {
      final fake = _FakeClearLocalDataUseCase();
      final container = _containerWith(fake);

      await container
          .read(dataControlControllerProvider.notifier)
          .clearActivity();
      container.read(dataControlControllerProvider.notifier).resetToIdle();

      expect(
        container.read(dataControlControllerProvider),
        isA<DataControlIdle>(),
      );
    });

    test('throws when use case is not provided', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      try {
        await container
            .read(dataControlControllerProvider.notifier)
            .clearActivity();
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('clearActivity catches exceptions and maps to failure', () async {
      final container = _containerWith(_ThrowingClearLocalDataUseCase());

      await container
          .read(dataControlControllerProvider.notifier)
          .clearActivity();

      final state = container.read(dataControlControllerProvider);
      expect(state, isA<DataControlFailure>());
    });

    test('resetAllLocalData catches exceptions and maps to failure', () async {
      final container = _containerWith(_ThrowingClearLocalDataUseCase());

      await container
          .read(dataControlControllerProvider.notifier)
          .resetAllLocalData();

      final state = container.read(dataControlControllerProvider);
      expect(state, isA<DataControlFailure>());
    });
  });
}

class _ThrowingClearLocalDataUseCase implements IClearLocalDataUseCase {
  @override
  Future<ClearActivityResult> clearActivity() async {
    throw Exception('Unexpected error');
  }

  @override
  Future<ResetAllDataResult> resetAllLocalData() async {
    throw Exception('Unexpected error');
  }
}
