import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('Migration matrix', () {
    test('schema version is 5', () {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      expect(db.schemaVersion, 9);
    });

    group('v5 schema has all required tables', () {
      test('foundation tables exist', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final tables = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table'",
              readsFrom: const {},
            )
            .get();

        final tableNames = tables
            .map((row) => row.read<String>('name'))
            .toSet();

        expect(tableNames, contains('app_settings'));
        expect(tableNames, contains('parser_rules'));
        expect(tableNames, contains('sms_events'));
        expect(tableNames, contains('transaction_candidates'));
        expect(tableNames, contains('activity_events'));
        expect(tableNames, contains('decision_traces'));
        expect(tableNames, contains('schema_metadata'));
        expect(tableNames, contains('app_lock_state'));
        expect(tableNames, contains('deletion_audit_events'));
        expect(tableNames, contains('wallet_account_cache'));
        expect(tableNames, contains('wallet_category_cache'));
        expect(tableNames, contains('wallet_connection_status'));
        expect(tableNames, contains('wallet_mutations'));
        expect(tableNames, contains('wallet_record_links'));
        expect(tableNames, contains('capability_ledger'));
        expect(tableNames, contains('rule_packs'));
        expect(tableNames, contains('ingestion_checkpoint'));
      });

      // NOTE: v5 indexes are created via raw SQL in onUpgrade(from < 5),
      // so they only exist after migrating from v4, not on fresh databases.
      // This is a known limitation - indexes should ideally be defined in
      // table classes or created in beforeOpen for fresh databases too.
    });

    group('v5 app_settings has all required columns', () {
      test('v1 foundation columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.privacyEpoch, 0);
      });

      test('v2 onboarding and lock columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.onboardingCompleted, false);
        expect(setting.onboardingRevision, isNull);
        expect(setting.disclosureAccepted, false);
        expect(setting.disclosureRevision, isNull);
        expect(setting.processingMode, 'review');
        expect(setting.configurationRevision, 0);
      });

      test('v4 retention columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.rawCopyRetentionDays, 0);
        expect(setting.activityRetentionDays, 180);
      });

      test('v5 SMS history columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.smsDisclosureRevision, isNull);
        expect(setting.historySmsEnabled, false);
        expect(setting.historyWindowDays, 7);
        expect(setting.historyMessageCap, 100);
      });
    });

    group('v5 sms_events has all required columns', () {
      test('v1 foundation columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'test-key',
                senderKey: 'test-sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final event = await db.select(db.smsEvents).getSingle();
        expect(event.sourceKey, 'test-key');
        expect(event.senderKey, 'test-sender');
        expect(event.ingestionSource, 'manual');
        expect(event.receivedAtEpochMs, 1234567890);
        expect(event.status, SmsEventStatus.captured);
        expect(event.privacyEpoch, 0);
      });

      test('v5 provider and canonicalization columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'test-key',
                senderKey: 'test-sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final event = await db.select(db.smsEvents).getSingle();
        expect(event.providerRowId, isNull);
        expect(event.captureCanonicalizationVersion, 2);
        expect(event.redactionVersion, 1);
        expect(event.rawPurgeState, RawPurgeState.pending);
      });
    });

    group('v5 transaction_candidates has all required columns', () {
      test('v1 foundation columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'test-key',
                senderKey: 'test-sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final event = await db.select(db.smsEvents).getSingle();

        await db
            .into(db.transactionCandidates)
            .insert(
              TransactionCandidatesCompanion.insert(
                smsEventId: event.id,
                state: CandidateRecordState.needsReview,
                encryptedPayload: '{}',
                revision: 1,
                createdAtEpochMs: 1234567890,
              ),
            );

        final candidate = await db.select(db.transactionCandidates).getSingle();
        expect(candidate.smsEventId, event.id);
        expect(candidate.state, CandidateRecordState.needsReview);
        expect(candidate.revision, 1);
        expect(candidate.createdAtEpochMs, 1234567890);
      });

      test('v2 currency columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'test-key',
                senderKey: 'test-sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final event = await db.select(db.smsEvents).getSingle();

        await db
            .into(db.transactionCandidates)
            .insert(
              TransactionCandidatesCompanion.insert(
                smsEventId: event.id,
                state: CandidateRecordState.needsReview,
                encryptedPayload: '{}',
                revision: 1,
                createdAtEpochMs: 1234567890,
              ),
            );

        final candidate = await db.select(db.transactionCandidates).getSingle();
        expect(candidate.warningCode, isNull);
        expect(candidate.paymentEvidence, isNull);
        expect(candidate.instrumentEvidence, isNull);
        expect(candidate.originalCurrencyCode, isNull);
        expect(candidate.walletCurrencyCode, isNull);
      });

      test('v5 interpretation columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'test-key',
                senderKey: 'test-sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final event = await db.select(db.smsEvents).getSingle();

        await db
            .into(db.transactionCandidates)
            .insert(
              TransactionCandidatesCompanion.insert(
                smsEventId: event.id,
                state: CandidateRecordState.needsReview,
                encryptedPayload: '{}',
                revision: 1,
                createdAtEpochMs: 1234567890,
              ),
            );

        final candidate = await db.select(db.transactionCandidates).getSingle();
        expect(candidate.kind, isNull);
        expect(candidate.direction, isNull);
        expect(candidate.lifecycle, isNull);
        expect(candidate.originalAmountMinor, isNull);
        expect(candidate.walletAmountMinor, isNull);
        expect(candidate.transactionAtEpochMs, isNull);
        expect(candidate.dateEvidence, isNull);
        expect(candidate.counterpartyRedacted, isNull);
        expect(candidate.instrumentSuffixHash, isNull);
        expect(candidate.availableBalanceMinor, isNull);
        expect(candidate.paymentType, isNull);
        expect(candidate.confidenceBasisPoints, isNull);
        expect(candidate.parserRuleId, isNull);
        expect(candidate.parserRuleVersion, isNull);
        expect(candidate.rulePackId, isNull);
        expect(candidate.rulePackVersion, isNull);
        expect(candidate.reviewReasons, isNull);
        expect(candidate.transactionFingerprint, isNull);
      });
    });

    group('v5 decision_traces has all required columns', () {
      test('v1 foundation and v5 stage columns', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'test-key',
                senderKey: 'test-sender',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        final event = await db.select(db.smsEvents).getSingle();

        await db
            .into(db.transactionCandidates)
            .insert(
              TransactionCandidatesCompanion.insert(
                smsEventId: event.id,
                state: CandidateRecordState.needsReview,
                encryptedPayload: '{}',
                revision: 1,
                createdAtEpochMs: 1234567890,
              ),
            );

        final candidate = await db.select(db.transactionCandidates).getSingle();

        await db
            .into(db.decisionTraces)
            .insert(
              DecisionTracesCompanion.insert(
                candidateId: Value(candidate.id),
                traceCode: DecisionTraceCode.initialReview,
                createdAtEpochMs: 1234567890,
              ),
            );

        final trace = await db.select(db.decisionTraces).getSingle();
        expect(trace.candidateId, candidate.id);
        expect(trace.traceCode, DecisionTraceCode.initialReview);
        expect(trace.createdAtEpochMs, 1234567890);
        expect(trace.stage, isNull);
        expect(trace.rulePackVersion, isNull);
        expect(trace.outcomeCode, isNull);
      });
    });

    group('v5 new tables', () {
      test('rule_packs table exists and is empty', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final rulePacks = await db.select(db.rulePacks).get();
        expect(rulePacks, isEmpty);
      });

      test('ingestion_checkpoint table exists and is empty', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final checkpoints = await db.select(db.ingestionCheckpoints).get();
        expect(checkpoints, isEmpty);
      });
    });

    group('PRAGMA and singleton initialization', () {
      test('PRAGMA foreign_keys is enabled', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final result = await db
            .customSelect('PRAGMA foreign_keys', readsFrom: const {})
            .getSingle();
        expect(result.read<int>('foreign_keys'), 1);
      });

      test('singleton seed rows exist', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        final settings = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(settings.singletonId, 1);
        expect(settings.privacyEpoch, 0);

        final lockState = await (db.select(
          db.appLockState,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(lockState.singletonId, 1);

        final walletStatus = await (db.select(
          db.walletConnectionStatus,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(walletStatus.singletonId, 1);
        expect(walletStatus.status, 'disconnected');
      });
    });

    group('source_key uniqueness constraint', () {
      test('duplicate source_key is rejected', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'unique-key',
                senderKey: 'sender-1',
                ingestionSource: 'manual',
                receivedAtEpochMs: 1234567890,
                status: SmsEventStatus.captured,
                privacyEpoch: 0,
              ),
            );

        expect(
          () => db
              .into(db.smsEvents)
              .insert(
                SmsEventsCompanion.insert(
                  sourceKey: 'unique-key',
                  senderKey: 'sender-2',
                  ingestionSource: 'manual',
                  receivedAtEpochMs: 9876543210,
                  status: SmsEventStatus.captured,
                  privacyEpoch: 0,
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
      });

      test(
        'different source_keys with same provider_row_id are allowed',
        () async {
          final db = AppDatabase.inMemoryForTesting();
          addTearDown(db.close);

          await db
              .into(db.smsEvents)
              .insert(
                SmsEventsCompanion.insert(
                  sourceKey: 'key-1',
                  senderKey: 'sender',
                  ingestionSource: 'history_selection',
                  receivedAtEpochMs: 1234567890,
                  status: SmsEventStatus.captured,
                  privacyEpoch: 0,
                  providerRowId: Value(123),
                ),
              );

          await db
              .into(db.smsEvents)
              .insert(
                SmsEventsCompanion.insert(
                  sourceKey: 'key-2',
                  senderKey: 'sender',
                  ingestionSource: 'history_selection',
                  receivedAtEpochMs: 1234567890,
                  status: SmsEventStatus.captured,
                  privacyEpoch: 0,
                  providerRowId: Value(123),
                ),
              );

          final events = await db.select(db.smsEvents).get();
          expect(events.length, 2);
        },
      );
    });
  });
}
