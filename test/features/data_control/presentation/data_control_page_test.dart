import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';
import 'package:money_sync/features/data_control/presentation/data_control_controller.dart';
import 'package:money_sync/features/data_control/presentation/data_control_page.dart';

import 'package:money_sync/features/data_control/application/clear_local_data.dart';

class _FakeClearLocalDataUseCase implements IClearLocalDataUseCase {
  _FakeClearLocalDataUseCase({
    this.clearActivityResult = const ClearActivityResult(success: true),
    this.resetResult = const ResetAllDataResult(
      success: true,
      epochAdvanced: true,
      keysDeleted: true,
      databaseRemoved: true,
    ),
    this.clearActivityDelay = Duration.zero,
    this.resetDelay = Duration.zero,
  });

  ClearActivityResult clearActivityResult;
  ResetAllDataResult resetResult;
  Duration clearActivityDelay;
  Duration resetDelay;

  @override
  Future<ClearActivityResult> clearActivity() async {
    await Future.delayed(clearActivityDelay);
    return clearActivityResult;
  }

  @override
  Future<ResetAllDataResult> resetAllLocalData() async {
    await Future.delayed(resetDelay);
    return resetResult;
  }
}

Widget _makeTestApp(IClearLocalDataUseCase useCase) {
  return ProviderScope(
    overrides: [clearLocalDataUseCaseProvider.overrideWithValue(useCase)],
    child: const MaterialApp(home: DataControlPage()),
  );
}

void main() {
  group('DataControlPage', () {
    testWidgets('renders both clear activity and reset cards', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      expect(find.text('Clear activity'), findsWidgets);
      expect(find.text('Reset MoneySync'), findsWidgets);
      expect(find.text('Clear activity...'), findsOneWidget);
      expect(find.text('Reset local data...'), findsOneWidget);
    });

    testWidgets('clear activity button shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Clear activity...'));
      await tester.pumpAndSettle();

      expect(find.text('Clear activity?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Clear activity'), findsWidgets);
    });

    testWidgets('cancel dismisses clear activity dialog', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Clear activity...'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Clear activity?'), findsNothing);
    });

    testWidgets('confirm clear activity shows success banner', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Clear activity...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear activity'));
      await tester.pumpAndSettle();

      expect(find.text('Activity cleared.'), findsOneWidget);
    });

    testWidgets('confirm clear activity failure shows error banner', (
      tester,
    ) async {
      final fake = _FakeClearLocalDataUseCase(
        clearActivityResult: const ClearActivityResult(
          success: false,
          errorMessage: 'Clear failed',
        ),
      );
      await tester.pumpWidget(_makeTestApp(fake));

      await tester.tap(find.text('Clear activity...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear activity'));
      await tester.pumpAndSettle();

      expect(find.text('Clear failed'), findsOneWidget);
    });

    testWidgets('reset button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Reset local data...'));
      await tester.pumpAndSettle();

      expect(find.text('Reset all local data?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset everything'), findsOneWidget);
    });

    testWidgets('cancel dismisses reset dialog', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Reset local data...'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Reset all local data?'), findsNothing);
    });

    testWidgets('confirm reset shows success banner', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Reset local data...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset everything'));
      await tester.pumpAndSettle();

      expect(
        find.text('All local data reset. The app will restart.'),
        findsOneWidget,
      );
    });

    testWidgets('partial reset failure shows details and retry', (
      tester,
    ) async {
      final fake = _FakeClearLocalDataUseCase(
        resetResult: const ResetAllDataResult(
          success: false,
          epochAdvanced: true,
          keysDeleted: false,
          databaseRemoved: false,
        ),
      );
      await tester.pumpWidget(_makeTestApp(fake));

      await tester.tap(find.text('Reset local data...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset everything'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Partial reset'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Dismiss'), findsWidgets);
    });

    testWidgets('dismiss banner returns to idle state', (tester) async {
      await tester.pumpWidget(_makeTestApp(_FakeClearLocalDataUseCase()));

      await tester.tap(find.text('Clear activity...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear activity'));
      await tester.pumpAndSettle();

      expect(find.text('Activity cleared.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Activity cleared.'), findsNothing);
      expect(find.text('Clear activity...'), findsOneWidget);
      expect(find.text('Reset local data...'), findsOneWidget);
    });

    testWidgets('buttons are disabled while operation is busy', (tester) async {
      final fake = _FakeClearLocalDataUseCase(
        clearActivityDelay: const Duration(milliseconds: 100),
      );
      await tester.pumpWidget(_makeTestApp(fake));

      await tester.tap(find.text('Clear activity...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear activity'));
      await tester.pump();

      final clearButton = find.widgetWithText(OutlinedButton, 'Clearing...');
      expect(clearButton, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('reset button is disabled while reset is busy', (tester) async {
      final fake = _FakeClearLocalDataUseCase(
        resetDelay: const Duration(milliseconds: 100),
      );
      await tester.pumpWidget(_makeTestApp(fake));

      await tester.tap(find.text('Reset local data...'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset everything'));
      await tester.pump();

      final resettingButton = find.widgetWithText(FilledButton, 'Resetting...');
      expect(resettingButton, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });
  });
}
