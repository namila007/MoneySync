import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/review_inbox/data/drift_review_outbox_writer.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

void main() {
  late AppDatabase database;
  late DriftReviewOutboxWriter writer;

  setUp(() {
    database = AppDatabase.inMemoryForTesting();
    writer = DriftReviewOutboxWriter(database: database);
  });

  tearDown(() => database.close());

  Future<int> insertSmsEvent(String sourceKey) async {
    return database.into(database.smsEvents).insert(
      SmsEventsCompanion.insert(
        sourceKey: sourceKey,
        senderKey: 'BANK ALPHA',
        ingestionSource: 'manual_paste',
        receivedAtEpochMs: 1_700_000_000_000,
        status: SmsEventStatus.review,
        privacyEpoch: 0,
      ),
    );
  }

  Future<void> submit({String? candidateId, int? smsEventId}) async {
    final candidate = candidateId ?? 'candidate-1';
    final eventId = smsEventId ?? await insertSmsEvent('source-$candidate');
    await writer.submitAtomically(
      smsEventId: eventId,
      candidateState: CandidateRecordState.retainedLocal,
      encryptedPayload: '{}',
      revision: 1,
      createdAtEpochMs: 1_700_000_000_000,
      privacyEpoch: 0,
      intent: WalletMutationIntent(
        id: 'mutation-$candidate',
        candidateId: candidate,
        operation: WalletMutationOperation.create,
        operationRevision: 1,
        lineageGeneration: 1,
        createLineageKey: 'lineage-key-$candidate',
        transactionFingerprint: 'fingerprint-$candidate',
        payload: const <String, Object?>{
          'accountId': 'account-1',
          'amountMinor': -4500,
        },
        state: WalletMutationState.queued,
      ),
      itemLegRole: WalletItemLegRole.primary,
      itemPayloadCiphertext: '{}',
      activityType: ActivityEventCode.walletRecordCreated,
      safeDetailCode: ActivityStateTransition.needsReview,
      decisionTraceCode: DecisionTraceCode.initialReview,
    );
  }

  group('atomic review -> outbox write', () {
    test('writes candidate, mutation, item, activity, and trace together',
        () async {
      await submit();

      expect(await database.transactionCandidates.count().getSingle(), 1);
      expect(await database.walletMutations.count().getSingle(), 1);
      expect(await database.walletMutationItems.count().getSingle(), 1);
      expect(await database.activityEvents.count().getSingle(), 1);
      expect(await database.decisionTraces.count().getSingle(), 1);

      final mutation = await database.select(database.walletMutations).getSingle();
      expect(mutation.operationKind, WalletMutationOperation.create);
      expect(mutation.state, WalletMutationState.queued);
      expect(mutation.candidateId, 'candidate-1');
      expect(mutation.lineageGeneration, 1);
    });

    test(
      'reviewing an ingest-created candidate UPDATES it in place: exactly one '
      'row, revision bumped, no unique sms_event_id collision (M5.14 gap 1)',
      () async {
        // Mimic the real ingest path: history import creates the candidate row
        // via insertCandidateAndActivityAtomically (sms_event_id UNIQUE).
        final eventId = await insertSmsEvent('source-ingested');
        await database.insertCandidateAndActivityAtomically(
          smsEventId: eventId,
          candidateState: CandidateRecordState.needsReview,
          encryptedPayload: '{"kind":"expense"}',
          revision: 1,
          createdAtEpochMs: 1_700_000_000_000,
          activityType: ActivityEventCode.candidateNeedsReview,
          safeDetailCode: ActivityStateTransition.needsReview,
          decisionTraceCode: DecisionTraceCode.parsedComplete,
          privacyEpoch: 0,
        );

        await writer.submitAtomically(
          smsEventId: eventId,
          candidateState: CandidateRecordState.retainedLocal,
          encryptedPayload: '{"kind":"expense","approved":true}',
          revision: 2,
          createdAtEpochMs: 1_700_000_000_000,
          privacyEpoch: 0,
          intent: WalletMutationIntent(
            id: 'mutation-ingested',
            candidateId: 'candidate-ingested',
            operation: WalletMutationOperation.create,
            operationRevision: 1,
            lineageGeneration: 1,
            createLineageKey: 'lineage-key-ingested',
            transactionFingerprint: 'fingerprint-ingested',
            payload: const <String, Object?>{'accountId': 'account-1'},
            state: WalletMutationState.queued,
          ),
          itemLegRole: WalletItemLegRole.primary,
          itemPayloadCiphertext: '{}',
          activityType: ActivityEventCode.walletRecordCreated,
          safeDetailCode: ActivityStateTransition.needsReview,
          decisionTraceCode: DecisionTraceCode.initialReview,
        );

        // Exactly ONE candidate row, updated (revision 2), not a duplicate.
        final candidates = await database
            .select(database.transactionCandidates)
            .get();
        expect(candidates, hasLength(1));
        expect(candidates.single.revision, 2);
        expect(candidates.single.smsEventId, eventId);
        expect(candidates.single.candidateId, 'candidate-ingested');

        // The approved candidate + one queued mutation are both observable.
        expect(await database.walletMutations.count().getSingle(), 1);
        final mutation = await database
            .select(database.walletMutations)
            .getSingle();
        expect(mutation.candidateId, 'candidate-ingested');
        expect(mutation.state, WalletMutationState.queued);
      },
    );
  });

  group('atomic rollback', () {
    test(
      'a mid-transaction failure rolls back ALL writes (no partial '
      'state observable)',
      () async {
        final eventId = await insertSmsEvent('source-rollback');

        // Force the wallet_mutations insert (step 2 of the transaction) to
        // violate the partial unique active-lineage index by pre-inserting an
        // active create mutation for the same candidate+generation. This is a
        // realistic mid-transaction failure (a concurrent submit that won),
        // after the candidate UPSERT (step 1) has already run. Everything must
        // roll back — including the candidate update.
        await database.into(database.walletMutations).insert(
          WalletMutationsCompanion.insert(
            id: 'mutation-pre-existing',
            operationKind: WalletMutationOperation.create,
            payload: '{}',
            state: WalletMutationState.queued,
            lineageKey: 'lineage-key-rollback-candidate',
            fingerprint: 'fingerprint-rollback-candidate',
            createdAtEpochMs: 1_700_000_000_000,
            updatedAtEpochMs: 1_700_000_000_000,
            candidateId: const Value('rollback-candidate'),
            operationRevision: const Value(1),
            lineageGeneration: const Value(1),
          ),
        );

        await expectLater(
          submit(candidateId: 'rollback-candidate', smsEventId: eventId),
          throwsA(isA<UniqueLineageViolationException>()),
        );

        // Nothing from the failed transaction may be observable: no mutation,
        // no item, no activity event, no decision trace, and the candidate
        // UPSERT that ran before the failure must also be rolled back.
        expect(await database.walletMutations.count().getSingle(), 1);
        expect(await database.walletMutationItems.count().getSingle(), 0);
        expect(await database.activityEvents.count().getSingle(), 0);
        expect(await database.decisionTraces.count().getSingle(), 0);
        expect(await database.transactionCandidates.count().getSingle(), 0);
      },
    );
  });

  group('double-submit prevention', () {
    test('second active lineage for the same candidate is rejected', () async {
      final eventId = await insertSmsEvent('source-candidate-1');
      await submit(candidateId: 'candidate-1', smsEventId: eventId);
      await expectLater(
        submit(candidateId: 'candidate-1', smsEventId: eventId),
        throwsA(isA<UniqueLineageViolationException>()),
      );

      // Exactly one mutation row survives; the partial unique index is the
      // DB-level backstop.
      final rows = await database.select(database.walletMutations).get();
      expect(rows, hasLength(1));
    });

    test('hasActiveLineage returns true after a write', () async {
      expect(await writer.hasActiveLineage('candidate-1'), isFalse);
      await submit();
      expect(await writer.hasActiveLineage('candidate-1'), isTrue);
    });

    test('two concurrent submits never produce two active rows', () async {
      final eventId = await insertSmsEvent('source-race');
      await Future.wait([
        submit(candidateId: 'race', smsEventId: eventId),
        submit(
          candidateId: 'race',
          smsEventId: eventId,
        ).catchError((_) => null),
      ]);

      final rows = await database
          .select(database.walletMutations)
          .get();
      final active = rows
          .where(
            (r) =>
                r.candidateId == 'race' &&
                const {
                  WalletMutationState.queued,
                  WalletMutationState.syncing,
                }.contains(r.state),
          )
          .toList();
      expect(active, hasLength(1));
    });
  });
}
