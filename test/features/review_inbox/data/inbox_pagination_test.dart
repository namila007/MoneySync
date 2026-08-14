import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

/// Keyset pagination proofs (M4.14 WP2): identical timestamps and inserts
/// arriving mid-scroll must never duplicate or skip a row.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
  });

  tearDown(() => db.close());

  Future<void> seed(
    int count, {
    int receivedAtEpochMs = 1000,
    String senderKey = 'SENDER',
    String sourcePrefix = '',
  }) async {
    for (var i = 0; i < count; i++) {
      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: '$sourcePrefix$senderKey-$i',
              senderKey: senderKey,
              ingestionSource: 'history_selection',
              receivedAtEpochMs: receivedAtEpochMs,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
              redactedBody: Value('body $i'),
            ),
          );
    }
  }

  test('first page returns the newest rows in newest-first order', () async {
    await seed(30, receivedAtEpochMs: 1000);

    final page = await db.smsEventsPage(limit: 25);

    expect(page, hasLength(25));
    expect(page.first.id, 30);
    expect(page.last.id, 6);
    for (var i = 0; i < page.length - 1; i++) {
      expect(
        page[i].id,
        greaterThan(page[i + 1].id),
        reason: 'rows must be strictly newest-first',
      );
    }
  });

  test(
    'cursor page excludes the cursor row and returns the next window',
    () async {
      await seed(30, receivedAtEpochMs: 1000);
      final first = await db.smsEventsPage(limit: 25);

      final second = await db.smsEventsPage(
        limit: 25,
        beforeReceivedAtEpochMs: first.last.receivedAtEpochMs,
        beforeId: first.last.id,
      );

      expect(second.map((e) => e.id), isNot(contains(first.last.id)));
      expect(second.map((e) => e.id).toSet(), {5, 4, 3, 2, 1});
    },
  );

  test(
    'rows with identical receivedAt are ordered and paged by id without repeats',
    () async {
      await seed(30, receivedAtEpochMs: 1234567890);

      final first = await db.smsEventsPage(limit: 25);
      final second = await db.smsEventsPage(
        limit: 25,
        beforeReceivedAtEpochMs: first.last.receivedAtEpochMs,
        beforeId: first.last.id,
      );

      expect(first, hasLength(25));
      expect(second, hasLength(5));
      final all = [...first, ...second];
      expect(all.map((e) => e.id).toSet(), hasLength(30));
      for (var i = 0; i < all.length - 1; i++) {
        expect(all[i].id, greaterThan(all[i + 1].id));
      }
    },
  );

  test(
    'inserting a newer row mid-pagination does not duplicate or skip',
    () async {
      await seed(30, receivedAtEpochMs: 1000);
      final first = await db.smsEventsPage(limit: 25);
      final cursor = first.last;

      // A live import lands a newer row while the user is deep in the list.
      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'newer',
              senderKey: 'SENDER',
              ingestionSource: 'history_selection',
              receivedAtEpochMs: 99999,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
            ),
          );

      // Cursor-anchored page is unaffected by the new top row.
      final second = await db.smsEventsPage(
        limit: 25,
        beforeReceivedAtEpochMs: cursor.receivedAtEpochMs,
        beforeId: cursor.id,
      );
      expect(second.map((e) => e.id).toSet(), {5, 4, 3, 2, 1});

      // And the merged view has no repeats and no gaps.
      final merged = [...first.map((e) => e.id), ...second.map((e) => e.id)];
      expect(merged.toSet(), hasLength(30));
    },
  );

  test('per-sender paging only returns rows for that sender', () async {
    await seed(20, receivedAtEpochMs: 1000, senderKey: 'SENDER_A');
    await seed(5, receivedAtEpochMs: 2000, senderKey: 'SENDER_B');

    final aPage = await db.smsEventsPage(limit: 10, senderKey: 'SENDER_A');
    expect(aPage, hasLength(10));
    expect(aPage.every((e) => e.senderKey == 'SENDER_A'), isTrue);
  });

  test(
    'sender summaries report the true total, not the loaded count',
    () async {
      await seed(40, receivedAtEpochMs: 1000, senderKey: 'SENDER_A');
      await seed(3, receivedAtEpochMs: 500, senderKey: 'SENDER_B');

      final summaries = await db.watchSmsEventSenderSummaries().first;

      expect(summaries, hasLength(2));
      expect(summaries.firstWhere((s) => s.senderKey == 'SENDER_A').total, 40);
      expect(summaries.firstWhere((s) => s.senderKey == 'SENDER_B').total, 3);
      expect(summaries.first.senderKey, 'SENDER_A');
    },
  );

  group('M4.15 WP2 date and sender filters', () {
    test('from/until bounds the window inclusive on both ends', () async {
      await seed(3, receivedAtEpochMs: 1000, sourcePrefix: 'a');
      await seed(3, receivedAtEpochMs: 2000, sourcePrefix: 'b');
      await seed(3, receivedAtEpochMs: 3000, sourcePrefix: 'c');

      final page = await db.smsEventsPage(
        limit: 50,
        fromReceivedAtEpochMs: 1000,
        untilReceivedAtEpochMs: 2000,
      );

      expect(page.map((e) => e.receivedAtEpochMs).toSet(), {1000, 2000});
    });

    test('sender and date filters combine', () async {
      await seed(
        2,
        receivedAtEpochMs: 1000,
        senderKey: 'SENDER_A',
        sourcePrefix: 'a',
      );
      await seed(
        2,
        receivedAtEpochMs: 1000,
        senderKey: 'SENDER_B',
        sourcePrefix: 'b',
      );
      await seed(
        2,
        receivedAtEpochMs: 3000,
        senderKey: 'SENDER_A',
        sourcePrefix: 'c',
      );

      final page = await db.smsEventsPage(
        limit: 50,
        senderKey: 'SENDER_A',
        fromReceivedAtEpochMs: 1500,
      );

      expect(page, hasLength(2));
      expect(page.every((e) => e.receivedAtEpochMs == 3000), isTrue);
    });

    test('filtered pages stay cursor-anchored', () async {
      await seed(
        30,
        receivedAtEpochMs: 1000,
        senderKey: 'SENDER_A',
        sourcePrefix: 'a',
      );
      await seed(
        5,
        receivedAtEpochMs: 2000,
        senderKey: 'SENDER_B',
        sourcePrefix: 'b',
      );

      final first = await db.smsEventsPage(
        limit: 25,
        senderKey: 'SENDER_A',
        fromReceivedAtEpochMs: 1000,
        untilReceivedAtEpochMs: 1000,
      );
      final second = await db.smsEventsPage(
        limit: 25,
        senderKey: 'SENDER_A',
        fromReceivedAtEpochMs: 1000,
        untilReceivedAtEpochMs: 1000,
        beforeReceivedAtEpochMs: first.last.receivedAtEpochMs,
        beforeId: first.last.id,
      );

      expect(first, hasLength(25));
      expect(second, hasLength(5));
      expect(second.map((e) => e.id).toSet(), isNot(contains(first.last.id)));
    });

    test('watch page honours the same filter window', () async {
      await seed(
        2,
        receivedAtEpochMs: 1000,
        senderKey: 'SENDER_A',
        sourcePrefix: 'a',
      );
      await seed(
        2,
        receivedAtEpochMs: 3000,
        senderKey: 'SENDER_A',
        sourcePrefix: 'b',
      );

      final page = await db
          .watchSmsEventsPage(
            limit: 25,
            senderKey: 'SENDER_A',
            fromReceivedAtEpochMs: 2500,
          )
          .first;

      expect(page, hasLength(2));
      expect(page.every((e) => e.receivedAtEpochMs == 3000), isTrue);
    });
  });
}
