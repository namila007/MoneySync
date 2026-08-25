import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/sms_ingestion/application/delete_imported_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

import '../../../helpers/fake_identity_signer.dart';

void main() {
  group('Content hash dedupe', () {
    String hashOf(String sender, String body) =>
        sha256.convert(utf8.encode('$sender|$body')).toString();

    test('same normalized (sender, body) yields the same hash', () {
      expect(
        hashOf('SAMPATH', 'LKR 100.00 debited'),
        hashOf('SAMPATH', 'LKR 100.00 debited'),
      );
      expect(
        hashOf('SAMPATH', 'LKR 100.00 debited'),
        isNot(hashOf('SAMPATH', 'LKR 200.00 debited')),
      );
    });

    // M4.14 WP4: the content hash is a review hint, never an identity —
    // identical bodies at different times are distinct transactions.
    test('identical-body messages at different times both store', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final ingest = IngestManualMessage(
        database: db,
        identitySigner: fakeIdentitySigner(),
      );

      final first = await ingest(
        rawBody:
            'LKR 1,000.00 debited from AC **6126 for SYNTHETIC STORE '
            'Avl Bal: LKR 49,000.00',
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );

      // Same content, different epoch (as if pasted again later).
      final second = await ingest(
        rawBody:
            'LKR 1,000.00 debited from AC **6126 for SYNTHETIC STORE '
            'Avl Bal: LKR 49,000.00',
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 13).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );

      expect(first, isA<ManualIngestStored>());
      expect(second, isA<ManualIngestStored>());
      final events = await db.select(db.smsEvents).get();
      expect(events.length, 2);
    });
  });

  group('Delete imported message', () {
    test('removes event, candidate, and traces; records activity', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final ingest = IngestManualMessage(
        database: db,
        identitySigner: fakeIdentitySigner(),
      );
      final outcome = await ingest(
        rawBody:
            'LKR 500.00 debited from AC **6126 for SYNTHETIC SHOP '
            'Avl Bal: LKR 49,500.00',
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );
      final eventId = (outcome as ManualIngestStored).eventId;

      // Give it a real candidate so the cascade is genuinely exercised.
      await db.insertCandidateAndActivityAtomically(
        smsEventId: eventId,
        candidateState: CandidateRecordState.needsReview,
        encryptedPayload: '{"kind":"expense"}',
        revision: 1,
        createdAtEpochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
        activityType: ActivityEventCode.candidateNeedsReview,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.parsedComplete,
        privacyEpoch: 0,
      );

      final useCase = DeleteImportedMessage(database: db);
      final result = await useCase(eventId: eventId, privacyEpoch: 0);

      expect(result, isA<DeleteMessageDeleted>());
      expect(await db.select(db.smsEvents).get(), isEmpty);
      expect(await db.select(db.transactionCandidates).get(), isEmpty);
      expect(await db.select(db.decisionTraces).get(), isEmpty);

      final activities = await db.select(db.activityEvents).get();
      expect(
        activities.map((a) => a.eventType),
        contains(ActivityEventCode.smsEventDeleted),
      );
    });

    test('blocked by stale privacy epoch', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final ingest = IngestManualMessage(
        database: db,
        identitySigner: fakeIdentitySigner(),
      );
      final outcome = await ingest(
        rawBody:
            'LKR 500.00 debited from AC **6126 for SYNTHETIC SHOP '
            'Avl Bal: LKR 49,500.00',
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );
      final eventId = (outcome as ManualIngestStored).eventId;

      await db.advancePrivacyEpoch(expectedCurrent: 0);
      final useCase = DeleteImportedMessage(database: db);
      final result = await useCase(eventId: eventId, privacyEpoch: 0);

      expect(result, isA<DeleteMessageBlockedByEpoch>());
      expect(await db.select(db.smsEvents).get(), hasLength(1));
    });

    test('deleted message can be re-imported', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final ingest = IngestManualMessage(
        database: db,
        identitySigner: fakeIdentitySigner(),
      );
      const body =
          'LKR 250.00 debited from AC **6126 for SYNTHETIC CAFE '
          'Avl Bal: LKR 49,750.00';

      final first = await ingest(
        rawBody: body,
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 12).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );
      final eventId = (first as ManualIngestStored).eventId;

      await DeleteImportedMessage(
        database: db,
      ).call(eventId: eventId, privacyEpoch: 0);

      final again = await ingest(
        rawBody: body,
        rawSender: 'SAMPATHTX',
        source: IngestionSource.manualPaste,
        userOverrodeFilter: false,
        epochMs: DateTime.utc(2026, 8, 13).millisecondsSinceEpoch,
        privacyEpoch: 0,
      );

      expect(again, isA<ManualIngestStored>());
    });
  });

  group('Schema v7', () {
    test('content_sha256 column exists and is nullable', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      expect(db.schemaVersion, 15);

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'k1',
              senderKey: 'S',
              ingestionSource: 'manual_paste',
              receivedAtEpochMs: 1,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
            ),
          );
      final event = await db.select(db.smsEvents).getSingle();
      expect(event.contentSha256, isNull);
    });
  });
}
