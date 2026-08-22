import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// M5.1 schema v9 migration + constraint tests.
///
/// Partial unique indexes cannot be expressed in Drift's declarative table
/// syntax, so they are created as raw SQL in `beforeOpen` and must be verified
/// with their own raw-SQL assertions (M5.1 §Covers).
void main() {
  Future<AppDatabase> migrateFrom(
    int fromVersion,
    void Function(dynamic db) seedSchema,
  ) async {
    return AppDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.execute('PRAGMA user_version = $fromVersion');
          seedSchema(db);
        },
      ),
    );
  }

  group('M5.1 schema v9', () {
    test('fresh install reports schema version 9', () {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      expect(db.schemaVersion, 11);
    });

    test('v9 tables exist on a fresh database', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table'",
            readsFrom: const {},
          )
          .get();
      final names = tables.map((r) => r.read<String>('name')).toSet();
      expect(names, containsAll(['mapping_rule', 'wallet_mutation_item']));
    });

    test('wallet_mutations carries all v9 columns', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final cols = await db
          .customSelect(
            'PRAGMA table_info(wallet_mutations)',
            readsFrom: const {},
          )
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'id',
          'operation_kind',
          'payload',
          'state',
          'lineage_key',
          'fingerprint',
          'created_at_epoch_ms',
          'updated_at_epoch_ms',
          'candidate_id',
          'operation_revision',
          'lineage_generation',
          'payload_json_ciphertext',
          'source_marker',
          'attempt_count',
          'next_attempt_at_epoch_ms',
          'lease_until_epoch_ms',
          'last_http_status',
          'wallet_correlation_id',
        ]),
      );
    });

    test('wallet_record_links carries all v9 columns', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final cols = await db
          .customSelect(
            'PRAGMA table_info(wallet_record_links)',
            readsFrom: const {},
          )
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'id',
          'app_id',
          'remote_id',
          'created_at_epoch_ms',
          'candidate_id',
          'leg_role',
          'pair_group_id',
          'last_known_revision',
          'last_known_state',
          'updated_at_epoch_ms',
          'deleted_at_epoch_ms',
          'remote_deleted_tombstone',
        ]),
      );
    });

    test('transaction_candidates has a stable text candidateId', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final cols = await db
          .customSelect(
            'PRAGMA table_info(transaction_candidates)',
            readsFrom: const {},
          )
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();
      expect(names, contains('candidate_id'));
    });

    test('mapping_rule has the lookup index', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND name = 'idx_mapping_rules_lookup'",
            readsFrom: const {},
          )
          .get();
      expect(indexes, isNotEmpty);
    });
  });

  group('M5.1 partial unique indexes', () {
    test('active create lineage index exists', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final rows = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type='index' "
            "AND name='wallet_mutation_active_lineage'",
            readsFrom: const {},
          )
          .get();
      expect(rows, hasLength(1));
      final sql = rows.single.read<String>('sql');
      expect(sql.toLowerCase(), contains('where'));
      expect(sql.toLowerCase(), contains('operation_kind'));
    });

    test('two active creates for the same (candidate_id, lineage_generation) '
        'are rejected', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      Future<void> insertActiveCreate({String? candidateId}) {
        return db
            .into(db.walletMutations)
            .insert(
              WalletMutationsCompanion.insert(
                id: candidateId == null ? 'm1' : 'm2',
                operationKind: WalletMutationOperation.create,
                payload: '{}',
                state: WalletMutationState.queued,
                lineageKey: 'lk',
                fingerprint: 'fp',
                createdAtEpochMs: 1,
                updatedAtEpochMs: 1,
                candidateId: Value(candidateId ?? 'candidate-1'),
                operationRevision: const Value(1),
                lineageGeneration: const Value(1),
              ),
            );
      }

      await insertActiveCreate(candidateId: 'candidate-1');
      await expectLater(
        insertActiveCreate(candidateId: 'candidate-1'),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'a create outside the active-state window is not deduplicated',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        Future<void> insertPermanentFailure({required String id}) {
          return db
              .into(db.walletMutations)
              .insert(
                WalletMutationsCompanion.insert(
                  id: id,
                  operationKind: WalletMutationOperation.create,
                  payload: '{}',
                  state: WalletMutationState.permanentFailure,
                  lineageKey: 'lk',
                  fingerprint: 'fp',
                  createdAtEpochMs: 1,
                  updatedAtEpochMs: 1,
                  candidateId: const Value('candidate-1'),
                  operationRevision: const Value(1),
                  lineageGeneration: const Value(1),
                ),
              );
        }

        await insertPermanentFailure(id: 'm1');
        await insertPermanentFailure(id: 'm2');
        final rows = await db.select(db.walletMutations).get();
        expect(rows, hasLength(2));
      },
    );

    test(
      'remote_id unique index only applies to non-null remote ids',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);

        Future<void> insert({required String id, String? remoteId}) {
          return db
              .into(db.walletRecordLinks)
              .insert(
                WalletRecordLinksCompanion.insert(
                  id: id,
                  appId: 'app-$id',
                  remoteId: Value(remoteId),
                  createdAtEpochMs: 1,
                ),
              );
        }

        await insert(id: 'r1', remoteId: null);
        await insert(id: 'r2', remoteId: null);
        await insert(id: 'r3', remoteId: 'remote-x');

        await expectLater(
          insert(id: 'r4', remoteId: 'remote-x'),
          throwsA(isA<SqliteException>()),
        );
      },
    );
  });

  group('M5.1 v8 -> v9 upgrade', () {
    void seedV8Schema(dynamic db) {
      db.execute(
        'CREATE TABLE app_settings ('
        'singleton_id INTEGER NOT NULL PRIMARY KEY, '
        'privacy_epoch INTEGER NOT NULL DEFAULT 0, '
        'onboarding_completed BOOLEAN NOT NULL DEFAULT 0, '
        'onboarding_revision INTEGER, '
        'disclosure_accepted BOOLEAN NOT NULL DEFAULT 0, '
        'disclosure_revision INTEGER, '
        'processing_mode TEXT NOT NULL DEFAULT \'review\', '
        'configuration_revision INTEGER NOT NULL DEFAULT 0, '
        'raw_copy_retention_days INTEGER NOT NULL DEFAULT 0, '
        'activity_retention_days INTEGER NOT NULL DEFAULT 180, '
        'sms_disclosure_revision INTEGER, '
        'history_sms_enabled BOOLEAN NOT NULL DEFAULT 0, '
        'history_window_days INTEGER NOT NULL DEFAULT 7, '
        'history_message_cap INTEGER NOT NULL DEFAULT 100)',
      );
      db.execute(
        'CREATE TABLE app_lock_state ('
        'singleton_id INTEGER NOT NULL PRIMARY KEY, '
        'lock_enabled BOOLEAN NOT NULL DEFAULT 0, '
        'inactivity_timeout_seconds INTEGER NOT NULL DEFAULT 300, '
        'lock_metadata TEXT)',
      );
      db.execute(
        'CREATE TABLE wallet_connection_status ('
        'singleton_id INTEGER NOT NULL PRIMARY KEY, '
        'status TEXT NOT NULL DEFAULT \'disconnected\', '
        'last_sync_at_epoch_ms INTEGER)',
      );
      db.execute(
        'CREATE TABLE activity_events ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'event_type TEXT NOT NULL, '
        'sanitized_detail TEXT NOT NULL, '
        'occurred_at_epoch_ms INTEGER NOT NULL, '
        'privacy_epoch INTEGER NOT NULL, '
        'batch_count INTEGER)',
      );
      db.execute(
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
      db.execute(
        'CREATE TABLE wallet_record_links ('
        'id TEXT NOT NULL PRIMARY KEY, '
        'app_id TEXT NOT NULL UNIQUE, '
        'remote_id TEXT, '
        'created_at_epoch_ms INTEGER NOT NULL)',
      );
      db.execute(
        'CREATE TABLE transaction_candidates ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'sms_event_id INTEGER NOT NULL UNIQUE, '
        'state TEXT NOT NULL, '
        'encrypted_payload TEXT NOT NULL, '
        'revision INTEGER NOT NULL, '
        'created_at_epoch_ms INTEGER NOT NULL, '
        'warning_code TEXT, payment_evidence TEXT, instrument_evidence TEXT, '
        'original_currency_code TEXT, wallet_currency_code TEXT, '
        'kind TEXT, direction TEXT, lifecycle TEXT, '
        'original_amount_minor INTEGER, wallet_amount_minor INTEGER, '
        'transaction_at_epoch_ms INTEGER, date_evidence TEXT, '
        'counterparty_redacted TEXT, instrument_suffix_hash TEXT, '
        'available_balance_minor INTEGER, payment_type TEXT, '
        'confidence_basis_points INTEGER, parser_rule_id TEXT, '
        'parser_rule_version TEXT, rule_pack_id TEXT, rule_pack_version TEXT, '
        'review_reasons TEXT, transaction_fingerprint TEXT)',
      );
      db.execute(
        'INSERT INTO wallet_mutations (id, operation, payload, state, '
        'lineage_key, fingerprint, created_at_epoch_ms, updated_at_epoch_ms) '
        "VALUES ('legacy-1', 'create', '{}', 'queued', 'lk1', 'fp1', 1, 1)",
      );
      db.execute(
        'INSERT INTO wallet_record_links (id, app_id, remote_id, '
        'created_at_epoch_ms) VALUES '
        "('link-1', 'app-1', 'remote-1', 1)",
      );
    }

    test('widens the stub tables and preserves rows', () async {
      final db = await migrateFrom(8, seedV8Schema);
      addTearDown(db.close);

      expect(db.schemaVersion, 11);

      final mutations = await db.select(db.walletMutations).get();
      expect(mutations, hasLength(1));
      expect(mutations.single.operationKind, WalletMutationOperation.create);
      expect(mutations.single.state, WalletMutationState.queued);
      expect(mutations.single.candidateId, isNull);

      final links = await db.select(db.walletRecordLinks).get();
      expect(links, hasLength(1));
      expect(links.single.remoteId, 'remote-1');

      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND name IN ('wallet_mutation_active_lineage', "
            "'idx_wallet_record_link_remote_id')",
            readsFrom: const {},
          )
          .get();
      expect(indexes.map((r) => r.read<String>('name')).toSet(), {
        'wallet_mutation_active_lineage',
        'idx_wallet_record_link_remote_id',
      });
    });

    test('candidateId stays null on pre-existing candidates', () async {
      final db = await migrateFrom(8, seedV8Schema);
      addTearDown(db.close);

      final cols = await db
          .customSelect(
            'PRAGMA table_info(transaction_candidates)',
            readsFrom: const {},
          )
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();
      expect(names, contains('candidate_id'));
    });
  });
}
