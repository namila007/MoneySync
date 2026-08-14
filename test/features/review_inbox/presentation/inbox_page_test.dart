import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_controller.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_page.dart';

(Widget, ProviderContainer) _appWithEvents(List<SmsEventsCompanion> events) {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) async {
        final db = AppDatabase.inMemoryForTesting();
        ref.onDispose(db.close);
        for (final event in events) {
          await db.into(db.smsEvents).insert(event);
        }
        return db;
      }),
      inboxViewProvider.overrideWith(InboxViewController.new),
    ],
  );
  addTearDown(container.dispose);
  final widget = UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: InboxPage()),
  );
  return (widget, container);
}

SmsEventsCompanion _event(
  int i, {
  String senderKey = 'SENDER_A',
  String? senderDisplay,
  int receivedAtEpochMs = 1000,
}) {
  return SmsEventsCompanion.insert(
    sourceKey: 'k$i',
    senderKey: senderKey,
    senderDisplay: Value(senderDisplay),
    ingestionSource: 'history_selection',
    receivedAtEpochMs: receivedAtEpochMs,
    status: SmsEventStatus.review,
    privacyEpoch: 0,
    encryptedBody: Value('full body $i'),
    redactedBody: Value('redacted body $i'),
  );
}

Future<ProviderContainer> _pumpEvents(
  WidgetTester tester,
  List<SmsEventsCompanion> events,
) async {
  final (widget, container) = _appWithEvents(events);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('grouped layout caps each sender at 5 with a truthful Show all', (
    tester,
  ) async {
    await _pumpEvents(tester, [
      for (var i = 0; i < 6; i++) _event(i, senderKey: 'SENDER_A'),
      for (var i = 6; i < 8; i++) _event(i, senderKey: 'SENDER_B'),
    ]);

    await tester.scrollUntilVisible(
      find.text('Show all (6)'),
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Show all (6)'), findsOneWidget);
    expect(find.text('Show all (2)'), findsNothing);

    await tester.tap(find.text('Show all (6)'));
    await tester.pumpAndSettle();

    expect(find.text('Show all (6)'), findsNothing);
    expect(find.text('full body 0'), findsOneWidget);
  });

  testWidgets('grouped headers show the display form, never the key', (
    tester,
  ) async {
    await _pumpEvents(tester, [
      _event(0, senderKey: 'SENDER_A', senderDisplay: 'SAMPATHTX'),
    ]);

    await tester.pumpAndSettle();
    expect(find.text('SAMPATHTX'), findsWidgets);
  });

  testWidgets('M4.16 inbox row shows the full original body, not the masked '
      'preview', (tester) async {
    await _pumpEvents(tester, [_event(0)]);

    expect(find.text('full body 0'), findsOneWidget);
    expect(find.text('redacted body 0'), findsNothing);
  });

  testWidgets('M4.16 inbox row falls back to the masked preview when the body '
      'is purged', (tester) async {
    await _pumpEvents(tester, [
      SmsEventsCompanion.insert(
        sourceKey: 'k0',
        senderKey: 'SENDER_A',
        senderDisplay: const Value(null),
        ingestionSource: 'history_selection',
        receivedAtEpochMs: 1000,
        status: SmsEventStatus.review,
        privacyEpoch: 0,
        encryptedBody: const Value(null),
        redactedBody: const Value('redacted body 0'),
      ),
    ]);

    expect(find.text('redacted body 0'), findsOneWidget);
    expect(find.text('(no body)'), findsNothing);
  });

  testWidgets('layout toggle switches to flat newest-first', (tester) async {
    await _pumpEvents(tester, [
      for (var i = 0; i < 6; i++) _event(i, senderKey: 'SENDER_A'),
      for (var i = 6; i < 8; i++) _event(i, senderKey: 'SENDER_B'),
    ]);

    await tester.tap(find.byTooltip('Switch to flat list'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch to grouped by sender'), findsOneWidget);
    expect(find.textContaining('SENDER_A '), findsWidgets);
  });

  testWidgets('delete swipe shows confirm and deletes the message', (
    tester,
  ) async {
    await _pumpEvents(tester, [for (var i = 0; i < 8; i++) _event(i)]);

    await tester.drag(find.text('full body 7'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete this imported message?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('full body 7'), findsNothing);
  });

  testWidgets('empty inbox is pull-to-refreshable', (tester) async {
    await _pumpEvents(tester, const []);

    expect(find.textContaining('No transaction candidates'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.textContaining('No transaction candidates'), findsOneWidget);
  });

  testWidgets('renders rows inserted after the first build', (tester) async {
    final container = await _pumpEvents(tester, const []);

    expect(find.textContaining('No transaction candidates'), findsOneWidget);

    final db = await container.read(appDatabaseProvider.future);
    await db
        .into(db.smsEvents)
        .insert(_event(1, senderKey: 'SENDER_A', receivedAtEpochMs: 5000));
    await tester.pumpAndSettle();

    expect(find.text('full body 1'), findsOneWidget);
    expect(find.textContaining('No transaction candidates'), findsNothing);
  });

  testWidgets('flat list loads a second page on scroll', (tester) async {
    final container = await _pumpEvents(tester, [
      for (var i = 0; i < 30; i++) _event(i, receivedAtEpochMs: 1000 + i),
    ]);

    await tester.tap(find.byTooltip('Switch to flat list'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();

    final view = container.read(inboxViewProvider);
    expect(view.flatMore, hasLength(5));
    expect(view.flatHasMore, isFalse);

    await tester.scrollUntilVisible(
      find.text('full body 0'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('full body 0'), findsOneWidget);
  });

  testWidgets('Show all loads more for that sender only', (tester) async {
    final container = await _pumpEvents(tester, [
      for (var i = 0; i < 3; i++)
        _event(i, senderKey: 'SENDER_B', receivedAtEpochMs: 1000 + i),
      for (var i = 3; i < 63; i++)
        _event(i, senderKey: 'SENDER_A', receivedAtEpochMs: 1000 + i),
    ]);

    await tester.scrollUntilVisible(
      find.text('Show all (60)'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Show all (60)'));
    await tester.pumpAndSettle();

    expect(
      container.read(inboxViewProvider).senderMore['SENDER_A'],
      hasLength(25),
    );
    expect(
      container.read(inboxViewProvider).senderMore.containsKey('SENDER_B'),
      isFalse,
    );

    await tester.scrollUntilVisible(
      find.text('Show all (60)'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Show all (60)'), findsOneWidget);

    await tester.tap(find.text('Show all (60)'));
    await tester.pumpAndSettle();

    expect(
      container.read(inboxViewProvider).senderMore['SENDER_A'],
      hasLength(35),
    );
    expect(find.text('Show all (60)'), findsNothing);
  });

  group('M4.15 WP2 inbox filters', () {
    testWidgets('sender dropdown filters rows and clear restores', (
      tester,
    ) async {
      await _pumpEvents(tester, [
        _event(0, senderKey: 'SENDER_A', senderDisplay: 'BANK A'),
        _event(1, senderKey: 'SENDER_B', senderDisplay: 'BANK B'),
      ]);

      expect(find.text('full body 0'), findsOneWidget);
      expect(find.text('full body 1'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BANK B').last);
      await tester.pumpAndSettle();

      expect(find.text('full body 0'), findsNothing);
      expect(find.text('full body 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('full body 0'), findsOneWidget);
      expect(find.text('full body 1'), findsOneWidget);
    });

    testWidgets('date range filter shows only in-range rows', (tester) async {
      await _pumpEvents(tester, [
        _event(
          0,
          receivedAtEpochMs: DateTime.utc(2026, 8, 10).millisecondsSinceEpoch,
        ),
        _event(
          1,
          receivedAtEpochMs: DateTime.utc(2026, 8, 20).millisecondsSinceEpoch,
        ),
      ]);

      final container = tester.element(find.byType(InboxPage));
      final controller = ProviderScope.containerOf(
        container,
      ).read(inboxViewProvider.notifier);
      controller.setDateRangeFilter(
        DateTimeRange(start: DateTime(2026, 8, 9), end: DateTime(2026, 8, 11)),
      );
      await tester.pumpAndSettle();

      expect(find.text('full body 0'), findsOneWidget);
      expect(find.text('full body 1'), findsNothing);
      expect(find.textContaining('9/8/2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('full body 1'), findsOneWidget);
      expect(find.text('Any date'), findsOneWidget);
    });

    testWidgets('date chip opens the Material range picker', (tester) async {
      await _pumpEvents(tester, [_event(0)]);

      await tester.tap(find.byIcon(Icons.date_range_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Filter messages by received date'), findsOneWidget);

      Navigator.of(
        tester.element(find.text('Filter messages by received date')),
      ).pop();
      await tester.pumpAndSettle();
    });

    testWidgets('filtered flat paging loads only matching senders', (
      tester,
    ) async {
      final container = await _pumpEvents(tester, [
        for (var i = 0; i < 30; i++)
          _event(i, senderKey: 'SENDER_A', receivedAtEpochMs: 1000 + i),
        for (var i = 30; i < 60; i++)
          _event(i, senderKey: 'SENDER_B', receivedAtEpochMs: 1000 + i),
      ]);

      container.read(inboxViewProvider.notifier).setSenderFilter('SENDER_A');
      await tester.pumpAndSettle();

      expect(find.text('full body 29'), findsOneWidget);
      expect(find.text('full body 59'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      final view = container.read(inboxViewProvider);
      expect(view.flatMore, hasLength(5));
      expect(view.flatMore.every((e) => e.senderKey == 'SENDER_A'), isTrue);
    });
  });
}
