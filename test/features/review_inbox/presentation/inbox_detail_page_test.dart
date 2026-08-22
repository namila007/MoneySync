import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_controller.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_detail_page.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_page.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

const _candidatePayload =
    '{"kind":"income","direction":"credit","lifecycle":"posted",'
    '"amountMinor":500000,"amountCurrency":"LKR",'
    '"transactionAtUtc":"2026-08-14T04:30:00.000Z",'
    '"confidenceBasisPoints":9600,"requiresReview":false}';

(Widget, ProviderContainer) _app(
  List<SmsEventsCompanion> events, {
  Future<void> Function(AppDatabase db)? seedCandidates,
}) {
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) async {
        final db = AppDatabase.inMemoryForTesting();
        ref.onDispose(db.close);
        for (final event in events) {
          await db.into(db.smsEvents).insert(event);
        }
        await seedCandidates?.call(db);
        return db;
      }),
      inboxViewProvider.overrideWith(InboxViewController.new),
      walletCatalogProvider.overrideWith((ref) async => null),
      mappingRuleListProvider.overrideWith((ref) async => []),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/inbox',
    routes: [
      GoRoute(path: '/inbox', builder: (context, state) => const InboxPage()),
      GoRoute(
        path: '/inbox/detail/:id',
        builder: (context, state) =>
            InboxDetailPage(smsEventId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );

  final widget = UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
  return (widget, container);
}

SmsEventsCompanion _event(
  int i, {
  String senderKey = 'SENDER_A',
  String? senderDisplay,
  int receivedAtEpochMs = 1000,
  bool hasFullBody = true,
}) {
  return SmsEventsCompanion.insert(
    sourceKey: 'k$i',
    senderKey: senderKey,
    senderDisplay: Value(senderDisplay),
    ingestionSource: 'history_selection',
    receivedAtEpochMs: receivedAtEpochMs,
    status: SmsEventStatus.review,
    privacyEpoch: 0,
    encryptedBody: hasFullBody ? Value('full body $i') : const Value(null),
    redactedBody: Value('redacted body $i'),
  );
}

Future<void> _seedCandidate(AppDatabase db) async {
  final event = await (db.select(
    db.smsEvents,
  )..where((t) => t.sourceKey.equals('k0'))).getSingle();
  await db
      .into(db.transactionCandidates)
      .insert(
        TransactionCandidatesCompanion.insert(
          smsEventId: event.id,
          state: CandidateRecordState.needsReview,
          encryptedPayload: _candidatePayload,
          revision: 1,
          createdAtEpochMs: 1000,
        ),
      );
}

void main() {
  testWidgets('tapping an inbox row opens the message detail', (tester) async {
    final (widget, _) = _app([
      _event(0, senderKey: 'SENDER_A', senderDisplay: 'BANKX'),
      _event(1, senderKey: 'SENDER_A'),
    ]);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('full body 1'));
    await tester.pumpAndSettle();

    expect(find.text('Message'), findsOneWidget);
    expect(find.text('full body 1'), findsOneWidget);
    expect(find.textContaining('SENDER_A ·'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
  });

  testWidgets('detail shows the body, sender and status chip', (tester) async {
    final (widget, _) = _app([
      _event(0, senderKey: 'SENDER_A', senderDisplay: 'BANKX'),
    ]);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('full body 0'));
    await tester.pumpAndSettle();

    expect(find.text('BANKX'), findsOneWidget);
    expect(find.text('full body 0'), findsOneWidget);
    expect(find.text('redacted body 0'), findsNothing);
    expect(find.text('Review'), findsOneWidget); // status chip label
  });

  testWidgets(
    'detail falls back to the masked preview when the body is purged',
    (tester) async {
      final (widget, _) = _app([
        _event(
          0,
          senderKey: 'SENDER_A',
          senderDisplay: 'BANKX',
          hasFullBody: false,
        ),
      ]);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('redacted body 0'));
      await tester.pumpAndSettle();

      expect(find.text('redacted body 0'), findsOneWidget);
      expect(find.text('full body 0'), findsNothing);
      expect(find.text('(no body)'), findsNothing);
    },
  );

  testWidgets('detail shows (no body) when both body and preview are absent', (
    tester,
  ) async {
    final (widget, _) = _app([
      SmsEventsCompanion.insert(
        sourceKey: 'k0',
        senderKey: 'SENDER_A',
        senderDisplay: const Value(null),
        ingestionSource: 'history_selection',
        receivedAtEpochMs: 1000,
        status: SmsEventStatus.review,
        privacyEpoch: 0,
        encryptedBody: const Value(null),
        redactedBody: const Value(null),
      ),
    ]);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('(no body)'));
    await tester.pumpAndSettle();

    expect(find.text('(no body)'), findsOneWidget);
  });

  testWidgets(
    'detail with a candidate shows the summary card and Detail sheet',
    (tester) async {
      final (widget, _) = _app([
        _event(0, senderKey: 'SENDER_A', senderDisplay: 'BANKX'),
      ], seedCandidates: _seedCandidate);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('full body 0'));
      await tester.pumpAndSettle();

      expect(find.text('Candidate summary'), findsOneWidget);
      expect(find.text('Amount: LKR 5000.00'), findsOneWidget);
      expect(find.text('Confidence: 96%'), findsOneWidget);

      await tester.tap(find.text('Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Candidate detail'), findsOneWidget);
      expect(find.text('Kind: income'), findsOneWidget);
      expect(find.text('Direction: credit'), findsOneWidget);
    },
  );

  testWidgets('detail without a candidate hides the candidate card', (
    tester,
  ) async {
    final (widget, _) = _app([
      _event(0, senderKey: 'SENDER_A', senderDisplay: 'BANKX'),
    ]);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('full body 0'));
    await tester.pumpAndSettle();

    expect(find.text('Candidate summary'), findsNothing);
    expect(find.text('Review'), findsOneWidget); // status chip only
  });

  testWidgets('detail of a deleted message shows not-found', (tester) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: InboxDetailPage(smsEventId: 404)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Message not found.'), findsOneWidget);
  });

  test('candidate summary parse tolerates malformed payloads', () {
    expect(CandidateSummaryView.parse(_candidatePayload)?.amountMinor, 500000);
    expect(CandidateSummaryView.parse('not-json'), isNull);
    expect(CandidateSummaryView.parse('{"amountMinor":"x"}'), isNull);
  });
}
