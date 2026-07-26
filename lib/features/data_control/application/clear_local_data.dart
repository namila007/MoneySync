import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/privacy/clear_local_data.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';

final class ClearLocalDataUseCase {
  ClearLocalDataUseCase({
    required this.database,
    required this.clearLocalDataService,
  });

  final AppDatabase database;
  final ClearLocalDataService clearLocalDataService;

  Future<ClearActivityResult> clearActivity() async {
    try {
      final result = await clearLocalDataService.clearActivityOnly();
      return ClearActivityResult(success: result.epochAdvanced);
    } catch (e) {
      return ClearActivityResult(success: false, errorMessage: e.toString());
    }
  }

  Future<ClearActivityResult> resetAllLocalData() async {
    try {
      final result = await clearLocalDataService.clearAllAppData();
      return ClearActivityResult(success: result.success);
    } catch (e) {
      return ClearActivityResult(success: false, errorMessage: e.toString());
    }
  }
}
