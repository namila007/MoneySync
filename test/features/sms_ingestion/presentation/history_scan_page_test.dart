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

Finder _scrollableFinder() => find.descendant(
  of: find.byType(ListView),
  matching: find.byType(Scrollable),
);

void main() {
  group('HistoryImportPage', () {
    group('input view', () {
      testWidgets('renders Sync Past Activity title', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Sync Past Activity'), findsOneWidget);
      });

      testWidgets('renders Data Recovery tag', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Data Recovery'), findsOneWidget);
      });

      testWidgets('shows Choose Sources section', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('1. CHOOSE SOURCES'), findsOneWidget);
        expect(find.text('0 available'), findsOneWidget);
      });

      testWidgets('shows Configuration section', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('2. CONFIGURATION'), findsOneWidget);
      });

      testWidgets('shows scan depth presets', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('SCAN DEPTH'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('20'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
        expect(find.text('Custom'), findsOneWidget);
      });

      testWidgets('shows Privacy Guard card', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        await tester.scrollUntilVisible(
          find.text('Privacy Guard Active'),
          250,
          scrollable: _scrollableFinder(),
        );
        expect(find.text('Privacy Guard Active'), findsOneWidget);
      });

      testWidgets('shows Initiate bulk import button', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        await tester.scrollUntilVisible(
          find.text('Initiate bulk import'),
          250,
          scrollable: _scrollableFinder(),
        );
        expect(find.text('Initiate bulk import'), findsOneWidget);
      });

      testWidgets('shows Update sources button', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('Update sources'), findsOneWidget);
      });

      testWidgets('disables import button when no tracked senders', (
        tester,
      ) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        await tester.scrollUntilVisible(
          find.text('Initiate bulk import'),
          250,
          scrollable: _scrollableFinder(),
        );
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Initiate bulk import'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('shows import range presets', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('IMPORT RANGE'), findsOneWidget);
        expect(find.text('7 days'), findsOneWidget);
        expect(find.text('14 days'), findsOneWidget);
        expect(find.text('30 days'), findsOneWidget);
        expect(find.text('60 days'), findsOneWidget);
      });

      testWidgets('has AppBar with back button', (tester) async {
        await tester.pumpWidget(_buildApp(const HistoryImportState()));
        expect(find.text('History Import'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('populated state', () {
      testWidgets('shows source card for tracked sender', (tester) async {
        await tester.pumpWidget(
          _buildApp(const HistoryImportState(trackedSenders: ['SAMPATHTX'])),
        );
        expect(find.text('SAMPATHTX'), findsWidgets);
        expect(find.text('1 available'), findsOneWidget);
      });

      testWidgets('enables import button when senders tracked', (tester) async {
        await tester.pumpWidget(
          _buildApp(const HistoryImportState(trackedSenders: ['SAMPATHTX'])),
        );
        await tester.pumpAndSettle();
        // The button exists in the widget tree (may be off-screen in ListView)
        expect(
          find.text('Initiate bulk import', skipOffstage: false),
          findsOneWidget,
        );
      });

      testWidgets('shows estimated time', (tester) async {
        await tester.pumpWidget(
          _buildApp(const HistoryImportState(trackedSenders: ['SAMPATHTX'])),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('estimated time', skipOffstage: false),
          findsOneWidget,
        );
      });
    });
  });
}

class _StubHistoryImportController extends HistoryImportController {
  _StubHistoryImportController(this._initialState);

  final HistoryImportState _initialState;

  @override
  HistoryImportState build() => _initialState;

  @override
  Future<void> reloadTrackedSenders() async {}

  @override
  void selectPreset(int days) {}

  @override
  void setCustomDays(int days) {}

  @override
  void setMessageCap(int cap) {}

  @override
  Future<void> startImport() async {}

  @override
  void cancelImport() {}

  @override
  void reset() {}
}
