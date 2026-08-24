import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../security/database_key_provider.dart';
import '../../features/activity_log/domain/activity_event.dart';
import '../../features/mappings/domain/mapping_rule.dart';
import '../../features/sms_tracking/domain/tracked_senders.dart';
import '../../features/transaction_parser/domain/transaction_candidate.dart';
import '../../features/wallet_sync/domain/mutation_intent.dart';

part 'app_database.g.dart';

enum RawPurgeState {
  pending,
  purgedOnFilter,
  purgedAfterProcessing,
  purgedOnExpiry,
  purgedOnUserRequest,
  retainedByConsent,
}

enum IngestionOutcome {
  completed,
  capReached,
  userCancelled,
  permissionDenied,
  permissionRevoked,
  noResults,
  failed,
}

/// Closed lifecycle states of one stored message. Persisted by name — append
/// new members, never rename or reorder (M4.14 §3.2).
enum SmsEventStatus { captured, review, interpreted, ignored, purged }

class SmsEventInsertResult {
  const SmsEventInsertResult({
    required this.id,
    required this.inserted,
    this.duplicateSuspected = false,
  });

  final int id;
  final bool inserted;

  /// A row with the same content hash already exists but was not deduplicated
  /// (different canonical key). Review hint only — never a drop (M4.14 WP4).
  final bool duplicateSuspected;
}

/// True per-sender totals for the grouped inbox, computed over the whole
/// table — the `Show all (N)` count must not lie about N (M4.14 WP2).
final class SmsEventSenderSummary {
  const SmsEventSenderSummary({
    required this.senderKey,
    required this.senderDisplay,
    required this.total,
  });

  final String senderKey;
  final String? senderDisplay;
  final int total;
}

final class StalePrivacyEpochException implements Exception {
  const StalePrivacyEpochException();
}

/// Persists [WalletMutationState] using the plan/03 canonical snake_case
/// values so the raw-SQL partial unique index on
/// `wallet_mutations(candidate_id, lineage_generation)` matches what the
/// outbox writes (M5.1). Enum `.name` is camelCase and is not stored.
class WalletMutationStateConverter
    extends TypeConverter<WalletMutationState, String> {
  const WalletMutationStateConverter();

  @override
  WalletMutationState fromSql(String fromDb) => switch (fromDb) {
    'queued' => WalletMutationState.queued,
    'syncing' => WalletMutationState.syncing,
    'reconciling' => WalletMutationState.reconciling,
    'unknown_delivery' => WalletMutationState.unknownDelivery,
    'unknown_update' => WalletMutationState.unknownUpdate,
    'unknown_delete' => WalletMutationState.unknownDelete,
    'retry_scheduled' => WalletMutationState.retryScheduled,
    'succeeded' => WalletMutationState.succeeded,
    'permanent_failure' => WalletMutationState.permanentFailure,
    'superseded_before_send' => WalletMutationState.supersededBeforeSend,
    _ => throw ArgumentError.value(
      fromDb,
      'fromDb',
      'Unknown WalletMutationState',
    ),
  };

  @override
  String toSql(WalletMutationState value) => switch (value) {
    WalletMutationState.queued => 'queued',
    WalletMutationState.syncing => 'syncing',
    WalletMutationState.reconciling => 'reconciling',
    WalletMutationState.unknownDelivery => 'unknown_delivery',
    WalletMutationState.unknownUpdate => 'unknown_update',
    WalletMutationState.unknownDelete => 'unknown_delete',
    WalletMutationState.retryScheduled => 'retry_scheduled',
    WalletMutationState.succeeded => 'succeeded',
    WalletMutationState.permanentFailure => 'permanent_failure',
    WalletMutationState.supersededBeforeSend => 'superseded_before_send',
  };
}

/// Persists [WalletItemLegRole] using plan/03 canonical snake_case values
/// (`primary`, `transfer_source`, `transfer_mirror`).
class WalletItemLegRoleConverter
    extends TypeConverter<WalletItemLegRole, String> {
  const WalletItemLegRoleConverter();

  @override
  WalletItemLegRole fromSql(String fromDb) => switch (fromDb) {
    'primary' => WalletItemLegRole.primary,
    'transfer_source' => WalletItemLegRole.transferSource,
    'transfer_mirror' => WalletItemLegRole.transferMirror,
    _ => throw ArgumentError.value(
      fromDb,
      'fromDb',
      'Unknown WalletItemLegRole',
    ),
  };

  @override
  String toSql(WalletItemLegRole value) => switch (value) {
    WalletItemLegRole.primary => 'primary',
    WalletItemLegRole.transferSource => 'transfer_source',
    WalletItemLegRole.transferMirror => 'transfer_mirror',
  };
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

  IntColumn get smsDisclosureRevision => integer().nullable()();
  BoolColumn get historySmsEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get historyWindowDays => integer().withDefault(const Constant(7))();
  IntColumn get historyMessageCap =>
      integer().withDefault(const Constant(100))();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};

  @override
  String get tableName => 'app_settings';
}

/// One parser family per sender is no longer the rule: a sender legitimately
/// emits card and account messages (plan/03:7). Uniqueness is the composite
/// (sender_hash, parser_family); [priority] ranks families for one sender
/// (plan/03:203-211). The column is named `sender_hash` for legacy continuity
/// but holds the normalized matching key, never a hash (M4.14 §3.3).
@TableIndex(
  name: 'idx_parser_rules_sender_family',
  columns: {#senderHash, #parserFamily},
  unique: true,
)
class SenderRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get senderHash => text()();
  TextColumn get parserFamily => text()();
  IntColumn get createdAtEpochMs => integer()();
  IntColumn get priority => integer().withDefault(const Constant(0))();

  TextColumn get parserVersion => text().nullable()();
  TextColumn get parserChecksum => text().nullable()();

  @override
  String get tableName => 'parser_rules';
}

/// Tracked SMS senders as a table — joinable against `sms_events.sender_key`,
/// indexable, and able to carry a per-sender rule-pack hint. Migrated out of
/// the `schema_metadata` JSON blob in v7 (M4.14 §3.4).
@DataClassName('TrackedSenderRow')
class TrackedSenders extends Table {
  TextColumn get senderKey => text()();
  TextColumn get senderDisplay => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get addedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {senderKey};

  @override
  String get tableName => 'tracked_senders';
}

@TableIndex(
  name: 'idx_sms_events_received_desc',
  columns: {#receivedAtEpochMs, #id},
)
@TableIndex(
  name: 'idx_sms_events_sender_received',
  columns: {#senderKey, #receivedAtEpochMs, #id},
)
class SmsEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceKey => text().unique()();

  /// Normalized matching key: trimmed, uppercased, NFC. Not a hash — renamed
  /// from `senderHash`, which never held a hash (M4.14 V6).
  TextColumn get senderKey => text()();

  /// Sender exactly as the transport reported it. Display only — never used
  /// for matching (plan/03:46).
  TextColumn get senderDisplay => text().nullable()();

  /// Full normalized original message body — the primary review display
  /// source (M4.16). Plaintext inside the SQLCipher-encrypted database;
  /// the column name is historical and predates the at-rest encryption
  /// design. Nullable: filtered OTP/unrelated rows store nothing, and the
  /// retention sweep clears it when raw-copy consent is disabled.
  TextColumn get encryptedBody => text().nullable()();

  /// Masked preview (amounts/dates/phone numbers redacted, ≤300 chars).
  /// Fallback display source when [encryptedBody] is absent, and the
  /// source for plan-mandated redacted surfaces (notifications).
  TextColumn get redactedBody => text().nullable()();
  TextColumn get ingestionSource => text()();
  IntColumn get receivedAtEpochMs => integer()();
  IntColumn get expiresAtEpochMs => integer().nullable()();
  TextColumn get status => textEnum<SmsEventStatus>()();
  IntColumn get privacyEpoch => integer()();

  IntColumn get providerRowId => integer().nullable()();
  IntColumn get captureCanonicalizationVersion =>
      integer().withDefault(const Constant(2))();
  IntColumn get redactionVersion => integer().withDefault(const Constant(1))();
  TextColumn get rawPurgeState =>
      textEnum<RawPurgeState>().withDefault(const Constant('pending'))();

  TextColumn get contentSha256 => text().nullable()();
}

class TransactionCandidates extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable text UUID decoupled from the int auto-increment PK. Autoincrement
  /// ints are unsafe to expose in `create_lineage_key` derivation across
  /// reinstall/restore (M5.1). Nullable: pre-v9 rows predate the column.
  TextColumn get candidateId => text().nullable()();

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

  TextColumn get kind => textEnum<TransactionKind>().nullable()();
  TextColumn get direction => textEnum<TransactionDirection>().nullable()();
  TextColumn get lifecycle => textEnum<FinancialLifecycle>().nullable()();
  IntColumn get originalAmountMinor => integer().nullable()();
  IntColumn get walletAmountMinor => integer().nullable()();
  IntColumn get transactionAtEpochMs => integer().nullable()();
  TextColumn get dateEvidence => text().nullable()();
  TextColumn get counterpartyRedacted => text().nullable()();
  TextColumn get instrumentSuffixHash => text().nullable()();
  IntColumn get availableBalanceMinor => integer().nullable()();
  TextColumn get paymentType => text().nullable()();
  IntColumn get confidenceBasisPoints => integer().nullable()();
  TextColumn get parserRuleId => text().nullable()();
  TextColumn get parserRuleVersion => text().nullable()();
  TextColumn get rulePackId => text().nullable()();
  TextColumn get rulePackVersion => text().nullable()();
  TextColumn get reviewReasons => text().nullable()();
  TextColumn get transactionFingerprint => text().nullable()();
}

class ActivityEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => textEnum<ActivityEventCode>()();
  TextColumn get sanitizedDetail => textEnum<ActivityStateTransition>()();
  IntColumn get occurredAtEpochMs => integer()();
  IntColumn get privacyEpoch => integer()();

  /// Optional count for aggregated batch events — e.g. one
  /// `messageImported` row per import batch instead of one per message
  /// (M4.15 WP3). Null = single-item event.
  IntColumn get batchCount => integer().nullable()();

  /// The outbox mutation this event describes (M5.14). Nullable so the column
  /// is safe for log-derived and pre-v10 rows; recovery actions read it to
  /// dispatch the REAL mutation id instead of a fabricated one.
  TextColumn get mutationId => text().nullable()();

  /// Optional human-readable detail for the activity event (M5.15 Bug 8.1).
  /// Nullable so pre-v11 rows stay valid; the UI falls back to the
  /// ActivityStateTransition enum label when null.
  TextColumn get detailMessage => text().nullable()();
}

class DecisionTraces extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get candidateId =>
      integer().nullable().references(TransactionCandidates, #id)();
  TextColumn get traceCode => textEnum<DecisionTraceCode>()();
  IntColumn get createdAtEpochMs => integer()();

  TextColumn get stage => textEnum<DecisionStage>().nullable()();
  TextColumn get rulePackVersion => text().nullable()();
  TextColumn get outcomeCode => text().nullable()();
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
  TextColumn get groupId => text().withDefault(const Constant('unknown'))();
  TextColumn get groupName => text().withDefault(const Constant('Unknown'))();
  TextColumn get parentId => text().nullable()();
  IntColumn get refreshedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_category_cache';
}

class WalletLabelCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get refreshedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_label_cache';
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

/// M5 outbox row. Widened in schema v9 from the M3 stub: the `operation_kind`,
/// `state` and dedup columns now carry the outbox state machine, and
/// `lineage_key`/`fingerprint` are reused as `create_lineage_key`/
/// `transactionFingerprint` (plan/03 §wallet_mutation, M5.1).
class WalletMutations extends Table {
  TextColumn get id => text()();
  TextColumn get operationKind => textEnum<WalletMutationOperation>()();
  TextColumn get payload => text()();
  TextColumn get state => text().map(const WalletMutationStateConverter())();
  TextColumn get lineageKey => text()();
  TextColumn get fingerprint => text()();
  IntColumn get createdAtEpochMs => integer()();
  IntColumn get updatedAtEpochMs => integer()();

  TextColumn get candidateId => text().nullable()();
  IntColumn get operationRevision => integer().nullable()();
  IntColumn get lineageGeneration => integer().nullable()();
  TextColumn get payloadJsonCiphertext => text().nullable()();
  TextColumn get sourceMarker => text().nullable()();
  IntColumn get attemptCount => integer().nullable()();
  IntColumn get nextAttemptAtEpochMs => integer().nullable()();
  IntColumn get leaseUntilEpochMs => integer().nullable()();
  IntColumn get lastHttpStatus => integer().nullable()();
  TextColumn get walletCorrelationId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_mutations';
}

/// One row per confirmed remote record/leg owned by the app. Only these links
/// authorize PATCH/DELETE. `remote_id` carries a partial unique index (not
/// null) and `remote_deleted_tombstone` marks a deleted generation (M5.1).
class WalletRecordLinks extends Table {
  TextColumn get id => text()();
  TextColumn get appId => text().unique()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get createdAtEpochMs => integer()();

  TextColumn get candidateId => text().nullable()();
  TextColumn get legRole =>
      text().map(const WalletItemLegRoleConverter()).nullable()();
  TextColumn get pairGroupId => text().nullable()();
  IntColumn get lastKnownRevision => integer().nullable()();
  TextColumn get lastKnownState => text().nullable()();
  IntColumn get updatedAtEpochMs => integer().nullable()();
  IntColumn get deletedAtEpochMs => integer().nullable()();
  BoolColumn get remoteDeletedTombstone => boolean().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'wallet_record_links';
}

/// User-owned mapping rule (plan/03 §mapping_rule). `sender_matcher` and
/// `merchant_matcher` are JSON matcher specs; `sync_mode` and `direction`
/// store enum names (M5.1).
@TableIndex(
  name: 'idx_mapping_rules_lookup',
  columns: {#senderMatcher, #parserFamily, #instrumentSuffixHash, #enabled},
)
@DataClassName('MappingRuleRow')
class MappingRules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get enabled => boolean()();
  TextColumn get senderMatcher => text()();
  TextColumn get parserFamily => text().nullable()();
  TextColumn get instrumentSuffixHash => text().nullable()();
  TextColumn get direction => textEnum<TransactionDirection>().nullable()();
  TextColumn get merchantMatcher => text().nullable()();
  TextColumn get walletAccountId => text()();
  TextColumn get walletCategoryId => text().nullable()();
  TextColumn get paymentType => text()();
  TextColumn get syncMode => textEnum<MappingSyncMode>()();
  IntColumn get priority => integer()();
  IntColumn get minConfidenceBasisPoints => integer().nullable()();
  IntColumn get ruleVersion => integer()();
  TextColumn get supersededByRuleId => text().nullable()();
  IntColumn get createdAtEpochMs => integer()();
  IntColumn get updatedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id, ruleVersion};

  @override
  String get tableName => 'mapping_rule';
}

/// One immutable item of a [WalletMutations] batch (plan/03
/// §wallet_mutation_item). `state`/`safe_error_code` are per-item because
/// Wallet batches are non-atomic (207). One mutation = one or more items.
class WalletMutationItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get walletMutationId => text().references(WalletMutations, #id)();
  IntColumn get itemIndex => integer()();
  TextColumn get legRole => text().map(const WalletItemLegRoleConverter())();
  TextColumn get walletRecordId => text().nullable()();
  IntColumn get expectedRemoteRevision => integer().nullable()();
  TextColumn get payloadCiphertext => text()();
  TextColumn get state => text().map(const WalletMutationStateConverter())();
  TextColumn get safeErrorCode => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {walletMutationId, itemIndex},
  ];

  @override
  String get tableName => 'wallet_mutation_item';
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

class RulePacks extends Table {
  TextColumn get id => text()();
  TextColumn get version => text()();
  TextColumn get checksum => text()();
  TextColumn get market => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get installedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id, version};

  @override
  String get tableName => 'rule_packs';
}

class IngestionCheckpoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingestionSource => text()();
  IntColumn get selectedFromEpochMs => integer().nullable()();
  IntColumn get selectedUntilEpochMs => integer().nullable()();
  IntColumn get selectedRangeDays => integer().nullable()();
  TextColumn get senderCursorHash => text().nullable()();
  IntColumn get dateCursorEpochMs => integer().nullable()();
  IntColumn get configuredCap => integer()();
  IntColumn get processedCount => integer().withDefault(const Constant(0))();
  IntColumn get acceptedCount => integer().withDefault(const Constant(0))();
  IntColumn get filteredCount => integer().withDefault(const Constant(0))();
  IntColumn get duplicateCount => integer().withDefault(const Constant(0))();
  TextColumn get outcome => textEnum<IngestionOutcome>().nullable()();
  IntColumn get startedAtEpochMs => integer()();
  IntColumn get completedAtEpochMs => integer().nullable()();
  IntColumn get privacyEpoch => integer()();

  @override
  String get tableName => 'ingestion_checkpoint';
}

@DriftDatabase(
  tables: [
    AppSettings,
    SenderRules,
    TrackedSenders,
    SmsEvents,
    TransactionCandidates,
    ActivityEvents,
    DecisionTraces,
    DatabaseMetadata,
    AppLockState,
    DeletionAuditEvents,
    WalletAccountCache,
    WalletCategoryCache,
    WalletLabelCache,
    WalletConnectionStatus,
    WalletMutations,
    WalletRecordLinks,
    MappingRules,
    WalletMutationItems,
    CapabilityLedger,
    RulePacks,
    IngestionCheckpoints,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.inMemoryForTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 14;

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

      // Partial unique indexes cannot be expressed in Drift's declarative
      // table syntax (M5.1). Created here with IF NOT EXISTS so fresh
      // installs and every upgrade path both get the constraints; they run
      // after onCreate/onUpgrade complete.
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS wallet_mutation_active_lineage '
        'ON wallet_mutations (candidate_id, lineage_generation) '
        "WHERE operation_kind = 'create' AND state IN "
        "('queued','syncing','reconciling','unknown_delivery',"
        "'retry_scheduled','succeeded')",
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_wallet_record_link_remote_id '
        'ON wallet_record_links (remote_id) WHERE remote_id IS NOT NULL',
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
        await m.createTable(capabilityLedger);

        // Original v3 stub shapes for the wallet tables (not the current v9
        // definition): the v9 block widens them via ALTER-add-column, so a
        // v1/v2->v9 chain must start from the stub, not the final shape.
        await customStatement(
          'CREATE TABLE wallet_mutations ('
          'id TEXT NOT NULL PRIMARY KEY, '
          'operation TEXT NOT NULL, '
          'payload TEXT NOT NULL, '
          'state TEXT NOT NULL, '
          'lineage_key TEXT NOT NULL, '
          'fingerprint TEXT NOT NULL, '
          'created_at_epoch_ms INTEGER NOT NULL, '
          'updated_at_epoch_ms INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE TABLE wallet_record_links ('
          'id TEXT NOT NULL PRIMARY KEY, '
          'app_id TEXT NOT NULL UNIQUE, '
          'remote_id TEXT, '
          'created_at_epoch_ms INTEGER NOT NULL)',
        );

        await customStatement(
          'INSERT OR IGNORE INTO wallet_connection_status '
          '(singleton_id) VALUES (1)',
        );
      }
      if (from < 4) {
        await m.addColumn(appSettings, appSettings.rawCopyRetentionDays);
        await m.addColumn(appSettings, appSettings.activityRetentionDays);
      }
      if (from < 5) {
        await m.addColumn(appSettings, appSettings.smsDisclosureRevision);
        await m.addColumn(appSettings, appSettings.historySmsEnabled);
        await m.addColumn(appSettings, appSettings.historyWindowDays);
        await m.addColumn(appSettings, appSettings.historyMessageCap);

        await m.addColumn(smsEvents, smsEvents.providerRowId);
        await m.addColumn(smsEvents, smsEvents.captureCanonicalizationVersion);
        await m.addColumn(smsEvents, smsEvents.redactionVersion);
        await m.addColumn(smsEvents, smsEvents.rawPurgeState);

        await m.addColumn(transactionCandidates, transactionCandidates.kind);
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.direction,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.lifecycle,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.originalAmountMinor,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.walletAmountMinor,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.transactionAtEpochMs,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.dateEvidence,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.counterpartyRedacted,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.instrumentSuffixHash,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.availableBalanceMinor,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.paymentType,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.confidenceBasisPoints,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.parserRuleId,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.parserRuleVersion,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.rulePackId,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.rulePackVersion,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.reviewReasons,
        );
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.transactionFingerprint,
        );

        await m.addColumn(decisionTraces, decisionTraces.stage);
        await m.addColumn(decisionTraces, decisionTraces.rulePackVersion);
        await m.addColumn(decisionTraces, decisionTraces.outcomeCode);

        await m.createTable(rulePacks);
        await m.createTable(ingestionCheckpoints);

        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sms_events_received_at '
          'ON sms_events (received_at_epoch_ms DESC)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sms_events_purge '
          'ON sms_events (raw_purge_state, expires_at_epoch_ms)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sms_events_provider_alias '
          'ON sms_events (provider_row_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_candidates_state '
          'ON transaction_candidates (state, created_at_epoch_ms DESC)',
        );
      }
      if (from < 6) {
        await m.addColumn(smsEvents, smsEvents.contentSha256);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sms_events_content_sha256 '
          'ON sms_events (content_sha256)',
        );
      }
      if (from < 7) {
        // 3.1 sender columns: sender_hash held plaintext (never a hash), so
        // rename it to what it is and add the display form (M4.14 V6/V5).
        await m.renameColumn(smsEvents, 'sender_hash', smsEvents.senderKey);
        await m.addColumn(smsEvents, smsEvents.senderDisplay);
        await customStatement(
          'UPDATE sms_events SET sender_display = sender_key '
          'WHERE sender_display IS NULL',
        );

        // 3.2 close the status enum: map anything unrecognised to a member.
        await customStatement(
          "UPDATE sms_events SET status = 'captured' "
          "WHERE status NOT IN "
          "('captured','review','interpreted','ignored','purged')",
        );

        // 3.3 parser_rules: the UNIQUE on sender_hash forbids two families for
        // one sender. SQLite cannot drop a column constraint without a table
        // rebuild, so rebuild with priority + composite unique (M4.14 §3.3).
        await customStatement('DROP TABLE IF EXISTS parser_rules_new');
        await customStatement(
          'CREATE TABLE parser_rules_new ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          'sender_hash TEXT NOT NULL, '
          'parser_family TEXT NOT NULL, '
          'created_at_epoch_ms INTEGER NOT NULL, '
          'parser_version TEXT, '
          'parser_checksum TEXT, '
          'priority INTEGER NOT NULL DEFAULT 0)',
        );
        await customStatement(
          'INSERT INTO parser_rules_new (id, sender_hash, parser_family, '
          'created_at_epoch_ms, parser_version, parser_checksum) '
          'SELECT id, sender_hash, parser_family, created_at_epoch_ms, '
          'parser_version, parser_checksum FROM parser_rules',
        );
        await customStatement('DROP TABLE parser_rules');
        await customStatement(
          'ALTER TABLE parser_rules_new RENAME TO parser_rules',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_parser_rules_sender_family '
          'ON parser_rules (sender_hash, parser_family)',
        );

        // 3.4 tracked senders: promote the schema_metadata JSON blob to a
        // table, then delete the metadata key so there is one owner.
        await m.createTable(trackedSenders);
        final trackedRows = await customSelect(
          'SELECT value FROM schema_metadata WHERE key = ?',
          variables: [Variable('tracked_senders')],
        ).get();
        if (trackedRows.isNotEmpty) {
          final now = DateTime.now().millisecondsSinceEpoch;
          for (final address in TrackedSendersQuery.decode(
            trackedRows.first.read<String>('value'),
          )) {
            await into(trackedSenders).insert(
              TrackedSendersCompanion.insert(
                senderKey: address,
                addedAtEpochMs: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
          await (delete(
            databaseMetadata,
          )..where((t) => t.key.equals('tracked_senders'))).go();
        }

        // WP4: existing rows keep their v1-era keys; only new rows get
        // version 2. The v5 migration applied the current default (2) to all
        // rows, so normalise genuine v1 keys back to 1.
        await customStatement(
          "UPDATE sms_events SET capture_canonicalization_version = 1 "
          "WHERE source_key LIKE 'v1_%'",
        );

        // WP2 keyset pagination indexes.
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sms_events_received_desc '
          'ON sms_events (received_at_epoch_ms DESC, id DESC)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sms_events_sender_received '
          'ON sms_events (sender_key, received_at_epoch_ms DESC, id DESC)',
        );
      }
      if (from < 8) {
        // M4.15 WP3: aggregated batch events carry an optional count.
        await m.addColumn(activityEvents, activityEvents.batchCount);
      }
      if (from < 9) {
        // M5.1: rename the M3 stub `operation` column to `operation_kind`
        // (plan/03 §wallet_mutation) so the raw-SQL partial unique index can
        // match `operation_kind='create'`.
        await m.renameColumn(
          walletMutations,
          'operation',
          walletMutations.operationKind,
        );

        // Widen wallet_mutations via ALTER-add-column (not recreate-and-copy:
        // v8 rows here are stub placeholders with no real create traffic).
        await m.addColumn(walletMutations, walletMutations.candidateId);
        await m.addColumn(walletMutations, walletMutations.operationRevision);
        await m.addColumn(walletMutations, walletMutations.lineageGeneration);
        await m.addColumn(
          walletMutations,
          walletMutations.payloadJsonCiphertext,
        );
        await m.addColumn(walletMutations, walletMutations.sourceMarker);
        await m.addColumn(walletMutations, walletMutations.attemptCount);
        await m.addColumn(
          walletMutations,
          walletMutations.nextAttemptAtEpochMs,
        );
        await m.addColumn(walletMutations, walletMutations.leaseUntilEpochMs);
        await m.addColumn(walletMutations, walletMutations.lastHttpStatus);
        await m.addColumn(walletMutations, walletMutations.walletCorrelationId);

        // Widen wallet_record_links.
        await m.addColumn(walletRecordLinks, walletRecordLinks.candidateId);
        await m.addColumn(walletRecordLinks, walletRecordLinks.legRole);
        await m.addColumn(walletRecordLinks, walletRecordLinks.pairGroupId);
        await m.addColumn(
          walletRecordLinks,
          walletRecordLinks.lastKnownRevision,
        );
        await m.addColumn(walletRecordLinks, walletRecordLinks.lastKnownState);
        await m.addColumn(
          walletRecordLinks,
          walletRecordLinks.updatedAtEpochMs,
        );
        await m.addColumn(
          walletRecordLinks,
          walletRecordLinks.deletedAtEpochMs,
        );
        await m.addColumn(
          walletRecordLinks,
          walletRecordLinks.remoteDeletedTombstone,
        );

        // Stable text candidateId on TransactionCandidates.
        await m.addColumn(
          transactionCandidates,
          transactionCandidates.candidateId,
        );

        // New tables.
        await m.createTable(mappingRules);
        await m.createTable(walletMutationItems);
      }
      if (from < 10) {
        // M5.14 gap 5: recovery actions must dispatch the REAL mutation id.
        // Nullable so log-derived and pre-v10 rows stay valid.
        await m.addColumn(activityEvents, activityEvents.mutationId);
      }
      if (from < 11) {
        // M5.15 Bug 8.1: human-readable detail for activity events.
        // Nullable so pre-v11 rows stay valid.
        await m.addColumn(activityEvents, activityEvents.detailMessage);
      }
      if (from >= 3 && from < 12) {
        // M5.17 WP1: hierarchical category model — group + parent columns.
        // Only needed when upgrading from v3–v11; fresh installs and v1→v12
        // get the columns from m.createTable(walletCategoryCache) in the
        // from < 3 block which uses the current table definition.
        await m.addColumn(walletCategoryCache, walletCategoryCache.groupId);
        await m.addColumn(walletCategoryCache, walletCategoryCache.groupName);
        await m.addColumn(walletCategoryCache, walletCategoryCache.parentId);
      }
      if (from < 13) {
        // M5.18: fix activity_events event_type values stored as wireValues
        // (e.g. 'wallet.record.created') instead of enum names ('walletRecordCreated').
        // The textEnum converter expects enum .name, not .wireValue.
        await customStatement(
          "UPDATE activity_events SET event_type = 'walletRecordCreated' "
          "WHERE event_type = 'wallet.record.created'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'candidateNeedsReview' "
          "WHERE event_type = 'candidate.needs_review'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'walletConnected' "
          "WHERE event_type = 'wallet.connected'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'walletDisconnected' "
          "WHERE event_type = 'wallet.disconnected'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'walletRefreshed' "
          "WHERE event_type = 'wallet.refreshed'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'mappingRuleCreated' "
          "WHERE event_type = 'mapping_rule.created'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'messageImported' "
          "WHERE event_type = 'sms.message.imported'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'smsEventDeleted' "
          "WHERE event_type = 'sms.message.deleted'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'logInfo' "
          "WHERE event_type = 'app.log.info'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'logWarning' "
          "WHERE event_type = 'app.log.warning'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'logError' "
          "WHERE event_type = 'app.log.error'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'privacyEpochAdvanced' "
          "WHERE event_type = 'privacy.epoch.advanced'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'rawCopyPurged' "
          "WHERE event_type = 'privacy.raw_copy.purged'",
        );
        await customStatement(
          "UPDATE activity_events SET event_type = 'activityRetentionApplied' "
          "WHERE event_type = 'privacy.activity_retention.applied'",
        );
      }
      if (from < 14) {
        await m.createTable(walletLabelCache);
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

  /// Newest-first page of events strictly older than the cursor.
  /// Pass a null cursor for the first page. [senderKey] restricts to one
  /// sender (grouped layout). Keyset pagination: (receivedAtEpochMs DESC,
  /// id DESC) — never OFFSET, which shifts under concurrent inserts.
  /// [fromReceivedAtEpochMs]/[untilReceivedAtEpochMs] bound the window
  /// (M4.15 WP2 filters).
  Future<List<SmsEvent>> smsEventsPage({
    required int limit,
    String? senderKey,
    int? fromReceivedAtEpochMs,
    int? untilReceivedAtEpochMs,
    int? beforeReceivedAtEpochMs,
    int? beforeId,
  }) => _smsEventsSelect(
    limit: limit,
    senderKey: senderKey,
    fromReceivedAtEpochMs: fromReceivedAtEpochMs,
    untilReceivedAtEpochMs: untilReceivedAtEpochMs,
    beforeReceivedAtEpochMs: beforeReceivedAtEpochMs,
    beforeId: beforeId,
  ).get();

  /// Live first page for the inbox stream; same ordering, limit and filter
  /// semantics as [smsEventsPage], re-emits on every write (M4.14 WP1 +
  /// M4.15 WP2).
  Stream<List<SmsEvent>> watchSmsEventsPage({
    required int limit,
    String? senderKey,
    int? fromReceivedAtEpochMs,
    int? untilReceivedAtEpochMs,
  }) => _smsEventsSelect(
    limit: limit,
    senderKey: senderKey,
    fromReceivedAtEpochMs: fromReceivedAtEpochMs,
    untilReceivedAtEpochMs: untilReceivedAtEpochMs,
  ).watch();

  Selectable<SmsEvent> _smsEventsSelect({
    required int limit,
    String? senderKey,
    int? fromReceivedAtEpochMs,
    int? untilReceivedAtEpochMs,
    int? beforeReceivedAtEpochMs,
    int? beforeId,
  }) {
    final q = select(smsEvents)
      ..orderBy([
        (t) => OrderingTerm.desc(t.receivedAtEpochMs),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(limit);
    final hasCursor = beforeReceivedAtEpochMs != null && beforeId != null;
    if (senderKey != null ||
        fromReceivedAtEpochMs != null ||
        untilReceivedAtEpochMs != null ||
        hasCursor) {
      q.where((t) {
        final conditions = <Expression<bool>>[
          if (senderKey != null) t.senderKey.equals(senderKey),
          if (fromReceivedAtEpochMs != null)
            t.receivedAtEpochMs.isBiggerOrEqualValue(fromReceivedAtEpochMs),
          if (untilReceivedAtEpochMs != null)
            t.receivedAtEpochMs.isSmallerOrEqualValue(untilReceivedAtEpochMs),
          if (hasCursor)
            t.receivedAtEpochMs.isSmallerThanValue(beforeReceivedAtEpochMs) |
                (t.receivedAtEpochMs.equals(beforeReceivedAtEpochMs) &
                    t.id.isSmallerThanValue(beforeId)),
        ];
        return conditions.fold<Expression<bool>>(
          conditions.removeAt(0),
          (a, b) => a & b,
        );
      });
    }
    return q;
  }

  /// One stored message by its app id (M4.15 WP1 detail view).
  Future<SmsEvent?> getSmsEventById(int id) =>
      (select(smsEvents)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// The candidate record for one message, when the ingest produced one.
  Future<TransactionCandidate?> getCandidateBySmsEventId(int smsEventId) =>
      (select(
        transactionCandidates,
      )..where((t) => t.smsEventId.equals(smsEventId))).getSingleOrNull();

  /// Sender headers with true totals for the grouped inbox — the `Show all
  /// (N)` count must never lie about N (M4.14 WP2).
  Stream<List<SmsEventSenderSummary>> watchSmsEventSenderSummaries() {
    return customSelect(
      'SELECT sender_key AS sender_key, '
      'MAX(sender_display) AS sender_display, COUNT(*) AS total '
      'FROM sms_events GROUP BY sender_key '
      'ORDER BY MAX(received_at_epoch_ms) DESC',
      readsFrom: {smsEvents},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          SmsEventSenderSummary(
            senderKey: row.read<String>('sender_key'),
            senderDisplay: row.read<String?>('sender_display'),
            total: row.read<int>('total'),
          ),
      ],
    );
  }

  Future<SmsEventInsertResult> insertSmsEventIfAbsent({
    required String sourceKey,
    required String senderKey,
    String? senderDisplay,
    String? encryptedBody,
    String? redactedBody,
    required String ingestionSource,
    required int receivedAtEpochMs,
    int? expiresAtEpochMs,
    required SmsEventStatus status,
    required int privacyEpoch,
    required int captureCanonicalizationVersion,
    String? contentSha256,
  }) async {
    return transaction(() async {
      await _requireCurrentPrivacyEpoch(privacyEpoch);

      // Identity is decided by sourceKey only. The content hash never
      // suppresses an insert — identical-body messages at different times are
      // distinct transactions and must both store (M4.14 WP4).
      final inserted = await into(smsEvents).insertReturningOrNull(
        SmsEventsCompanion.insert(
          sourceKey: sourceKey,
          senderKey: senderKey,
          senderDisplay: Value(senderDisplay),
          encryptedBody: Value(encryptedBody),
          redactedBody: Value(redactedBody),
          ingestionSource: ingestionSource,
          receivedAtEpochMs: receivedAtEpochMs,
          expiresAtEpochMs: Value(expiresAtEpochMs),
          status: status,
          privacyEpoch: privacyEpoch,
          captureCanonicalizationVersion: Value(captureCanonicalizationVersion),
          contentSha256: Value(contentSha256),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      if (inserted != null) {
        var duplicateSuspected = false;
        if (contentSha256 != null) {
          final duplicate =
              await (select(smsEvents)..where(
                    (t) =>
                        t.contentSha256.equals(contentSha256) &
                        t.id.equals(inserted.id).not(),
                  ))
                  .getSingleOrNull();
          duplicateSuspected = duplicate != null;
        }
        return SmsEventInsertResult(
          id: inserted.id,
          inserted: true,
          duplicateSuspected: duplicateSuspected,
        );
      }
      final existing = await (select(
        smsEvents,
      )..where((row) => row.sourceKey.equals(sourceKey))).getSingle();
      return SmsEventInsertResult(
        id: existing.id,
        inserted: false,
        duplicateSuspected: false,
      );
    });
  }

  /// Records one sanitized activity event (no candidate, no trace).
  /// [count] aggregates a batch (M4.15 WP3) — null for single-item events.
  /// [detailMessage] is an optional human-readable detail (M5.15 Bug 8.1).
  Future<void> insertActivity({
    required ActivityEventCode activityType,
    required ActivityStateTransition safeDetailCode,
    required int occurredAtEpochMs,
    required int privacyEpoch,
    int? count,
    String? detailMessage,
  }) {
    return transaction(() async {
      await _requireCurrentPrivacyEpoch(privacyEpoch);
      await into(activityEvents).insert(
        ActivityEventsCompanion.insert(
          eventType: activityType,
          sanitizedDetail: safeDetailCode,
          occurredAtEpochMs: occurredAtEpochMs,
          privacyEpoch: privacyEpoch,
          batchCount: Value(count),
          detailMessage: Value(detailMessage),
        ),
      );
    });
  }

  /// Deletes one imported message (app copy) with its candidate and decision
  /// traces. Never touches the Android SMS provider. Returns false when the
  /// event does not exist (or the epoch is stale — caller decides).
  Future<bool> deleteSmsEvent({
    required int eventId,
    required int privacyEpoch,
  }) async {
    return transaction(() async {
      await _requireCurrentPrivacyEpoch(privacyEpoch);
      // FK order: traces -> candidates -> event.
      final candidates = await (select(
        transactionCandidates,
      )..where((row) => row.smsEventId.equals(eventId))).get();
      for (final candidate in candidates) {
        await (delete(
          decisionTraces,
        )..where((row) => row.candidateId.equals(candidate.id))).go();
      }
      await (delete(
        transactionCandidates,
      )..where((row) => row.smsEventId.equals(eventId))).go();
      final deleted = await (delete(
        smsEvents,
      )..where((row) => row.id.equals(eventId))).go();
      return deleted > 0;
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
    bool recordActivity = true,
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
      if (recordActivity) {
        await into(activityEvents).insert(
          ActivityEventsCompanion.insert(
            eventType: activityType,
            sanitizedDetail: safeDetailCode,
            occurredAtEpochMs: createdAtEpochMs,
            privacyEpoch: privacyEpoch,
          ),
        );
      }
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
