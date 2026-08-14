import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/transaction_parser/data/rule_packs/lk/lk_sampath_account_v1.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

import '../../../helpers/fake_identity_signer.dart';

void main() {
  group('IngestManualMessage interpretation hook', () {
    test(
      'stored financial message creates a candidate and activity event',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final ingest = IngestManualMessage(
          database: db,
          identitySigner: fakeIdentitySigner(),
          interpret:
              ({
                required rawBody,
                required sender,
                required receivedAtUtc,
              }) async => InterpretMessage(
                registry: RulePackRegistry(packs: [lkSampathAccountV1]),
              )(rawBody: rawBody, sender: sender, receivedAtUtc: receivedAtUtc),
        );

        final outcome = await ingest(
          rawBody:
              'LKR 1,500.00 debited from AC **6126 for SYNTHETIC CAFE '
              'Avl Bal: LKR 48,500.00',
          rawSender: 'SAMPATHTX',
          source: IngestionSource.manualPaste,
          userOverrodeFilter: false,
          epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
          privacyEpoch: 0,
        );

        expect(outcome, isA<ManualIngestStored>());

        final candidates = await db.select(db.transactionCandidates).get();
        expect(candidates.length, 1);
        expect(candidates.first.state, CandidateRecordState.needsReview);
        expect(candidates.first.encryptedPayload, contains('"kind":"expense"'));

        final traces = await db.select(db.decisionTraces).get();
        expect(traces.length, 1);
        expect(traces.first.traceCode, DecisionTraceCode.parsedComplete);

        final activities = await db.select(db.activityEvents).get();
        expect(activities.length, 2);
        expect(
          activities.map((a) => a.eventType),
          containsAll([
            ActivityEventCode.messageImported,
            ActivityEventCode.candidateNeedsReview,
          ]),
        );
      },
    );

    test('OTP message stores no candidate', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final ingest = IngestManualMessage(
        database: db,
        identitySigner: fakeIdentitySigner(),
        interpret:
            ({
              required rawBody,
              required sender,
              required receivedAtUtc,
            }) async => InterpretMessage(
              registry: RulePackRegistry(packs: [lkSampathAccountV1]),
            )(rawBody: rawBody, sender: sender, receivedAtUtc: receivedAtUtc),
      );

      final outcome = await ingest(
        rawBody: 'Your Sampath OTP is 482913. Do not share.',
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );

      expect(outcome, isA<ManualIngestFiltered>());
      final candidates = await db.select(db.transactionCandidates).get();
      expect(candidates, isEmpty);
    });
  });

  group('IngestManualMessage identity (M4.14 WP4)', () {
    const body =
        'LKR 1,000.00 debited from AC **6126 for SYNTHETIC STORE '
        'Avl Bal: LKR 49,000.00';

    test('the same message via paste and via history yields one row', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final ingest = IngestManualMessage(
        database: db,
        identitySigner: fakeIdentitySigner(),
      );
      final epoch = DateTime.utc(2026, 8, 12, 9, 30).millisecondsSinceEpoch;

      final pasted = await ingest(
        rawBody: body,
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: epoch,
        privacyEpoch: 0,
      );
      final fromHistory = await ingest(
        rawBody: body,
        rawSender: 'SAMPATHTX',
        source: IngestionSource.historySelection,
        userOverrodeFilter: false,
        epochMs: epoch,
        privacyEpoch: 0,
      );

      expect(pasted, isA<ManualIngestStored>());
      expect(fromHistory, isA<ManualIngestAlreadyPresent>());
      expect(await db.select(db.smsEvents).get(), hasLength(1));
    });

    test(
      'capture canonicalization version 2 is recorded on every row',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);
        final ingest = IngestManualMessage(
          database: db,
          identitySigner: fakeIdentitySigner(),
        );

        final outcome = await ingest(
          rawBody: body,
          rawSender: 'SAMPATHTX',
          source: IngestionSource.manualPaste,
          userOverrodeFilter: false,
          epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
          privacyEpoch: 0,
        );

        expect(outcome, isA<ManualIngestStored>());
        final event = await db.select(db.smsEvents).getSingle();
        expect(event.captureCanonicalizationVersion, 2);
        expect(event.sourceKey, startsWith('v2_'));
        expect(event.senderDisplay, 'SAMPATHTX');
      },
    );

    test(
      'content hash flags a duplicate for review but never blocks an insert',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);
        final ingest = IngestManualMessage(
          database: db,
          identitySigner: fakeIdentitySigner(),
        );

        final first = await ingest(
          rawBody: body,
          rawSender: 'SAMPATHTX',
          source: IngestionSource.manualPaste,
          userOverrodeFilter: false,
          epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
          privacyEpoch: 0,
        );
        final second = await ingest(
          rawBody: body,
          rawSender: 'SAMPATHTX',
          source: IngestionSource.manualPaste,
          userOverrodeFilter: false,
          epochMs: DateTime.utc(2026, 8, 13).millisecondsSinceEpoch,
          privacyEpoch: 0,
        );

        final firstStored = first as ManualIngestStored;
        final secondStored = second as ManualIngestStored;
        expect(firstStored.duplicateSuspected, isFalse);
        expect(secondStored.duplicateSuspected, isTrue);
        expect(firstStored.eventId, isNot(secondStored.eventId));
        expect(await db.select(db.smsEvents).get(), hasLength(2));
      },
    );
  });
}
