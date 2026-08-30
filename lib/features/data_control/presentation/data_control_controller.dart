import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/data_control/application/clear_local_data.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';

sealed class DataControlState {
  const DataControlState();
}

final class DataControlIdle extends DataControlState {
  const DataControlIdle();
}

final class DataControlBusy extends DataControlState {
  const DataControlBusy(this.scope);
  final DataClearScope scope;
}

final class DataControlSuccess extends DataControlState {
  const DataControlSuccess(this.scope);
  final DataClearScope scope;
}

final class DataControlPartialFailure extends DataControlState {
  const DataControlPartialFailure({
    required this.scope,
    required this.succeeded,
    required this.failed,
    required this.details,
  });

  final DataClearScope scope;
  final int succeeded;
  final int failed;
  final List<String> details;

  String get recoveryMessage =>
      '$succeeded step${succeeded == 1 ? '' : 's'} completed, '
      '$failed step${failed == 1 ? '' : 's'} failed. '
      'Try again or restart the app.';
}

final class DataControlFailure extends DataControlState {
  const DataControlFailure({required this.scope, required this.errorMessage});
  final DataClearScope scope;
  final String errorMessage;
}

final clearLocalDataUseCaseProvider = Provider<IClearLocalDataUseCase?>((ref) {
  throw UnimplementedError(
    'IClearLocalDataUseCase not provided — supply via ProviderScope override.',
  );
});

final dataControlControllerProvider =
    NotifierProvider<DataControlController, DataControlState>(
      DataControlController.new,
    );

class DataControlController extends Notifier<DataControlState> {
  @override
  DataControlState build() {
    return const DataControlIdle();
  }

  IClearLocalDataUseCase _useCase() {
    final useCase = ref.read(clearLocalDataUseCaseProvider);
    if (useCase == null) {
      throw StateError('IClearLocalDataUseCase not provided.');
    }
    return useCase;
  }

  Future<void> clearActivity() async {
    state = const DataControlBusy(DataClearScope.clearActivity);

    try {
      final result = await _useCase().clearActivity();

      if (result.success) {
        state = const DataControlSuccess(DataClearScope.clearActivity);
      } else {
        state = DataControlFailure(
          scope: DataClearScope.clearActivity,
          errorMessage:
              result.errorMessage ?? 'Activity clear did not complete.',
        );
      }
    } on Object catch (e, s) {
      final logger = Logger('DataControlController');
      logger.error('Activity clear failed in controller', e, s);
      state = DataControlFailure(
        scope: DataClearScope.clearActivity,
        errorMessage: 'Activity clear failed. Try again.',
      );
    }
  }

  Future<void> resetAllLocalData() async {
    state = const DataControlBusy(DataClearScope.resetAllLocalData);

    try {
      final result = await _useCase().resetAllLocalData();

      if (result.success) {
        state = const DataControlSuccess(DataClearScope.resetAllLocalData);
      } else if (result.succeededSteps > 0 && result.failedSteps > 0) {
        state = DataControlPartialFailure(
          scope: DataClearScope.resetAllLocalData,
          succeeded: result.succeededSteps,
          failed: result.failedSteps,
          details: result.stepDetails,
        );
      } else {
        state = DataControlFailure(
          scope: DataClearScope.resetAllLocalData,
          errorMessage: result.errorMessage ?? 'Reset did not complete.',
        );
      }
    } on Object catch (e, s) {
      final logger = Logger('DataControlController');
      logger.error('Reset failed in controller', e, s);
      state = DataControlFailure(
        scope: DataClearScope.resetAllLocalData,
        errorMessage: 'Reset failed. Restart the app and try again.',
      );
    }
  }

  void resetToIdle() {
    state = const DataControlIdle();
  }
}
