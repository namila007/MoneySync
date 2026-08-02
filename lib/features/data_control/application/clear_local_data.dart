import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/privacy/clear_local_data.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';

abstract interface class IClearLocalDataUseCase {
  Future<ClearActivityResult> clearActivity();
  Future<ResetAllDataResult> resetAllLocalData();
}

final class ClearLocalDataUseCase implements IClearLocalDataUseCase {
  ClearLocalDataUseCase({
    required this.database,
    required this.clearLocalDataService,
  });

  final AppDatabase database;
  final ClearLocalDataService clearLocalDataService;

  @override
  Future<ClearActivityResult> clearActivity() async {
    try {
      final result = await clearLocalDataService.clearActivityOnly();
      return ClearActivityResult(
        success: result.activityCleared,
        epochAdvanced: result.activityCleared,
      );
    } on Exception {
      return const ClearActivityResult(
        success: false,
        errorMessage: 'Activity clear failed. Try again.',
      );
    }
  }

  @override
  Future<ResetAllDataResult> resetAllLocalData() async {
    try {
      final result = await clearLocalDataService.clearAllAppData();
      return ResetAllDataResult(
        success: result.success,
        epochAdvanced: result.epochAdvanced,
        keysDeleted: result.keysDeleted,
        databaseRemoved: result.databaseRemoved,
      );
    } on Exception {
      return const ResetAllDataResult(
        success: false,
        errorMessage: 'Reset failed. Restart the app and try again.',
      );
    }
  }
}
