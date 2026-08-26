import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_ingestion/application/import_sms_history.dart';
import 'package:money_sync/features/sms_ingestion/presentation/history_import_controller.dart';

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async {
          final db = AppDatabase.inMemoryForTesting();
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Let the async _loadTrackedSenders complete before the test ends.
  Future<void> settleController(ProviderContainer c) async {
    c.read(historyImportProvider.notifier);
    // Give the async _loadTrackedSenders a chance to complete.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  group('HistoryImportState', () {
    test('windowDays returns preset when customDays is null', () {
      const state = HistoryImportState(preset: 7, customDays: null);
      expect(state.windowDays, 7);
    });

    test('windowDays returns customDays when set', () {
      const state = HistoryImportState(preset: 7, customDays: 30);
      expect(state.windowDays, 30);
    });

    test('copyWith preserves unmodified fields', () {
      final original = HistoryImportState(
        preset: 3,
        customDays: 5,
        messageCap: 200,
        trackedSenders: const ['SENDER_A'],
        isScanning: true,
        imported: 10,
        filtered: 2,
        duplicates: 1,
        terminalResult: TerminalResult.completed,
      );
      final copy = original.copyWith(preset: 14);
      expect(copy.preset, 14);
      expect(copy.customDays, 5);
      expect(copy.messageCap, 200);
      expect(copy.trackedSenders, ['SENDER_A']);
      expect(copy.isScanning, isTrue);
      expect(copy.imported, 10);
      expect(copy.filtered, 2);
      expect(copy.duplicates, 1);
      expect(copy.terminalResult, TerminalResult.completed);
    });

    test('copyWith replaces terminalResult', () {
      const state = HistoryImportState();
      final copy = state.copyWith(terminalResult: TerminalResult.error);
      expect(copy.terminalResult, TerminalResult.error);
    });

    test('initial state has expected defaults', () {
      final state = HistoryImportState.initial();
      expect(state.preset, 7);
      expect(state.customDays, isNull);
      expect(state.messageCap, 100);
      expect(state.trackedSenders, isEmpty);
      expect(state.isScanning, isFalse);
      expect(state.imported, 0);
      expect(state.filtered, 0);
      expect(state.duplicates, 0);
      expect(state.terminalResult, isNull);
    });
  });

  group('HistoryImportController', () {
    test('build returns initial state and loads tracked senders', () async {
      final container = createContainer();
      await settleController(container);
      final state = container.read(historyImportProvider);

      expect(state.preset, 7);
      expect(state.customDays, isNull);
      expect(state.messageCap, 100);
      expect(state.trackedSenders, isEmpty);
      expect(state.isScanning, isFalse);
    });

    test('selectPreset updates preset and clears customDays', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.selectPreset(14);
      final state = container.read(historyImportProvider);
      expect(state.preset, 14);
      expect(state.customDays, isNull);
    });

    test('selectPreset clears previously set customDays', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setCustomDays(30);
      expect(container.read(historyImportProvider).customDays, 30);

      notifier.selectPreset(3);
      final state = container.read(historyImportProvider);
      expect(state.preset, 3);
      expect(state.customDays, isNull);
    });

    test('setCustomDays clamps to min 1', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setCustomDays(-5);
      expect(container.read(historyImportProvider).customDays, 1);
    });

    test('setCustomDays clamps to max 90', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setCustomDays(200);
      expect(container.read(historyImportProvider).customDays, 90);
    });

    test('setCustomDays preserves value within range', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setCustomDays(21);
      expect(container.read(historyImportProvider).customDays, 21);
    });

    test('setMessageCap clamps to min 1', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setMessageCap(-10);
      expect(container.read(historyImportProvider).messageCap, 1);
    });

    test('setMessageCap clamps to hardCap', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setMessageCap(1000);
      expect(
        container.read(historyImportProvider).messageCap,
        ImportSmsHistory.hardCap,
      );
    });

    test('setMessageCap preserves value within range', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.setMessageCap(250);
      expect(container.read(historyImportProvider).messageCap, 250);
    });

    test('reset returns to initial state and reloads senders', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      notifier.selectPreset(14);
      notifier.setCustomDays(30);
      notifier.setMessageCap(300);
      expect(container.read(historyImportProvider).preset, 14);
      expect(container.read(historyImportProvider).customDays, 30);

      notifier.reset();
      // Let the async _loadTrackedSenders triggered by reset() complete.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(historyImportProvider);
      expect(state.preset, 7);
      expect(state.customDays, isNull);
      expect(state.messageCap, 100);
      expect(state.isScanning, isFalse);
      expect(state.terminalResult, isNull);
    });

    test('startImport with empty trackedSenders sets terminalResult', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      expect(container.read(historyImportProvider).trackedSenders, isEmpty);
      await notifier.startImport();
      final state = container.read(historyImportProvider);

      expect(state.terminalResult, TerminalResult.noTrackedSenders);
      expect(state.isScanning, isFalse);
    });

    test('startImport sets terminalResult.error when registry fails', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            final db = AppDatabase.inMemoryForTesting();
            ref.onDispose(db.close);
            return db;
          }),
          rulePackRegistryProvider.overrideWith((ref) async {
            throw StateError('registry unavailable');
          }),
        ],
      );
      addTearDown(container.dispose);
      await container.read(appDatabaseProvider.future);
      final db = await container.read(appDatabaseProvider.future);
      // Insert a tracked sender so the early-return path is skipped.
      await db
          .into(db.trackedSenders)
          .insert(
            TrackedSendersCompanion.insert(
              senderKey: 'SENDER_A',
              addedAtEpochMs: 1000,
            ),
          );
      final notifier = container.read(historyImportProvider.notifier);
      // Let the initial _loadTrackedSenders complete.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(historyImportProvider).trackedSenders,
        contains('SENDER_A'),
      );
      await notifier.startImport();
      // Let the async registry read complete.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final state = container.read(historyImportProvider);

      expect(state.terminalResult, TerminalResult.error);
      expect(state.isScanning, isFalse);
    });

    test('reloadTrackedSenders reloads from database', () async {
      final container = createContainer();
      await settleController(container);
      final notifier = container.read(historyImportProvider.notifier);

      expect(container.read(historyImportProvider).trackedSenders, isEmpty);

      // Insert a tracked sender into the database.
      final db = await container.read(appDatabaseProvider.future);
      await db
          .into(db.trackedSenders)
          .insert(
            TrackedSendersCompanion.insert(
              senderKey: 'BANKNEW',
              addedAtEpochMs: 1000,
            ),
          );

      await notifier.reloadTrackedSenders();
      // Let the async load complete.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(historyImportProvider).trackedSenders,
        contains('BANKNEW'),
      );
    });
  });
}
