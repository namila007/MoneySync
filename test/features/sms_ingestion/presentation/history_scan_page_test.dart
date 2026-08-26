import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_ingestion/presentation/history_import_controller.dart';
import 'package:money_sync/features/sms_ingestion/presentation/history_scan_page.dart';

Widget _buildApp(HistoryImportState state) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) async {
        final db = AppDatabase.inMemoryForTesting();
        ref.onDispose(db.close);
        return db;
      }),
      historyImportProvider.overrideWith(
        () => _StubHistoryImportController(state),
      ),
    ],
    child: const MaterialApp(home: HistoryImportPage()),
  );
}

void main() {
  group('HistoryImportPage', () {
    group('input view', () {
      testWidgets('renders app bar title', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Import from messages'), findsOneWidget);
      });

      testWidgets('shows tracked senders section', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Tracked senders'), findsOneWidget);
      });

      testWidgets('shows empty state when no tracked senders', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('No senders tracked yet.'), findsOneWidget);
      });

      testWidgets('shows Choose senders button when no tracked senders', (
        tester,
      ) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Choose senders to track first'), findsOneWidget);
      });

      testWidgets('shows date range section', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Date range'), findsOneWidget);
      });

      testWidgets('shows 3, 7, 14 day choice chips', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('3 days'), findsOneWidget);
        expect(find.text('7 days'), findsOneWidget);
        expect(find.text('14 days'), findsOneWidget);
      });

      testWidgets('shows maximum slider section', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Maximum'), findsOneWidget);
      });

      testWidgets('shows message cap value', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('100'), findsOneWidget);
      });

      testWidgets('shows inbox safety copy', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(
          find.text(
            'Only messages from tracked senders are read. '
            'Your inbox is never changed.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows Edit button for tracked senders', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Edit'), findsOneWidget);
      });
    });

    group('populated state with tracked senders', () {
      testWidgets('shows sender chips', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(trackedSenders: ['BANKA', 'BANKB']),
          ),
        );
        expect(find.text('BANKA'), findsOneWidget);
        expect(find.text('BANKB'), findsOneWidget);
      });

      testWidgets('shows Find messages button with correct label', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              trackedSenders: ['BANKA'],
              preset: 7,
              messageCap: 100,
            ),
          ),
        );
        expect(find.text('Find messages (7d, 100 max)'), findsOneWidget);
      });

      testWidgets('shows custom days in button when set', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              trackedSenders: ['BANKA'],
              customDays: 30,
              messageCap: 200,
            ),
          ),
        );
        expect(find.text('Find messages (30d, 200 max)'), findsOneWidget);
      });

      testWidgets('7 days chip is selected by default', (tester) async {
        await tester.pumpWidget(
          _buildApp(const HistoryImportState(preset: 7, trackedSenders: ['A'])),
        );
        final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
        final sevenDay = chips.firstWhere(
          (c) => c.label is Text && (c.label as Text).data == '7 days',
        );
        expect(sevenDay.selected, isTrue);
      });
    });

    group('scanning in progress', () {
      testWidgets('shows progress indicator', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(isScanning: true, trackedSenders: ['A']),
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows imported count', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              isScanning: true,
              imported: 25,
              trackedSenders: ['A'],
            ),
          ),
        );
        expect(find.text('Stored: 25'), findsOneWidget);
      });

      testWidgets('shows filtered count when > 0', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              isScanning: true,
              imported: 10,
              filtered: 5,
              trackedSenders: ['A'],
            ),
          ),
        );
        expect(find.text('Not recognised: 5'), findsOneWidget);
      });

      testWidgets('hides filtered count when 0', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              isScanning: true,
              imported: 10,
              filtered: 0,
              trackedSenders: ['A'],
            ),
          ),
        );
        expect(find.textContaining('Not recognised'), findsNothing);
      });

      testWidgets('shows duplicates count when > 0', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              isScanning: true,
              imported: 10,
              duplicates: 3,
              trackedSenders: ['A'],
            ),
          ),
        );
        expect(find.text('Already imported: 3'), findsOneWidget);
      });

      testWidgets('hides duplicates count when 0', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              isScanning: true,
              imported: 10,
              duplicates: 0,
              trackedSenders: ['A'],
            ),
          ),
        );
        expect(find.textContaining('Already imported'), findsNothing);
      });

      testWidgets('shows Cancel button', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(isScanning: true, trackedSenders: ['A']),
          ),
        );
        expect(find.text('Cancel'), findsOneWidget);
      });
    });

    group('terminal result view', () {
      for (final entry in {
        TerminalResult.completed: 'Import finished',
        TerminalResult.cancelled: 'Import cancelled',
        TerminalResult.capReached: 'Limit reached',
        TerminalResult.error: 'Import failed',
        TerminalResult.blocked: 'Import blocked',
        TerminalResult.noTrackedSenders: 'No tracked senders',
      }.entries) {
        testWidgets('shows correct title for ${entry.key.name}', (
          tester,
        ) async {
          await tester.pumpWidget(
            _buildApp(
              HistoryImportState(
                terminalResult: entry.key,
                imported: 10,
                filtered: 3,
                duplicates: 1,
              ),
            ),
          );
          expect(find.text(entry.value), findsWidgets);
        });
      }

      testWidgets('shows summary stats when not noTrackedSenders', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              terminalResult: TerminalResult.completed,
              imported: 20,
              filtered: 5,
              duplicates: 3,
            ),
          ),
        );
        expect(
          find.text(
            '20 stored · 5 not recognised as transactions · 3 already imported',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows skip explanation toggle when filtered > 0', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              terminalResult: TerminalResult.completed,
              imported: 10,
              filtered: 5,
            ),
          ),
        );
        expect(find.text('Why were some messages skipped?'), findsOneWidget);
      });

      testWidgets('hides skip explanation when filtered is 0', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              terminalResult: TerminalResult.completed,
              imported: 10,
              filtered: 0,
            ),
          ),
        );
        expect(find.text('Why were some messages skipped?'), findsNothing);
      });

      testWidgets('shows Done button for completed result', (tester) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              terminalResult: TerminalResult.completed,
              imported: 10,
            ),
          ),
        );
        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('shows Choose senders button for noTrackedSenders result', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              terminalResult: TerminalResult.noTrackedSenders,
            ),
          ),
        );
        expect(find.text('Choose senders'), findsOneWidget);
      });

      testWidgets('shows copy about nothing read for noTrackedSenders', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildApp(
            const HistoryImportState(
              terminalResult: TerminalResult.noTrackedSenders,
            ),
          ),
        );
        expect(
          find.text('Nothing was read. Choose at least one sender to track.'),
          findsOneWidget,
        );
      });
    });
  });
}

class _StubHistoryImportController extends HistoryImportController {
  _StubHistoryImportController(this._fixedState);

  final HistoryImportState _fixedState;

  @override
  HistoryImportState build() => _fixedState;
}
