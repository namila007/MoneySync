import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/security/database_key_provider.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

void main() {
  group('AppDatabase schema v5', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => database.close());

    test('creates each foundation table on a fresh database', () async {
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .get();

      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll(<String>[
          'activity_events',
          'app_lock_state',
          'app_settings',
          'capability_ledger',
          'decision_traces',
          'deletion_audit_events',
          'parser_rules',
          'schema_metadata',
          'sms_events',
          'transaction_candidates',
          'wallet_account_cache',
          'wallet_category_cache',
          'wallet_connection_status',
          'wallet_mutations',
          'wallet_record_links',
        ]),
      );
    });

    test(
      'reports the frozen v5 schema and enforces foreign keys after opening',
      () async {
        expect(database.schemaVersion, 5);

        await expectLater(
          database
              .into(database.transactionCandidates)
              .insert(
                TransactionCandidatesCompanion.insert(
                  smsEventId: 999,
                  state: CandidateRecordState.needsReview,
                  encryptedPayload: 'opaque-fixture',
                  revision: 1,
                  createdAtEpochMs: 1784678400000,
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
      },
    );

    test(
      'keeps only one canonical SMS event under concurrent duplicates',
      () async {
        final writes = List<Future<SmsEventInsertResult>>.generate(
          2,
          (_) => database.insertSmsEventIfAbsent(
            sourceKey: 'synthetic-hmac-key',
            senderHash: 'sender-hash',
            redactedBody: 'LKR ****.** at merchant',
            ingestionSource: 'history_selection',
            receivedAtEpochMs: 1784678400000,
            status: 'captured',
            privacyEpoch: 0,
          ),
        );

        final results = await Future.wait(writes);
        final count = await database.smsEvents.count().getSingle();

        expect(count, 1);
        expect(results.where((result) => result.inserted), hasLength(1));
        expect(results.where((result) => !result.inserted), hasLength(1));
      },
    );

    test('inserts the candidate and activity together', () async {
      final sms = await database.insertSmsEventIfAbsent(
        sourceKey: 'synthetic-hmac-transaction',
        senderHash: 'sender-hash',
        ingestionSource: 'history_selection',
        receivedAtEpochMs: 1784678400000,
        status: 'captured',
        privacyEpoch: 0,
      );

      await database.insertCandidateAndActivityAtomically(
        smsEventId: sms.id,
        candidateState: CandidateRecordState.needsReview,
        encryptedPayload: 'encrypted-fixture',
        revision: 1,
        createdAtEpochMs: 1784678400000,
        activityType: ActivityEventCode.candidateNeedsReview,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
        privacyEpoch: 0,
      );

      expect(await database.smsEvents.count().getSingle(), 1);
      expect(await database.transactionCandidates.count().getSingle(), 1);
      expect(await database.decisionTraces.count().getSingle(), 1);
      expect(await database.activityEvents.count().getSingle(), 1);
    });

    test(
      'rolls back candidate, decision trace and activity together',
      () async {
        final sms = await database.insertSmsEventIfAbsent(
          sourceKey: 'synthetic-hmac-rollback',
          senderHash: 'sender-hash',
          ingestionSource: 'history_selection',
          receivedAtEpochMs: 1784678400000,
          status: 'captured',
          privacyEpoch: 0,
        );

        await expectLater(
          database.insertCandidateAndActivityAtomically(
            smsEventId: sms.id,
            candidateState: CandidateRecordState.needsReview,
            encryptedPayload: 'encrypted-fixture',
            revision: 1,
            createdAtEpochMs: 1784678400000,
            activityType: ActivityEventCode.candidateNeedsReview,
            safeDetailCode: ActivityStateTransition.needsReview,
            decisionTraceCode: DecisionTraceCode.initialReview,
            privacyEpoch: 0,
            failBeforeCommitForTesting: true,
          ),
          throwsA(isA<StateError>()),
        );

        expect(await database.smsEvents.count().getSingle(), 1);
        expect(await database.transactionCandidates.count().getSingle(), 0);
        expect(await database.decisionTraces.count().getSingle(), 0);
        expect(await database.activityEvents.count().getSingle(), 0);
      },
    );

    test('enforces one transaction candidate for each source event', () async {
      final sms = await database.insertSmsEventIfAbsent(
        sourceKey: 'synthetic-hmac-one-to-one',
        senderHash: 'sender-hash',
        ingestionSource: 'history_selection',
        receivedAtEpochMs: 1784678400000,
        status: 'captured',
        privacyEpoch: 0,
      );

      Future<void> insertCandidate() =>
          database.insertCandidateAndActivityAtomically(
            smsEventId: sms.id,
            candidateState: CandidateRecordState.needsReview,
            encryptedPayload: 'encrypted-fixture',
            revision: 1,
            createdAtEpochMs: 1784678400000,
            activityType: ActivityEventCode.candidateNeedsReview,
            safeDetailCode: ActivityStateTransition.needsReview,
            decisionTraceCode: DecisionTraceCode.initialReview,
            privacyEpoch: 0,
          );

      await insertCandidate();
      await expectLater(insertCandidate(), throwsA(isA<SqliteException>()));
      expect(await database.transactionCandidates.count().getSingle(), 1);
    });

    test('rejects stale work after the privacy epoch advances', () async {
      expect(await database.advancePrivacyEpoch(expectedCurrent: 0), 1);

      await expectLater(
        database.insertSmsEventIfAbsent(
          sourceKey: 'synthetic-hmac-stale',
          senderHash: 'sender-hash',
          ingestionSource: 'history_selection',
          receivedAtEpochMs: 1784678400000,
          status: 'captured',
          privacyEpoch: 0,
        ),
        throwsA(isA<StalePrivacyEpochException>()),
      );
      expect(await database.smsEvents.count().getSingle(), 0);
    });
  });

  group('encrypted database opening boundary', () {
    test('fails closed when the key provider cannot provide a key', () async {
      var openerCalled = false;
      final factory = EncryptedDatabaseFactory(
        keyProvider: const _MissingKeyProvider(),
        openEncryptedExecutor: (_) {
          openerCalled = true;
          throw StateError('must not open');
        },
      );

      await expectLater(
        factory.open(),
        throwsA(isA<DatabaseKeyUnavailableException>()),
      );
      expect(openerCalled, isFalse);
    });

    test(
      'delegates a fake opaque key to an in-memory executor for tests',
      () async {
        final key = DatabaseKeyHandle(Uint8List.fromList([1, 2, 3, 4]));
        DatabaseKeyHandle? suppliedKey;
        final factory = EncryptedDatabaseFactory(
          keyProvider: _AvailableKeyProvider(key),
          openEncryptedExecutor: (receivedKey) async {
            suppliedKey = receivedKey;
            return NativeDatabase.memory();
          },
        );

        final database = await factory.open();
        addTearDown(database.close);

        expect(suppliedKey, same(key));
        expect(database.schemaVersion, 5);
        expect(await database.smsEvents.count().getSingle(), 0);
      },
    );
  });
}

final class _MissingKeyProvider implements DatabaseKeyProvider {
  const _MissingKeyProvider();

  @override
  Future<DatabaseKeyAccess> acquire() async {
    return const DatabaseKeyUnavailable(DatabaseKeyUnavailableReason.locked);
  }
}

final class _AvailableKeyProvider implements DatabaseKeyProvider {
  const _AvailableKeyProvider(this.key);

  final DatabaseKeyHandle key;

  @override
  Future<DatabaseKeyAccess> acquire() async => DatabaseKeyAvailable(key);
}
