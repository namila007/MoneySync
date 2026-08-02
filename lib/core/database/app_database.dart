import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../security/database_key_provider.dart';
import '../../features/activity_log/domain/activity_event.dart';
import '../../features/transaction_parser/domain/transaction_candidate.dart';

part 'app_database.g.dart';

class SmsEventInsertResult {
  const SmsEventInsertResult({required this.id, required this.inserted});

  final int id;
  final bool inserted;
}

final class StalePrivacyEpochException implements Exception {
  const StalePrivacyEpochException();
}

typedef EncryptedExecutorOpener =
    Future<QueryExecutor> Function(DatabaseKeyHandle key);

class EncryptedDatabaseFactory {
  const EncryptedDatabaseFactory({
    required this.keyProvider,
    required this.openEncryptedExecutor,
  });

  final DatabaseKeyProvider keyProvider;
  final EncryptedExecutorOpener openEncryptedExecutor;

  Future<AppDatabase> open() async {
    final keyAccess = await keyProvider.acquire();
    final executor = await openEncryptedExecutor(keyAccess.requireKey());
    return AppDatabase(executor);
  }
}

class AppSettings extends Table {
  IntColumn get singletonId => integer().withDefault(const Constant(1))();
  IntColumn get privacyEpoch => integer().withDefault(const Constant(0))();

  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get onboardingRevision => integer().nullable()();
  BoolColumn get disclosureAccepted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get disclosureRevision => integer().nullable()();
  TextColumn get processingMode =>
      text().withDefault(const Constant('review'))();
  IntColumn get configurationRevision =>
      integer().withDefault(const Constant(0))();

  IntColumn get rawCopyRetentionDays =>
      integer().withDefault(const Constant(0))();
  IntColumn get activityRetentionDays =>
      integer().withDefault(const Constant(180))();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};

  @override
  String get tableName => 'app_settings';
}

class SenderRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get senderHash => text().unique()();
  TextColumn get parserFamily => text()();
  IntColumn get createdAtEpochMs => integer()();

  TextColumn get parserVersion => text().nullable()();
  TextColumn get parserChecksum => text().nullable()();

  @override
  String get tableName => 'parser_rules';
}

class SmsEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceKey => text().unique()();
  TextColumn get senderHash => text()();
  TextColumn get encryptedBody => text().nullable()();
  TextColumn get redactedBody => text().nullable()();
  TextColumn get ingestionSource => text()();
  IntColumn get receivedAtEpochMs => integer()();
  IntColumn get expiresAtEpochMs => integer().nullable()();
  TextColumn get status => text()();
  IntColumn get privacyEpoch => integer()();
}

class TransactionCandidates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get smsEventId => integer().unique().references(SmsEvents, #id)();
  TextColumn get state => textEnum<CandidateRecordState>()();
  TextColumn get encryptedPayload => text()();
  IntColumn get revision => integer()();
  IntColumn get createdAtEpochMs => integer()();

  TextColumn get warningCode => text().nullable()();
  TextColumn get paymentEvidence => text().nullable()();
  TextColumn get instrumentEvidence => text().nullable()();
  TextColumn get originalCurrencyCode => text().nullable()();
  TextColumn get walletCurrencyCode => text().nullable()();
}

class ActivityEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => textEnum<ActivityEventCode>()();
  TextColumn get sanitizedDetail => textEnum<ActivityStateTransition>()();
  IntColumn get occurredAtEpochMs => integer()();
  IntColumn get privacyEpoch => integer()();
}

class DecisionTraces extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get candidateId =>
      integer().nullable().references(TransactionCandidates, #id)();
  TextColumn get traceCode => textEnum<DecisionTraceCode>()();
  IntColumn get createdAtEpochMs => integer()();
}

class DatabaseMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  String get tableName => 'schema_metadata';
}

class AppLockState extends Table {
  IntColumn get singletonId => integer().withDefault(const Constant(1))();
  BoolColumn get lockEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get inactivityTimeoutSeconds =>
      integer().withDefault(const Constant(300))();
  TextColumn get lockMetadata => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};

  @override
  String get tableName => 'app_lock_state';
}

class DeletionAuditEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get privacyEpochBefore => integer()();
  IntColumn get privacyEpochAfter => integer()();
  IntColumn get occurredAtEpochMs => integer()();

  @override
  String get tableName => 'deletion_audit_events';
}

class WalletAccountCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get currencyCode => text()();
  BoolColumn get isArchived => boolean()();
  BoolColumn get isBankSynced => boolean()();
  BoolColumn get isWritable => boolean()();
  TextColumn get eligibilityReason => text()();
  IntColumn get refreshedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_account_cache';
}

class WalletCategoryCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get refreshedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_category_cache';
}

class WalletConnectionStatus extends Table {
  IntColumn get singletonId => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('disconnected'))();
  IntColumn get lastSyncAtEpochMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};

  @override
  String get tableName => 'wallet_connection_status';
}

class WalletMutations extends Table {
  TextColumn get id => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get state => text()();
  TextColumn get lineageKey => text()();
  TextColumn get fingerprint => text()();
  IntColumn get createdAtEpochMs => integer()();
  IntColumn get updatedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_mutations';
}

class WalletRecordLinks extends Table {
  TextColumn get id => text()();
  TextColumn get appId => text().unique()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get createdAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_record_links';
}

class CapabilityLedger extends Table {
  TextColumn get id => text()();
  TextColumn get capability => text()();
  TextColumn get status => text()();
  TextColumn get evidenceReference => text().nullable()();
  TextColumn get observedOn => text()();
  TextColumn get reviewDate => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'capability_ledger';
}

@DriftDatabase(
  tables: [
    AppSettings,
    SenderRules,
    SmsEvents,
    TransactionCandidates,
    ActivityEvents,
    DecisionTraces,
    DatabaseMetadata,
    AppLockState,
    DeletionAuditEvents,
    WalletAccountCache,
    WalletCategoryCache,
    WalletConnectionStatus,
    WalletMutations,
    WalletRecordLinks,
    CapabilityLedger,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.inMemoryForTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'INSERT OR IGNORE INTO app_settings (singleton_id, privacy_epoch) '
        'VALUES (1, 0)',
      );
      await customStatement(
        'INSERT OR IGNORE INTO app_lock_state (singleton_id) VALUES (1)',
      );
      await customStatement(
        'INSERT OR IGNORE INTO wallet_connection_status '
        '(singleton_id) VALUES (1)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(appSettings, appSettings.onboardingCompleted);
        await m.addColumn(appSettings, appSettings.onboardingRevision);
        await m.addColumn(appSettings, appSettings.disclosureAccepted);
        await m.addColumn(appSettings, appSettings.disclosureRevision);
        await m.addColumn(appSettings, appSettings.processingMode);
        await m.addColumn(appSettings, appSettings.configurationRevision);

        await m.addColumn(senderRules, senderRules.parserVersion);
        await m.addColumn(senderRules, senderRules.parserChecksum);

        await m.addColumn(
          transactionCandidates,
          transactionCandidates.warningCode,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.paymentEvidence,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.instrumentEvidence,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.originalCurrencyCode,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.walletCurrencyCode,
        );

        await m.createTable(appLockState);
        await m.createTable(deletionAuditEvents);

        await customStatement(
          'INSERT OR IGNORE INTO app_lock_state (singleton_id) VALUES (1)',
        );
      }
      if (from < 3) {
        await m.createTable(walletAccountCache);
        await m.createTable(walletCategoryCache);
        await m.createTable(walletConnectionStatus);
        await m.createTable(walletMutations);
        await m.createTable(walletRecordLinks);
        await m.createTable(capabilityLedger);

        await customStatement(
          'INSERT OR IGNORE INTO wallet_connection_status '
          '(singleton_id) VALUES (1)',
        );
      }
      if (from < 4) {
        await m.addColumn(appSettings, appSettings.rawCopyRetentionDays);
        await m.addColumn(appSettings, appSettings.activityRetentionDays);
      }
    },
  );

  Future<int> advancePrivacyEpoch({required int expectedCurrent}) {
    return transaction(() async {
      await _requireCurrentPrivacyEpoch(expectedCurrent);
      final next = expectedCurrent + 1;
      await (update(appSettings)..where((row) => row.singletonId.equals(1)))
          .write(AppSettingsCompanion(privacyEpoch: Value(next)));
      return next;
    });
  }

  Future<SmsEventInsertResult> insertSmsEventIfAbsent({
    required String sourceKey,
    required String senderHash,
    String? encryptedBody,
    String? redactedBody,
    required String ingestionSource,
    required int receivedAtEpochMs,
    int? expiresAtEpochMs,
    required String status,
    required int privacyEpoch,
  }) async {
    return transaction(() async {
      await _requireCurrentPrivacyEpoch(privacyEpoch);
      final inserted = await into(smsEvents).insertReturningOrNull(
        SmsEventsCompanion.insert(
          sourceKey: sourceKey,
          senderHash: senderHash,
          encryptedBody: Value(encryptedBody),
          redactedBody: Value(redactedBody),
          ingestionSource: ingestionSource,
          receivedAtEpochMs: receivedAtEpochMs,
          expiresAtEpochMs: Value(expiresAtEpochMs),
          status: status,
          privacyEpoch: privacyEpoch,
        ),
        mode: InsertMode.insertOrIgnore,
      );
      if (inserted != null) {
        return SmsEventInsertResult(id: inserted.id, inserted: true);
      }
      final existing = await (select(
        smsEvents,
      )..where((row) => row.sourceKey.equals(sourceKey))).getSingle();
      return SmsEventInsertResult(id: existing.id, inserted: false);
    });
  }

  Future<void> insertCandidateAndActivityAtomically({
    required int smsEventId,
    required CandidateRecordState candidateState,
    required String encryptedPayload,
    required int revision,
    required int createdAtEpochMs,
    required ActivityEventCode activityType,
    required ActivityStateTransition safeDetailCode,
    required DecisionTraceCode decisionTraceCode,
    required int privacyEpoch,
    bool failBeforeCommitForTesting = false,
  }) {
    return transaction(() async {
      await _requireCurrentPrivacyEpoch(privacyEpoch);
      final candidateId = await into(transactionCandidates).insert(
        TransactionCandidatesCompanion.insert(
          smsEventId: smsEventId,
          state: candidateState,
          encryptedPayload: encryptedPayload,
          revision: revision,
          createdAtEpochMs: createdAtEpochMs,
        ),
      );
      await into(decisionTraces).insert(
        DecisionTracesCompanion.insert(
          candidateId: Value(candidateId),
          traceCode: decisionTraceCode,
          createdAtEpochMs: createdAtEpochMs,
        ),
      );
      await into(activityEvents).insert(
        ActivityEventsCompanion.insert(
          eventType: activityType,
          sanitizedDetail: safeDetailCode,
          occurredAtEpochMs: createdAtEpochMs,
          privacyEpoch: privacyEpoch,
        ),
      );
      if (failBeforeCommitForTesting) {
        throw StateError('synthetic_transaction_rollback');
      }
    });
  }

  Future<void> _requireCurrentPrivacyEpoch(int capturedEpoch) async {
    final setting = await (select(
      appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();
    if (setting.privacyEpoch != capturedEpoch) {
      throw const StalePrivacyEpochException();
    }
  }
}
