import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';

void main() {
  group('DataClearScope', () {
    test('clearActivity and resetAllLocalData are distinct scopes', () {
      expect(
        DataClearScope.clearActivity,
        isNot(DataClearScope.resetAllLocalData),
      );
    });

    test('all scopes are valid enum values', () {
      expect(DataClearScope.values, hasLength(2));
    });
  });

  group('ClearActivityResult', () {
    test('successful result has success=true', () {
      const result = ClearActivityResult(success: true);
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('failed result carries error message', () {
      const result = ClearActivityResult(
        success: false,
        errorMessage: 'Something went wrong',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Something went wrong'));
    });

    test('epochAdvanced is null by default', () {
      const result = ClearActivityResult(success: true);
      expect(result.epochAdvanced, isNull);
    });

    test('epochAdvanced can be set explicitly', () {
      const result = ClearActivityResult(success: true, epochAdvanced: true);
      expect(result.epochAdvanced, isTrue);
    });

    test('rowsDeleted is null by default', () {
      const result = ClearActivityResult(success: true);
      expect(result.rowsDeleted, isNull);
    });
  });

  group('ResetAllDataResult', () {
    test('successful result has all steps true', () {
      const result = ResetAllDataResult(
        success: true,
        epochAdvanced: true,
        keysDeleted: true,
        databaseRemoved: true,
      );
      expect(result.success, isTrue);
      expect(result.succeededSteps, equals(3));
      expect(result.failedSteps, equals(0));
    });

    test('partial failure tracks succeeded and failed steps', () {
      const result = ResetAllDataResult(
        success: false,
        epochAdvanced: true,
        keysDeleted: false,
        databaseRemoved: false,
      );
      expect(result.succeededSteps, equals(1));
      expect(result.failedSteps, equals(2));
    });

    test('complete failure has all steps false', () {
      const result = ResetAllDataResult(
        success: false,
        epochAdvanced: false,
        keysDeleted: false,
        databaseRemoved: false,
      );
      expect(result.succeededSteps, equals(0));
      expect(result.failedSteps, equals(3));
    });

    test('stepDetails lists each step outcome', () {
      const result = ResetAllDataResult(
        success: false,
        epochAdvanced: true,
        keysDeleted: false,
        databaseRemoved: true,
      );
      final details = result.stepDetails;
      expect(details, contains('Privacy epoch advanced'));
      expect(details, contains('Security key deletion failed'));
      expect(details, contains('Database and logs removed'));
    });

    test('failed result carries error message', () {
      const result = ResetAllDataResult(
        success: false,
        errorMessage: 'Reset failed',
      );
      expect(result.errorMessage, equals('Reset failed'));
    });

    test('all null steps count as zero succeeded', () {
      const result = ResetAllDataResult(success: false);
      expect(result.succeededSteps, equals(0));
      expect(result.failedSteps, equals(0));
    });
  });
}
