import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

void main() {
  group('v5 constraints', () {
    test('two events with same source_key but different provider_row_id '
        'insert the first only', () async {
      final db = AppDatabase.inMemoryForTesting();
      final resultA = await db.insertSmsEventIfAbsent(
        sourceKey: 'hash-abc',
        senderHash: 'sender-1',
        encryptedBody: 'body-a',
        ingestionSource: 'history_selection',
        receivedAtEpochMs: 1000,
        status: 'pending',
        privacyEpoch: 0,
      );
      expect(resultA.inserted, isTrue);

      final resultB = await db.insertSmsEventIfAbsent(
        sourceKey: 'hash-abc',
        senderHash: 'sender-1',
        encryptedBody: 'body-b',
        ingestionSource: 'history_selection',
        receivedAtEpochMs: 2000,
        status: 'pending',
        privacyEpoch: 0,
      );
      expect(resultB.inserted, isFalse);
      expect(resultB.id, resultA.id);
    });

    test('no money column has SQL type REAL', () async {
      final db = AppDatabase.inMemoryForTesting();
      final rows = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type='table' "
            "AND name IN ('transaction_candidates', 'sms_events')",
          )
          .get();

      for (final row in rows) {
        final sql = (row.data['sql'] as String).toLowerCase();
        expect(
          sql,
          isNot(contains('real')),
          reason: 'No money column may be REAL: $sql',
        );
      }
    });

    test('appending CandidateRecordState values preserves stored names', () {
      expect(CandidateRecordState.needsReview.name, 'needsReview');
      expect(CandidateRecordState.ignored.name, 'ignored');
      expect(CandidateRecordState.retainedLocal.name, 'retainedLocal');
      expect(CandidateRecordState.superseded.name, 'superseded');
    });

    test('appending DecisionTraceCode values preserves stored names', () {
      expect(DecisionTraceCode.initialReview.name, 'initialReview');
      expect(
        DecisionTraceCode.filteredNonTransaction.name,
        'filteredNonTransaction',
      );
      expect(DecisionTraceCode.filteredOtp.name, 'filteredOtp');
      expect(DecisionTraceCode.filteredPromotional.name, 'filteredPromotional');
    });

    test('rawPurgeState defaults to pending for pre-v5 rows', () async {
      final db = AppDatabase.inMemoryForTesting();
      final result = await db.insertSmsEventIfAbsent(
        sourceKey: 'hash-xyz',
        senderHash: 'sender-x',
        ingestionSource: 'manual_paste',
        receivedAtEpochMs: 1000,
        status: 'review',
        privacyEpoch: 0,
      );
      final event = await (db.select(
        db.smsEvents,
      )..where((row) => row.id.equals(result.id))).getSingle();
      expect(event.rawPurgeState, RawPurgeState.pending);
    });
  });
}
