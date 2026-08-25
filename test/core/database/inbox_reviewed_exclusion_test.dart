import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

/// M5.22 WP-D. A reviewed message must leave the inbox on *every* read path.
///
/// The exclusion previously lived in the inbox stream and filtered only the
/// first page, so reviewed messages reappeared under "Show all". It now lives
/// in the shared `_smsEventsSelect`, so the paginated reads inherit it.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.inMemoryForTesting());
  tearDown(() => db.close());

  Future<int> seedEvent(int receivedAt) async {
    return db
        .into(db.smsEvents)
        .insert(
          SmsEventsCompanion.insert(
            sourceKey: 'source-$receivedAt',
            senderKey: 'BANK ALPHA',
            ingestionSource: 'manual_paste',
            receivedAtEpochMs: receivedAt,
            status: SmsEventStatus.review,
            privacyEpoch: 0,
          ),
        );
  }

  Future<void> markReviewed(int smsEventId) async {
    await db
        .into(db.transactionCandidates)
        .insert(
          TransactionCandidatesCompanion.insert(
            smsEventId: smsEventId,
            state: CandidateRecordState.retainedLocal,
            encryptedPayload: '{}',
            revision: 1,
            createdAtEpochMs: 1_700_000_000_000,
          ),
        );
  }

  test('a reviewed message is absent from the live first page', () async {
    final kept = await seedEvent(1_700_000_002_000);
    final reviewed = await seedEvent(1_700_000_001_000);
    await markReviewed(reviewed);

    final page = await db.smsEventsPage(limit: 25);
    expect(page.map((e) => e.id), contains(kept));
    expect(page.map((e) => e.id), isNot(contains(reviewed)));
  });

  test('a reviewed message is absent from a paginated page too', () async {
    // Three events; page size 1 forces the cursor path that "Show all" uses.
    final newest = await seedEvent(1_700_000_003_000);
    final reviewed = await seedEvent(1_700_000_002_000);
    final oldest = await seedEvent(1_700_000_001_000);
    await markReviewed(reviewed);

    final first = await db.smsEventsPage(limit: 1);
    expect(first.single.id, newest);

    // The next page must skip the reviewed row entirely, not surface it.
    final second = await db.smsEventsPage(
      limit: 1,
      beforeReceivedAtEpochMs: first.single.receivedAtEpochMs,
      beforeId: first.single.id,
    );
    expect(
      second.single.id,
      oldest,
      reason: 'the reviewed message must not reappear when paging',
    );
  });

  test('a candidate still needing review stays in the inbox', () async {
    final pending = await seedEvent(1_700_000_001_000);
    await db
        .into(db.transactionCandidates)
        .insert(
          TransactionCandidatesCompanion.insert(
            smsEventId: pending,
            state: CandidateRecordState.needsReview,
            encryptedPayload: '{}',
            revision: 1,
            createdAtEpochMs: 1_700_000_000_000,
          ),
        );

    final page = await db.smsEventsPage(limit: 25);
    expect(page.map((e) => e.id), contains(pending));
  });
}
