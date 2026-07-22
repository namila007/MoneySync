import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../security/database_key_provider.dart';
import '../../features/activity_log/domain/activity_event.dart';
import '../../features/transaction_parser/domain/transaction_candidate.dart';

part 'app_database.g.dart';

/// Immutable result returned by [AppDatabase.insertSmsEventIfAbsent].
class SmsEventInsertResult {
  const SmsEventInsertResult({required this.id, required this.inserted});

  final int id;
  final bool inserted;
}

/// Safe failure raised when work captured before a reset attempts to commit.
final class StalePrivacyEpochException implements Exception {
  const StalePrivacyEpochException();
}

/// Opens SQLCipher-backed executors after the key has been acquired.
///
/// The application supplies the platform SQLCipher opener. It must apply the
/// supplied key before returning an executor, which prevents schema access
/// when a key cannot be obtained.
typedef EncryptedExecutorOpener =
    Future<QueryExecutor> Function(DatabaseKeyHandle key);

/// Production database construction. There is deliberately no plaintext
/// fallback: an unavailable key fails before an executor can be opened.
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

@DriftDatabase(
  tables: [
    AppSettings,
    SenderRules,
    SmsEvents,
    TransactionCandidates,
    ActivityEvents,
    DecisionTraces,
    DatabaseMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Fast, explicitly plaintext test-only database. Production uses
  /// [EncryptedDatabaseFactory] instead.
  AppDatabase.inMemoryForTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'INSERT OR IGNORE INTO app_settings (singleton_id, privacy_epoch) '
        'VALUES (1, 0)',
      );
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
