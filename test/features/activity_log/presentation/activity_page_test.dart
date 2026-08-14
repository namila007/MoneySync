import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/activity_log/presentation/activity_page.dart';

ActivityLogEntry _entry({
  required int id,
  required ActivityEventCode code,
  required ActivityStateTransition detail,
  required int epochMs,
  int? count,
}) {
  return ActivityLogEntry(
    id: id,
    code: code,
    detail: detail,
    occurredAt: DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true),
    privacyEpoch: 0,
    count: count,
  );
}

Widget _app(List<ActivityLogEntry> entries) {
  return ProviderScope(
    overrides: [
      activityLogRepositoryProvider.overrideWith(
        (ref) async => _FakeRepo(entries),
      ),
    ],
    child: const MaterialApp(home: ActivityPage()),
  );
}

void main() {
  group('ActivityPage', () {
    testWidgets('shows an empty state when there is no activity', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const []));
      await tester.pumpAndSettle();

      expect(find.textContaining('No activity yet'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders one tile per entry with readable labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app([
          _entry(
            id: 2,
            code: ActivityEventCode.privacyEpochAdvanced,
            detail: ActivityStateTransition.privacyEpochAdvanced,
            epochMs: 2000,
          ),
          _entry(
            id: 1,
            code: ActivityEventCode.rawCopyPurged,
            detail: ActivityStateTransition.rawCopyPurged,
            epochMs: 1000,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Local data cleared'), findsOneWidget);
      expect(find.text('Message copy removed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders every event code without a missing-case failure', (
      tester,
    ) async {
      var id = 0;
      await tester.pumpWidget(
        _app([
          for (final code in ActivityEventCode.values)
            _entry(
              id: id++,
              code: code,
              detail: ActivityStateTransition.logEvent,
              epochMs: 1000 * id,
            ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'aggregated import event tile shows the batch count (M4.15 WP3)',
      (tester) async {
        await tester.pumpWidget(
          _app([
            _entry(
              id: 1,
              code: ActivityEventCode.messageImported,
              detail: ActivityStateTransition.logEvent,
              epochMs: 1000,
              count: 20,
            ),
            _entry(
              id: 2,
              code: ActivityEventCode.messageImported,
              detail: ActivityStateTransition.logEvent,
              epochMs: 2000,
            ),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.text('20 messages imported'), findsOneWidget);
        expect(find.text('Message imported'), findsOneWidget);
      },
    );

    testWidgets('surfaces a safe message when the read fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityLogRepositoryProvider.overrideWith(
              (ref) async => _FailingRepo(),
            ),
          ],
          child: const MaterialApp(home: ActivityPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('could not be read'), findsOneWidget);
    });
  });
}

final class _FakeRepo implements ActivityLogRepository {
  const _FakeRepo(this.entries);

  final List<ActivityLogEntry> entries;

  @override
  Future<List<ActivityLogEntry>> recent({int limit = 200}) async => entries;
}

final class _FailingRepo implements ActivityLogRepository {
  @override
  Future<List<ActivityLogEntry>> recent({int limit = 200}) async =>
      throw StateError('database unavailable');
}
