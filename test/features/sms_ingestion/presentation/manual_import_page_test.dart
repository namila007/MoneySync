import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_ingestion/presentation/manual_import_controller.dart';
import 'package:money_sync/features/sms_ingestion/presentation/manual_import_page.dart';

Widget _buildApp(ManualImportState state) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) async {
        final db = AppDatabase.inMemoryForTesting();
        ref.onDispose(db.close);
        return db;
      }),
      manualImportProvider.overrideWith(
        () => _StubManualImportController(state),
      ),
    ],
    child: const MaterialApp(home: ManualImportPage()),
  );
}

void main() {
  group('ManualImportPage', () {
    group('input view', () {
      testWidgets('renders app bar title', (tester) async {
        await tester.pumpWidget(_buildApp(const ManualImportState()));
        expect(find.text('Paste a message'), findsOneWidget);
      });

      testWidgets('shows body text field', (tester) async {
        await tester.pumpWidget(_buildApp(const ManualImportState()));
        expect(find.text('Paste bank message here'), findsOneWidget);
      });

      testWidgets('shows sender text field', (tester) async {
        await tester.pumpWidget(_buildApp(const ManualImportState()));
        expect(find.text('Sender (optional)'), findsOneWidget);
      });

      testWidgets('shows character count', (tester) async {
        await tester.pumpWidget(_buildApp(const ManualImportState()));
        expect(find.text('0 / 2000'), findsOneWidget);
      });

      testWidgets('shows Review button', (tester) async {
        await tester.pumpWidget(_buildApp(const ManualImportState()));
        expect(find.text('Review'), findsOneWidget);
      });

      testWidgets('Review button is disabled when body is empty', (
        tester,
      ) async {
        await tester.pumpWidget(_buildApp(const ManualImportState()));
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('Review button is enabled when body meets min length', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              body: 'This is a valid bank message text for testing',
            ),
          ),
        );
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('shows share intent banner when isShareIntent', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(const ManualImportState(isShareIntent: true, body: '')),
        );
        expect(
          find.text('Shared messages always go to review.'),
          findsOneWidget,
        );
      });

      testWidgets('hides share intent banner when not share intent', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(const ManualImportState(isShareIntent: false)),
        );
        expect(find.text('Shared messages always go to review.'), findsNothing);
      });

      testWidgets('shows body length in character count', (tester) async {
        await tester.pumpWidget(
          _buildApp(const ManualImportState(body: 'Hello')),
        );
        expect(find.text('5 / 2000'), findsOneWidget);
      });
    });

    group('preview view', () {
      testWidgets('renders Review message title', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Your card was debited',
              sender: 'BANKA',
            ),
          ),
        );
        expect(find.text('Review message'), findsOneWidget);
      });

      testWidgets('shows sender in preview', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Your card was debited',
              sender: 'BANKA',
            ),
          ),
        );
        expect(find.text('BANKA'), findsOneWidget);
      });

      testWidgets('shows Not specified when sender is empty', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Your card was debited',
              sender: '',
            ),
          ),
        );
        expect(find.text('Not specified'), findsOneWidget);
      });

      testWidgets('shows body in preview', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Your card was debited',
            ),
          ),
        );
        expect(find.text('Your card was debited'), findsOneWidget);
      });

      testWidgets('shows Add message button', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Test message body here',
            ),
          ),
        );
        expect(find.text('Add message'), findsOneWidget);
      });

      testWidgets('shows Discard button', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Test message body here',
            ),
          ),
        );
        expect(find.text('Discard'), findsOneWidget);
      });

      testWidgets('shows share intent warning in preview when share intent', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Shared content',
              isShareIntent: true,
            ),
          ),
        );
        expect(
          find.text('Shared messages are permanently review-only.'),
          findsOneWidget,
        );
      });

      testWidgets(
        'hides share intent warning in preview when not share intent',
        (tester) async {
          await tester.pumpWidget(
            _buildApp(
              const ManualImportState(
                step: ManualImportStep.preview,
                body: 'Test body',
                isShareIntent: false,
              ),
            ),
          );
          expect(
            find.text('Shared messages are permanently review-only.'),
            findsNothing,
          );
        },
      );

      testWidgets('shows loading indicator when submitting', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Test body',
              isSubmitting: true,
            ),
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('hides buttons when submitting', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.preview,
              body: 'Test body',
              isSubmitting: true,
            ),
          ),
        );
        expect(find.text('Add message'), findsNothing);
        expect(find.text('Discard'), findsNothing);
      });

      testWidgets('shows empty message label when body is empty', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(step: ManualImportStep.preview, body: ''),
          ),
        );
        expect(find.text('(empty)'), findsOneWidget);
      });
    });

    group('result view', () {
      testWidgets('shows Result title', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Imported',
              resultType: ImportResultType.success,
            ),
          ),
        );
        expect(find.text('Result'), findsOneWidget);
      });

      testWidgets('shows success message for success result', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Message imported and queued for review.',
              resultType: ImportResultType.success,
            ),
          ),
        );
        expect(
          find.text('Message imported and queued for review.'),
          findsOneWidget,
        );
      });

      testWidgets('shows check icon for success result', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Imported',
              resultType: ImportResultType.success,
            ),
          ),
        );
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('shows info icon for error result', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Something went wrong',
              resultType: ImportResultType.error,
            ),
          ),
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('shows Done button', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Imported',
              resultType: ImportResultType.success,
            ),
          ),
        );
        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('shows Import another button', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Imported',
              resultType: ImportResultType.success,
            ),
          ),
        );
        expect(find.text('Import another'), findsOneWidget);
      });

      testWidgets('shows already present message', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'This message was already imported.',
              resultType: ImportResultType.alreadyPresent,
            ),
          ),
        );
        expect(find.text('This message was already imported.'), findsOneWidget);
      });

      testWidgets('shows filtered message', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Message filtered: otpOnly.',
              resultType: ImportResultType.filtered,
            ),
          ),
        );
        expect(find.text('Message filtered: otpOnly.'), findsOneWidget);
      });

      testWidgets('shows rejected message', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: 'Message is too short (minimum 12 characters).',
              resultType: ImportResultType.rejected,
            ),
          ),
        );
        expect(
          find.text('Message is too short (minimum 12 characters).'),
          findsOneWidget,
        );
      });

      testWidgets('falls back to Unknown result message when null', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const ManualImportState(
              step: ManualImportStep.result,
              resultMessage: null,
              resultType: null,
            ),
          ),
        );
        expect(find.text('Unknown result.'), findsOneWidget);
      });
    });
  });
}

class _StubManualImportController extends ManualImportController {
  _StubManualImportController(this._fixedState);

  final ManualImportState _fixedState;

  @override
  ManualImportState build() => _fixedState;
}
