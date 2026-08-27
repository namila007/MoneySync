import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

void main() {
  group('v5 migration', () {
    Future<AppDatabase> migrateFrom(int fromVersion) async {
      return AppDatabase(
        NativeDatabase.memory(
          setup: (db) {
            db.execute(
              'CREATE TABLE IF NOT EXISTS _drift_schema_versions '
              '(id INTEGER NOT NULL, run_at INTEGER NOT NULL)',
            );
            db.execute(
              'INSERT INTO _drift_schema_versions (id, run_at) '
              'VALUES (?, unixepoch())',
              [fromVersion],
            );
          },
        ),
      );
    }

    test('v5 schema version is reported on fresh database', () {
      final database = AppDatabase.inMemoryForTesting();
      expect(database.schemaVersion, 17);
    });

    test('smsDisclosureRevision is null after migration', () async {
      final db = AppDatabase.inMemoryForTesting();
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(setting.smsDisclosureRevision, isNull);
    });

    test('historySmsEnabled defaults to false after migration', () async {
      final db = AppDatabase.inMemoryForTesting();
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(setting.historySmsEnabled, false);
    });

    test(
      'historyWindowDays defaults to 7 and historyMessageCap to 100',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(setting.historyWindowDays, 7);
        expect(setting.historyMessageCap, 100);
      },
    );

    test('rule_packs and ingestion_checkpoint exist and are empty', () async {
      final db = AppDatabase.inMemoryForTesting();
      final rulePacksRows = await db.select(db.rulePacks).get();
      expect(rulePacksRows.length, 0);
      final checkpointsRows = await db.select(db.ingestionCheckpoints).get();
      expect(checkpointsRows.length, 0);
    });

    group('v1 → v5 migration', () {
      test(
        'preserves v1 app_settings and adds v5 columns with defaults',
        () async {
          final db = await migrateFrom(1);
          addTearDown(db.close);

          final setting = await (db.select(
            db.appSettings,
          )..where((row) => row.singletonId.equals(1))).getSingle();

          expect(setting.privacyEpoch, 0);
          expect(setting.onboardingCompleted, false);
          expect(setting.onboardingRevision, isNull);
          expect(setting.disclosureAccepted, false);
          expect(setting.disclosureRevision, isNull);
          expect(setting.processingMode, 'review');
          expect(setting.configurationRevision, 0);
          expect(setting.rawCopyRetentionDays, 0);
          expect(setting.activityRetentionDays, 180);
          expect(setting.smsDisclosureRevision, isNull);
          expect(setting.historySmsEnabled, false);
          expect(setting.historyWindowDays, 7);
          expect(setting.historyMessageCap, 100);
        },
      );

      test(
        'preserves v1 sms_events and adds v5 columns with defaults',
        () async {
          final db = await migrateFrom(1);
          addTearDown(db.close);

          await db
              .into(db.smsEvents)
              .insert(
                SmsEventsCompanion.insert(
                  sourceKey: 'v1-test-key',
                  senderKey: 'v1-sender-hash',
                  ingestionSource: 'manual',
                  receivedAtEpochMs: 1234567890,
                  status: SmsEventStatus.captured,
                  privacyEpoch: 0,
                ),
              );

          final event = await db.select(db.smsEvents).getSingle();
          expect(event.sourceKey, 'v1-test-key');
          expect(event.senderKey, 'v1-sender-hash');
          expect(event.providerRowId, isNull);
          expect(event.captureCanonicalizationVersion, 2);
          expect(event.redactionVersion, 1);
          expect(event.rawPurgeState, RawPurgeState.pending);
        },
      );
    });

    group('v2 → v5 migration', () {
      test('preserves v2 onboarding data and adds v5 columns', () async {
        final db = await migrateFrom(2);
        addTearDown(db.close);

        await (db.update(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).write(
          const AppSettingsCompanion(
            onboardingCompleted: Value(true),
            onboardingRevision: Value(1),
            disclosureAccepted: Value(true),
            disclosureRevision: Value(1),
            processingMode: Value('review'),
            configurationRevision: Value(1),
          ),
        );

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.onboardingCompleted, true);
        expect(setting.onboardingRevision, 1);
        expect(setting.disclosureAccepted, true);
        expect(setting.disclosureRevision, 1);
        expect(setting.processingMode, 'review');
        expect(setting.configurationRevision, 1);
        expect(setting.rawCopyRetentionDays, 0);
        expect(setting.activityRetentionDays, 180);
        expect(setting.smsDisclosureRevision, isNull);
        expect(setting.historySmsEnabled, false);
        expect(setting.historyWindowDays, 7);
        expect(setting.historyMessageCap, 100);
      });

      test('preserves v2 app_lock_state data', () async {
        final db = await migrateFrom(2);
        addTearDown(db.close);

        await (db.update(
          db.appLockState,
        )..where((row) => row.singletonId.equals(1))).write(
          const AppLockStateCompanion(
            lockEnabled: Value(true),
            inactivityTimeoutSeconds: Value(300),
          ),
        );

        final lockState = await (db.select(
          db.appLockState,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(lockState.lockEnabled, true);
        expect(lockState.inactivityTimeoutSeconds, 300);
      });
    });

    group('v3 → v5 migration', () {
      test('preserves v3 wallet data and adds v5 columns', () async {
        final db = await migrateFrom(3);
        addTearDown(db.close);

        await db
            .into(db.walletAccountCache)
            .insert(
              WalletAccountCacheCompanion.insert(
                id: 'test-account-id',
                name: 'Test Account',
                currencyCode: 'USD',
                isArchived: false,
                isBankSynced: false,
                isWritable: true,
                eligibilityReason: 'eligible',
                refreshedAtEpochMs: 1234567890,
              ),
            );

        await db
            .into(db.walletCategoryCache)
            .insert(
              WalletCategoryCacheCompanion.insert(
                id: 'test-category-id',
                name: 'Test Category',
                refreshedAtEpochMs: 1234567890,
              ),
            );

        final accounts = await db.select(db.walletAccountCache).get();
        expect(accounts.length, 1);
        expect(accounts.first.id, 'test-account-id');

        final categories = await db.select(db.walletCategoryCache).get();
        expect(categories.length, 1);
        expect(categories.first.id, 'test-category-id');

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();
        expect(setting.rawCopyRetentionDays, 0);
        expect(setting.activityRetentionDays, 180);
        expect(setting.historySmsEnabled, false);
        expect(setting.historyWindowDays, 7);
        expect(setting.historyMessageCap, 100);
      });
    });

    group('v4 → v5 migration', () {
      test('preserves v4 retention settings and adds v5 columns', () async {
        final db = await migrateFrom(4);
        addTearDown(db.close);

        await (db.update(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).write(
          const AppSettingsCompanion(
            rawCopyRetentionDays: Value(7),
            activityRetentionDays: Value(90),
          ),
        );

        final setting = await (db.select(
          db.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.rawCopyRetentionDays, 7);
        expect(setting.activityRetentionDays, 90);
        expect(setting.smsDisclosureRevision, isNull);
        expect(setting.historySmsEnabled, false);
        expect(setting.historyWindowDays, 7);
        expect(setting.historyMessageCap, 100);
      });

      test(
        'preserves v4 sms_events and adds v5 columns with defaults',
        () async {
          final db = await migrateFrom(4);
          addTearDown(db.close);

          await db
              .into(db.smsEvents)
              .insert(
                SmsEventsCompanion.insert(
                  sourceKey: 'v4-test-key',
                  senderKey: 'v4-sender-hash',
                  ingestionSource: 'manual',
                  receivedAtEpochMs: 1234567890,
                  status: SmsEventStatus.captured,
                  privacyEpoch: 0,
                ),
              );

          final event = await db.select(db.smsEvents).getSingle();
          expect(event.sourceKey, 'v4-test-key');
          expect(event.providerRowId, isNull);
          expect(event.captureCanonicalizationVersion, 2);
          expect(event.redactionVersion, 1);
          expect(event.rawPurgeState, RawPurgeState.pending);
        },
      );

      test('preserves v4 transaction_candidates and adds v5 columns', () async {
        final db = await migrateFrom(4);
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'v4-candidate-key',
                senderKey: 'v4-sender',
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

      test('preserves v4 decision_traces and adds v5 columns', () async {
        final db = await migrateFrom(4);
        addTearDown(db.close);

        await db
            .into(db.smsEvents)
            .insert(
              SmsEventsCompanion.insert(
                sourceKey: 'v4-trace-key',
                senderKey: 'v4-sender',
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
        expect(trace.stage, isNull);
        expect(trace.rulePackVersion, isNull);
        expect(trace.outcomeCode, isNull);
      });

      test('creates v5 rule_packs and ingestion_checkpoint tables', () async {
        final db = await migrateFrom(4);
        addTearDown(db.close);

        final rulePacks = await db.select(db.rulePacks).get();
        expect(rulePacks, isEmpty);

        final checkpoints = await db.select(db.ingestionCheckpoints).get();
        expect(checkpoints, isEmpty);
      });
    });

    group('v7 → v8 migration (M4.15 WP3)', () {
      test('adds the nullable count column to activity_events', () async {
        final db = await migrateFrom(7);
        addTearDown(db.close);

        await db.insertActivity(
          activityType: ActivityEventCode.messageImported,
          safeDetailCode: ActivityStateTransition.logEvent,
          occurredAtEpochMs: 1784678400000,
          privacyEpoch: 0,
        );

        final rows = await db.select(db.activityEvents).get();
        expect(rows, hasLength(1));
        expect(rows.single.batchCount, isNull);
      });

      test('pre-migration events read back with a null count', () async {
        final db = await migrateFrom(7);
        addTearDown(db.close);

        await db.customStatement(
          'INSERT INTO activity_events (event_type, sanitized_detail, '
          'occurred_at_epoch_ms, privacy_epoch) VALUES '
          "('messageImported', 'logEvent', 1, 0)",
        );

        final rows = await db.select(db.activityEvents).get();
        expect(rows.single.batchCount, isNull);
      });
    });
  });
}
