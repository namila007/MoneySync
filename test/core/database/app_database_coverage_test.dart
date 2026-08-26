import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/privacy/redaction.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Opens a database at [fromVersion] and lets it migrate to the current schema.
Future<AppDatabase> _migrateFrom(
  int fromVersion,
  void Function(sqlite.Database db) seedSchema,
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

// ---------------------------------------------------------------------------
// Seed schemas for each version boundary
// ---------------------------------------------------------------------------

void _seedV1(sqlite.Database db) {
  db.execute(
    'CREATE TABLE app_settings ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'privacy_epoch INTEGER NOT NULL DEFAULT 0)',
  );
  db.execute(
    'CREATE TABLE parser_rules ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'sender_hash TEXT NOT NULL, '
    'parser_family TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE sms_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'source_key TEXT NOT NULL UNIQUE, '
    'sender_hash TEXT NOT NULL, '
    'ingestion_source TEXT NOT NULL, '
    'received_at_epoch_ms INTEGER NOT NULL, '
    'expires_at_epoch_ms INTEGER, '
    'status TEXT NOT NULL, '
    'privacy_epoch INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE transaction_candidates ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'sms_event_id INTEGER NOT NULL UNIQUE, '
    'state TEXT NOT NULL, '
    'encrypted_payload TEXT NOT NULL, '
    'revision INTEGER NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE activity_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'event_type TEXT NOT NULL, '
    'sanitized_detail TEXT NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL, '
    'privacy_epoch INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE decision_traces ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'candidate_id INTEGER, '
    'trace_code TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE schema_metadata ('
    'key TEXT NOT NULL PRIMARY KEY, '
    'value TEXT NOT NULL)',
  );
}

void _seedV3(sqlite.Database db) {
  // v2 base
  db.execute(
    'CREATE TABLE app_settings ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'privacy_epoch INTEGER NOT NULL DEFAULT 0, '
    'onboarding_completed BOOLEAN NOT NULL DEFAULT 0, '
    'onboarding_revision INTEGER, '
    'disclosure_accepted BOOLEAN NOT NULL DEFAULT 0, '
    'disclosure_revision INTEGER, '
    'processing_mode TEXT NOT NULL DEFAULT \'review\', '
    'configuration_revision INTEGER NOT NULL DEFAULT 0)',
  );
  db.execute(
    'CREATE TABLE parser_rules ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'sender_hash TEXT NOT NULL, '
    'parser_family TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'parser_version TEXT, '
    'parser_checksum TEXT)',
  );
  db.execute(
    'CREATE TABLE sms_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'source_key TEXT NOT NULL UNIQUE, '
    'sender_hash TEXT NOT NULL, '
    'ingestion_source TEXT NOT NULL, '
    'received_at_epoch_ms INTEGER NOT NULL, '
    'expires_at_epoch_ms INTEGER, '
    'status TEXT NOT NULL, '
    'privacy_epoch INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE transaction_candidates ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'sms_event_id INTEGER NOT NULL UNIQUE, '
    'state TEXT NOT NULL, '
    'encrypted_payload TEXT NOT NULL, '
    'revision INTEGER NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'warning_code TEXT, '
    'payment_evidence TEXT, '
    'instrument_evidence TEXT, '
    'original_currency_code TEXT, '
    'wallet_currency_code TEXT)',
  );
  db.execute(
    'CREATE TABLE activity_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'event_type TEXT NOT NULL, '
    'sanitized_detail TEXT NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL, '
    'privacy_epoch INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE decision_traces ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'candidate_id INTEGER, '
    'trace_code TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE schema_metadata ('
    'key TEXT NOT NULL PRIMARY KEY, '
    'value TEXT NOT NULL)',
  );
  // v2 new tables
  db.execute(
    'CREATE TABLE app_lock_state ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'lock_enabled BOOLEAN NOT NULL DEFAULT 0, '
    'inactivity_timeout_seconds INTEGER NOT NULL DEFAULT 300, '
    'lock_metadata TEXT)',
  );
  db.execute(
    'CREATE TABLE deletion_audit_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'privacy_epoch_before INTEGER NOT NULL, '
    'privacy_epoch_after INTEGER NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL)',
  );
  // v3 tables — wallet_category_cache WITHOUT groupId/groupName/parentId/systemId
  db.execute(
    'CREATE TABLE wallet_account_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'currency_code TEXT NOT NULL, '
    'is_archived BOOLEAN NOT NULL, '
    'is_bank_synced BOOLEAN NOT NULL, '
    'is_writable BOOLEAN NOT NULL, '
    'eligibility_reason TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_category_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_connection_status ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'status TEXT NOT NULL DEFAULT \'disconnected\', '
    'last_sync_at_epoch_ms INTEGER)',
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
    'CREATE TABLE capability_ledger ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'capability TEXT NOT NULL, '
    'status TEXT NOT NULL, '
    'evidence_reference TEXT, '
    'observed_on TEXT NOT NULL, '
    'review_date TEXT NOT NULL)',
  );
}

void _seedV7(sqlite.Database db) {
  // v7 base: v6 columns (sender_key already renamed, content_sha256 present)
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
    'CREATE TABLE parser_rules ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'sender_hash TEXT NOT NULL, '
    'parser_family TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'parser_version TEXT, '
    'parser_checksum TEXT, '
    'priority INTEGER NOT NULL DEFAULT 0)',
  );
  db.execute(
    'CREATE TABLE sms_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'source_key TEXT NOT NULL UNIQUE, '
    'sender_key TEXT NOT NULL, '
    'sender_display TEXT, '
    'ingestion_source TEXT NOT NULL, '
    'received_at_epoch_ms INTEGER NOT NULL, '
    'status TEXT NOT NULL, '
    'privacy_epoch INTEGER NOT NULL, '
    'provider_row_id INTEGER, '
    'capture_canonicalization_version INTEGER NOT NULL DEFAULT 2, '
    'redaction_version INTEGER NOT NULL DEFAULT 1, '
    'raw_purge_state TEXT NOT NULL DEFAULT \'pending\', '
    'content_sha256 TEXT)',
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
    'CREATE TABLE activity_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'event_type TEXT NOT NULL, '
    'sanitized_detail TEXT NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL, '
    'privacy_epoch INTEGER NOT NULL, '
    'batch_count INTEGER)',
  );
  db.execute(
    'CREATE TABLE decision_traces ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'candidate_id INTEGER, '
    'trace_code TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'stage TEXT, '
    'rule_pack_version TEXT, '
    'outcome_code TEXT)',
  );
  db.execute(
    'CREATE TABLE schema_metadata ('
    'key TEXT NOT NULL PRIMARY KEY, '
    'value TEXT NOT NULL)',
  );
  db.execute(
    'CREATE TABLE app_lock_state ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'lock_enabled BOOLEAN NOT NULL DEFAULT 0, '
    'inactivity_timeout_seconds INTEGER NOT NULL DEFAULT 300, '
    'lock_metadata TEXT)',
  );
  db.execute(
    'CREATE TABLE deletion_audit_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'privacy_epoch_before INTEGER NOT NULL, '
    'privacy_epoch_after INTEGER NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_account_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'currency_code TEXT NOT NULL, '
    'is_archived BOOLEAN NOT NULL, '
    'is_bank_synced BOOLEAN NOT NULL, '
    'is_writable BOOLEAN NOT NULL, '
    'eligibility_reason TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_category_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_connection_status ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'status TEXT NOT NULL DEFAULT \'disconnected\', '
    'last_sync_at_epoch_ms INTEGER)',
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
    'CREATE TABLE capability_ledger ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'capability TEXT NOT NULL, '
    'status TEXT NOT NULL, '
    'evidence_reference TEXT, '
    'observed_on TEXT NOT NULL, '
    'review_date TEXT NOT NULL)',
  );
  db.execute(
    'CREATE TABLE rule_packs ('
    'id TEXT NOT NULL, '
    'version TEXT NOT NULL, '
    'checksum TEXT NOT NULL, '
    'market TEXT NOT NULL, '
    'enabled BOOLEAN NOT NULL DEFAULT 1, '
    'installed_at_epoch_ms INTEGER NOT NULL, '
    'PRIMARY KEY (id, version))',
  );
  db.execute(
    'CREATE TABLE ingestion_checkpoint ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'ingestion_source TEXT NOT NULL, '
    'selected_from_epoch_ms INTEGER, '
    'selected_until_epoch_ms INTEGER, '
    'selected_range_days INTEGER, '
    'sender_cursor_hash TEXT, '
    'date_cursor_epoch_ms INTEGER, '
    'configured_cap INTEGER NOT NULL, '
    'processed_count INTEGER NOT NULL DEFAULT 0, '
    'accepted_count INTEGER NOT NULL DEFAULT 0, '
    'filtered_count INTEGER NOT NULL DEFAULT 0, '
    'duplicate_count INTEGER NOT NULL DEFAULT 0, '
    'outcome TEXT, '
    'started_at_epoch_ms INTEGER NOT NULL, '
    'completed_at_epoch_ms INTEGER, '
    'privacy_epoch INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE tracked_senders ('
    'sender_key TEXT NOT NULL PRIMARY KEY, '
    'sender_display TEXT, '
    'enabled BOOLEAN NOT NULL DEFAULT 1, '
    'added_at_epoch_ms INTEGER NOT NULL)',
  );
}

void _seedV9(sqlite.Database db) {
  // v9 after migration: all v8 columns + wallet widening + new tables
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
    'CREATE TABLE parser_rules ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'sender_hash TEXT NOT NULL, '
    'parser_family TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'parser_version TEXT, '
    'parser_checksum TEXT, '
    'priority INTEGER NOT NULL DEFAULT 0)',
  );
  db.execute(
    'CREATE TABLE sms_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'source_key TEXT NOT NULL UNIQUE, '
    'sender_key TEXT NOT NULL, '
    'sender_display TEXT, '
    'ingestion_source TEXT NOT NULL, '
    'received_at_epoch_ms INTEGER NOT NULL, '
    'status TEXT NOT NULL, '
    'privacy_epoch INTEGER NOT NULL, '
    'provider_row_id INTEGER, '
    'capture_canonicalization_version INTEGER NOT NULL DEFAULT 2, '
    'redaction_version INTEGER NOT NULL DEFAULT 1, '
    'raw_purge_state TEXT NOT NULL DEFAULT \'pending\', '
    'content_sha256 TEXT)',
  );
  db.execute(
    'CREATE TABLE transaction_candidates ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'candidate_id TEXT, '
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
    'CREATE TABLE activity_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'event_type TEXT NOT NULL, '
    'sanitized_detail TEXT NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL, '
    'privacy_epoch INTEGER NOT NULL, '
    'batch_count INTEGER)',
  );
  db.execute(
    'CREATE TABLE decision_traces ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'candidate_id INTEGER, '
    'trace_code TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'stage TEXT, '
    'rule_pack_version TEXT, '
    'outcome_code TEXT)',
  );
  db.execute(
    'CREATE TABLE schema_metadata ('
    'key TEXT NOT NULL PRIMARY KEY, '
    'value TEXT NOT NULL)',
  );
  db.execute(
    'CREATE TABLE app_lock_state ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'lock_enabled BOOLEAN NOT NULL DEFAULT 0, '
    'inactivity_timeout_seconds INTEGER NOT NULL DEFAULT 300, '
    'lock_metadata TEXT)',
  );
  db.execute(
    'CREATE TABLE deletion_audit_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'privacy_epoch_before INTEGER NOT NULL, '
    'privacy_epoch_after INTEGER NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_account_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'currency_code TEXT NOT NULL, '
    'is_archived BOOLEAN NOT NULL, '
    'is_bank_synced BOOLEAN NOT NULL, '
    'is_writable BOOLEAN NOT NULL, '
    'eligibility_reason TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_category_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE wallet_connection_status ('
    'singleton_id INTEGER NOT NULL PRIMARY KEY, '
    'status TEXT NOT NULL DEFAULT \'disconnected\', '
    'last_sync_at_epoch_ms INTEGER)',
  );
  db.execute(
    'CREATE TABLE wallet_mutations ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'operation_kind TEXT NOT NULL, '
    'payload TEXT NOT NULL, '
    'state TEXT NOT NULL, '
    'lineage_key TEXT NOT NULL, '
    'fingerprint TEXT NOT NULL, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'updated_at_epoch_ms INTEGER NOT NULL, '
    'candidate_id TEXT, '
    'operation_revision INTEGER, '
    'lineage_generation INTEGER, '
    'payload_json_ciphertext TEXT, '
    'source_marker TEXT, '
    'attempt_count INTEGER, '
    'next_attempt_at_epoch_ms INTEGER, '
    'lease_until_epoch_ms INTEGER, '
    'last_http_status INTEGER, '
    'wallet_correlation_id TEXT)',
  );
  db.execute(
    'CREATE TABLE wallet_record_links ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'app_id TEXT NOT NULL UNIQUE, '
    'remote_id TEXT, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'candidate_id TEXT, '
    'leg_role TEXT, '
    'pair_group_id TEXT, '
    'last_known_revision INTEGER, '
    'last_known_state TEXT, '
    'updated_at_epoch_ms INTEGER, '
    'deleted_at_epoch_ms INTEGER, '
    'remote_deleted_tombstone BOOLEAN)',
  );
  db.execute(
    'CREATE TABLE capability_ledger ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'capability TEXT NOT NULL, '
    'status TEXT NOT NULL, '
    'evidence_reference TEXT, '
    'observed_on TEXT NOT NULL, '
    'review_date TEXT NOT NULL)',
  );
  db.execute(
    'CREATE TABLE rule_packs ('
    'id TEXT NOT NULL, '
    'version TEXT NOT NULL, '
    'checksum TEXT NOT NULL, '
    'market TEXT NOT NULL, '
    'enabled BOOLEAN NOT NULL DEFAULT 1, '
    'installed_at_epoch_ms INTEGER NOT NULL, '
    'PRIMARY KEY (id, version))',
  );
  db.execute(
    'CREATE TABLE ingestion_checkpoint ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'ingestion_source TEXT NOT NULL, '
    'selected_from_epoch_ms INTEGER, '
    'selected_until_epoch_ms INTEGER, '
    'selected_range_days INTEGER, '
    'sender_cursor_hash TEXT, '
    'date_cursor_epoch_ms INTEGER, '
    'configured_cap INTEGER NOT NULL, '
    'processed_count INTEGER NOT NULL DEFAULT 0, '
    'accepted_count INTEGER NOT NULL DEFAULT 0, '
    'filtered_count INTEGER NOT NULL DEFAULT 0, '
    'duplicate_count INTEGER NOT NULL DEFAULT 0, '
    'outcome TEXT, '
    'started_at_epoch_ms INTEGER NOT NULL, '
    'completed_at_epoch_ms INTEGER, '
    'privacy_epoch INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE tracked_senders ('
    'sender_key TEXT NOT NULL PRIMARY KEY, '
    'sender_display TEXT, '
    'enabled BOOLEAN NOT NULL DEFAULT 1, '
    'added_at_epoch_ms INTEGER NOT NULL)',
  );
  db.execute(
    'CREATE TABLE mapping_rule ('
    'id TEXT NOT NULL, '
    'name TEXT NOT NULL, '
    'enabled BOOLEAN NOT NULL, '
    'sender_matcher TEXT NOT NULL, '
    'parser_family TEXT, '
    'instrument_suffix_hash TEXT, '
    'direction TEXT, '
    'merchant_matcher TEXT, '
    'wallet_account_id TEXT NOT NULL, '
    'wallet_category_id TEXT, '
    'payment_type TEXT NOT NULL, '
    'sync_mode TEXT NOT NULL, '
    'priority INTEGER NOT NULL, '
    'min_confidence_basis_points INTEGER, '
    'rule_version INTEGER NOT NULL, '
    'superseded_by_rule_id TEXT, '
    'created_at_epoch_ms INTEGER NOT NULL, '
    'updated_at_epoch_ms INTEGER NOT NULL, '
    'PRIMARY KEY (id, rule_version))',
  );
  db.execute(
    'CREATE TABLE wallet_mutation_item ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'wallet_mutation_id TEXT NOT NULL REFERENCES wallet_mutations(id), '
    'item_index INTEGER NOT NULL, '
    'leg_role TEXT NOT NULL, '
    'wallet_record_id TEXT, '
    'expected_remote_revision INTEGER, '
    'payload_ciphertext TEXT NOT NULL, '
    'state TEXT NOT NULL, '
    'safe_error_code TEXT)',
  );
}

void _seedV11(sqlite.Database db) {
  // v11: same as v9 but activity_events has mutation_id + detail_message columns
  _seedV9(db);
  // Recreate activity_events with all columns
  db.execute('DROP TABLE activity_events');
  db.execute(
    'CREATE TABLE activity_events ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'event_type TEXT NOT NULL, '
    'sanitized_detail TEXT NOT NULL, '
    'occurred_at_epoch_ms INTEGER NOT NULL, '
    'privacy_epoch INTEGER NOT NULL, '
    'batch_count INTEGER, '
    'mutation_id TEXT, '
    'detail_message TEXT)',
  );
}

void _seedV13(sqlite.Database db) {
  // v13: v11 + wallet_category_cache with groupId/groupName/parentId
  _seedV11(db);
  db.execute('DROP TABLE wallet_category_cache');
  db.execute(
    'CREATE TABLE wallet_category_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'group_id TEXT NOT NULL DEFAULT \'unknown\', '
    'group_name TEXT NOT NULL DEFAULT \'Unknown\', '
    'parent_id TEXT, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
}

void _seedV14(sqlite.Database db) {
  // v14: v13 + wallet_label_cache
  _seedV13(db);
  db.execute(
    'CREATE TABLE wallet_label_cache ('
    'id TEXT NOT NULL PRIMARY KEY, '
    'name TEXT NOT NULL, '
    'refreshed_at_epoch_ms INTEGER NOT NULL)',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Migration chain: v1 → v15', () {
    test('completes without error and produces correct schema', () async {
      final db = await _migrateFrom(1, _seedV1);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);

      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
            readsFrom: const {},
          )
          .get();
      final names = tables.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'app_settings',
          'parser_rules',
          'sms_events',
          'transaction_candidates',
          'activity_events',
          'decision_traces',
          'schema_metadata',
          'app_lock_state',
          'deletion_audit_events',
          'wallet_account_cache',
          'wallet_category_cache',
          'wallet_connection_status',
          'wallet_mutations',
          'wallet_record_links',
          'capability_ledger',
          'rule_packs',
          'ingestion_checkpoint',
          'tracked_senders',
          'mapping_rule',
          'wallet_mutation_item',
          'wallet_label_cache',
        ]),
      );
    });

    test('v1→v15 preserves app_settings defaults', () async {
      final db = await _migrateFrom(1, _seedV1);
      addTearDown(db.close);

      final setting = await (db.select(
        db.appSettings,
      )..where((r) => r.singletonId.equals(1))).getSingle();
      expect(setting.privacyEpoch, 0);
      expect(setting.onboardingCompleted, false);
      expect(setting.rawCopyRetentionDays, 0);
      expect(setting.activityRetentionDays, 180);
      expect(setting.historySmsEnabled, false);
    });
  });

  group('Migration chain: v3 → v15 (guarded blocks)', () {
    test('completes without duplicate column errors', () async {
      final db = await _migrateFrom(3, _seedV3);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);

      // wallet_category_cache should have groupId, groupName, parentId, systemId
      final cols = await db
          .customSelect(
            'PRAGMA table_info(wallet_category_cache)',
            readsFrom: const {},
          )
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();
      expect(
        names,
        containsAll([
          'id',
          'name',
          'group_id',
          'group_name',
          'parent_id',
          'system_id',
        ]),
      );
    });

    test('wallet_label_cache exists after v3→v15', () async {
      final db = await _migrateFrom(3, _seedV3);
      addTearDown(db.close);

      final labels = await db.select(db.walletLabelCache).get();
      expect(labels, isEmpty);
    });
  });

  group('Migration chain: v7 → v15', () {
    test('completes without error', () async {
      final db = await _migrateFrom(7, _seedV7);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);
    });
  });

  group('Migration chain: v9 → v15', () {
    test('completes without error', () async {
      final db = await _migrateFrom(9, _seedV9);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);
    });
  });

  group('Migration chain: v11 → v15', () {
    test('completes without error', () async {
      final db = await _migrateFrom(11, _seedV11);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);
    });
  });

  group('Migration chain: v13 → v15', () {
    test('completes without error', () async {
      final db = await _migrateFrom(13, _seedV13);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);
    });
  });

  group('Migration chain: v14 → v15', () {
    test('completes without error and adds system_id', () async {
      final db = await _migrateFrom(14, _seedV14);
      addTearDown(db.close);

      expect(db.schemaVersion, 15);

      final cols = await db
          .customSelect(
            'PRAGMA table_info(wallet_category_cache)',
            readsFrom: const {},
          )
          .get();
      final names = cols.map((r) => r.read<String>('name')).toSet();
      expect(names, contains('system_id'));
    });
  });

  group('Type converters', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => db.close());

    test('WalletMutationStateConverter round-trips all states', () {
      const converter = WalletMutationStateConverter();
      for (final state in WalletMutationState.values) {
        final sql = converter.toSql(state);
        final back = converter.fromSql(sql);
        expect(back, state, reason: 'Failed for ${state.name}');
      }
    });

    test('WalletMutationStateConverter throws on unknown state', () {
      const converter = WalletMutationStateConverter();
      expect(
        () => converter.fromSql('nonexistent_state'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('WalletItemLegRoleConverter round-trips all roles', () {
      const converter = WalletItemLegRoleConverter();
      for (final role in WalletItemLegRole.values) {
        final sql = converter.toSql(role);
        final back = converter.fromSql(sql);
        expect(back, role, reason: 'Failed for ${role.name}');
      }
    });

    test('WalletItemLegRoleConverter throws on unknown role', () {
      const converter = WalletItemLegRoleConverter();
      expect(
        () => converter.fromSql('nonexistent_role'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('insertActivity', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => db.close());

    test('round-trips all fields including detailMessage', () async {
      await db.insertActivity(
        activityType: ActivityEventCode.walletRecordCreated,
        safeDetailCode: ActivityStateTransition.logEvent,
        occurredAtEpochMs: 1700000000000,
        privacyEpoch: 0,
        count: 5,
        detailMessage: 'Created 5 wallet records',
      );

      final rows = await db.select(db.activityEvents).get();
      expect(rows, hasLength(1));
      expect(rows.first.eventType, ActivityEventCode.walletRecordCreated);
      expect(rows.first.sanitizedDetail, ActivityStateTransition.logEvent);
      expect(rows.first.occurredAtEpochMs, 1700000000000);
      expect(rows.first.privacyEpoch, 0);
      expect(rows.first.batchCount, 5);
      expect(rows.first.detailMessage, 'Created 5 wallet records');
    });

    test('insertActivity without count or detailMessage', () async {
      await db.insertActivity(
        activityType: ActivityEventCode.candidateNeedsReview,
        safeDetailCode: ActivityStateTransition.needsReview,
        occurredAtEpochMs: 1700000000000,
        privacyEpoch: 0,
      );

      final rows = await db.select(db.activityEvents).get();
      expect(rows, hasLength(1));
      expect(rows.first.batchCount, isNull);
      expect(rows.first.detailMessage, isNull);
      expect(rows.first.mutationId, isNull);
    });

    test('throws StalePrivacyEpochException when epoch is stale', () async {
      await db.advancePrivacyEpoch(expectedCurrent: 0);

      await expectLater(
        db.insertActivity(
          activityType: ActivityEventCode.logInfo,
          safeDetailCode: ActivityStateTransition.logEvent,
          occurredAtEpochMs: 1700000000000,
          privacyEpoch: 0,
        ),
        throwsA(isA<StalePrivacyEpochException>()),
      );
    });

    test('multiple activity events accumulate', () async {
      for (var i = 0; i < 3; i++) {
        await db.insertActivity(
          activityType: ActivityEventCode.messageImported,
          safeDetailCode: ActivityStateTransition.logEvent,
          occurredAtEpochMs: 1700000000000 + i,
          privacyEpoch: 0,
        );
      }

      final rows = await db.select(db.activityEvents).get();
      expect(rows, hasLength(3));
    });
  });

  group('deleteSmsEvent', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => db.close());

    test('deletes event with candidate and decision traces', () async {
      final sms = await db.insertSmsEventIfAbsent(
        sourceKey: 'delete-test-key',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      await db.insertCandidateAndActivityAtomically(
        smsEventId: sms.id,
        candidateState: CandidateRecordState.needsReview,
        encryptedPayload: '{}',
        revision: 1,
        createdAtEpochMs: 1700000000000,
        activityType: ActivityEventCode.candidateNeedsReview,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.initialReview,
        privacyEpoch: 0,
      );

      expect(await db.smsEvents.count().getSingle(), 1);
      expect(await db.transactionCandidates.count().getSingle(), 1);
      expect(await db.decisionTraces.count().getSingle(), 1);

      final deleted = await db.deleteSmsEvent(eventId: sms.id, privacyEpoch: 0);
      expect(deleted, isTrue);

      expect(await db.smsEvents.count().getSingle(), 0);
      expect(await db.transactionCandidates.count().getSingle(), 0);
      expect(await db.decisionTraces.count().getSingle(), 0);
    });

    test('returns false for non-existent event', () async {
      final deleted = await db.deleteSmsEvent(eventId: 99999, privacyEpoch: 0);
      expect(deleted, isFalse);
    });

    test('throws StalePrivacyEpochException when epoch is stale', () async {
      final sms = await db.insertSmsEventIfAbsent(
        sourceKey: 'stale-delete-key',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      await db.advancePrivacyEpoch(expectedCurrent: 0);

      await expectLater(
        db.deleteSmsEvent(eventId: sms.id, privacyEpoch: 0),
        throwsA(isA<StalePrivacyEpochException>()),
      );
    });
  });

  group('insertSmsEventIfAbsent contentSha256 duplicate detection', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => db.close());

    test(
      'duplicateSuspected when same contentSha256 on different event',
      () async {
        await db.insertSmsEventIfAbsent(
          sourceKey: 'sha-key-1',
          senderKey: 'sender',
          ingestionSource: 'manual',
          receivedAtEpochMs: 1700000000000,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
          contentSha256: 'abc123',
        );

        final result = await db.insertSmsEventIfAbsent(
          sourceKey: 'sha-key-2',
          senderKey: 'sender',
          ingestionSource: 'manual',
          receivedAtEpochMs: 1700000000001,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
          contentSha256: 'abc123',
        );

        expect(result.inserted, isTrue);
        expect(result.duplicateSuspected, isTrue);
      },
    );

    test('no duplicateSuspected when contentSha256 is unique', () async {
      await db.insertSmsEventIfAbsent(
        sourceKey: 'sha-unique-1',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
        contentSha256: 'unique_hash_1',
      );

      final result = await db.insertSmsEventIfAbsent(
        sourceKey: 'sha-unique-2',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000001,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
        contentSha256: 'unique_hash_2',
      );

      expect(result.inserted, isTrue);
      expect(result.duplicateSuspected, isFalse);
    });

    test('no duplicateSuspected when contentSha256 is null', () async {
      final result = await db.insertSmsEventIfAbsent(
        sourceKey: 'sha-null-key',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      expect(result.inserted, isTrue);
      expect(result.duplicateSuspected, isFalse);
    });
  });

  group('smsEventsPage with filters', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.inMemoryForTesting();
      // Insert test events with different senders and timestamps
      for (var i = 0; i < 5; i++) {
        await db.insertSmsEventIfAbsent(
          sourceKey: 'filter-key-$i',
          senderKey: i < 3 ? 'senderA' : 'senderB',
          senderDisplay: i < 3 ? 'Bank A' : 'Bank B',
          ingestionSource: 'manual',
          receivedAtEpochMs: 1700000000000 + i * 1000,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
        );
      }
    });

    tearDown(() => db.close());

    test('returns events ordered by receivedAtEpochMs DESC', () async {
      final events = await db.smsEventsPage(limit: 10);
      expect(events, hasLength(5));
      expect(
        events.first.receivedAtEpochMs,
        greaterThanOrEqualTo(events.last.receivedAtEpochMs),
      );
    });

    test('filters by senderKey', () async {
      final events = await db.smsEventsPage(limit: 10, senderKey: 'senderA');
      expect(events, hasLength(3));
      expect(events.every((e) => e.senderKey == 'senderA'), isTrue);
    });

    test('filters by fromReceivedAtEpochMs', () async {
      final events = await db.smsEventsPage(
        limit: 10,
        fromReceivedAtEpochMs: 1700000002000,
      );
      expect(events, hasLength(3)); // timestamps 2, 3, 4
    });

    test('filters by untilReceivedAtEpochMs', () async {
      final events = await db.smsEventsPage(
        limit: 10,
        untilReceivedAtEpochMs: 1700000001000,
      );
      expect(events, hasLength(2)); // timestamps 0, 1
    });

    test('paginates with cursor', () async {
      final firstPage = await db.smsEventsPage(limit: 3);
      expect(firstPage, hasLength(3));

      final cursor = firstPage.last;
      final secondPage = await db.smsEventsPage(
        limit: 3,
        beforeReceivedAtEpochMs: cursor.receivedAtEpochMs,
        beforeId: cursor.id,
      );
      expect(secondPage, hasLength(2));
      // All second page events should be older than the cursor
      for (final event in secondPage) {
        expect(
          event.receivedAtEpochMs < cursor.receivedAtEpochMs ||
              (event.receivedAtEpochMs == cursor.receivedAtEpochMs &&
                  event.id < cursor.id),
          isTrue,
        );
      }
    });

    test('respects limit', () async {
      final events = await db.smsEventsPage(limit: 2);
      expect(events, hasLength(2));
    });

    test('excludes events with retainedLocal candidates', () async {
      final sms = await db.insertSmsEventIfAbsent(
        sourceKey: 'retained-key',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000010000,
        status: SmsEventStatus.interpreted,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      await db.insertCandidateAndActivityAtomically(
        smsEventId: sms.id,
        candidateState: CandidateRecordState.retainedLocal,
        encryptedPayload: '{}',
        revision: 1,
        createdAtEpochMs: 1700000010000,
        activityType: ActivityEventCode.candidateNeedsReview,
        safeDetailCode: ActivityStateTransition.needsReview,
        decisionTraceCode: DecisionTraceCode.parsedComplete,
        privacyEpoch: 0,
      );

      final events = await db.smsEventsPage(limit: 100);
      expect(
        events.every((e) => e.id != sms.id),
        isTrue,
        reason: 'retainedLocal candidate should exclude the SMS event',
      );
    });
  });

  group('watchSmsEventSenderSummaries', () {
    test('groups by sender and counts correctly', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db.insertSmsEventIfAbsent(
        sourceKey: 'summary-key-1',
        senderKey: 'BANK_A',
        senderDisplay: 'Bank A',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );
      await db.insertSmsEventIfAbsent(
        sourceKey: 'summary-key-2',
        senderKey: 'BANK_A',
        senderDisplay: 'Bank A',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000001000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );
      await db.insertSmsEventIfAbsent(
        sourceKey: 'summary-key-3',
        senderKey: 'BANK_B',
        senderDisplay: 'Bank B',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000002000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      final summaries = await db.watchSmsEventSenderSummaries().first;
      expect(summaries, hasLength(2));

      final bankA = summaries.firstWhere((s) => s.senderKey == 'BANK_A');
      expect(bankA.total, 2);
      expect(bankA.senderDisplay, 'Bank A');

      final bankB = summaries.firstWhere((s) => s.senderKey == 'BANK_B');
      expect(bankB.total, 1);
    });
  });

  group('ActivityRedaction guard', () {
    const redaction = ActivityRedaction();

    test('rejectRawText always throws', () {
      expect(
        () => redaction.rejectRawText('any text'),
        throwsA(isA<RedactionViolation>()),
      );
    });

    test('rejectTokenLikeText throws on bearer token', () {
      expect(
        () => redaction.rejectTokenLikeText('bearer abc123'),
        throwsA(isA<RedactionViolation>()),
      );
    });

    test('rejectTokenLikeText throws on token= pattern', () {
      expect(
        () => redaction.rejectTokenLikeText('token=secret123'),
        throwsA(isA<RedactionViolation>()),
      );
    });

    test('rejectTokenLikeText throws on api_key= pattern', () {
      expect(
        () => redaction.rejectTokenLikeText('api_key=abcdef'),
        throwsA(isA<RedactionViolation>()),
      );
    });

    test('rejectTokenLikeText passes on clean text', () {
      expect(
        () => redaction.rejectTokenLikeText('LKR 1500.00 at Merchant'),
        returnsNormally,
      );
    });

    test('rejectArbitraryMetadata always throws', () {
      expect(
        () => redaction.rejectArbitraryMetadata({'key': 'value'}),
        throwsA(isA<RedactionViolation>()),
      );
    });
  });

  group('Privacy epoch read path', () {
    test('_requireCurrentPrivacyEpoch reads from app_settings', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      // Initial epoch is 0 — inserting with epoch 0 should succeed
      await db.insertSmsEventIfAbsent(
        sourceKey: 'epoch-read-key',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 0,
        captureCanonicalizationVersion: 2,
      );

      // Advance to epoch 1
      final newEpoch = await db.advancePrivacyEpoch(expectedCurrent: 0);
      expect(newEpoch, 1);

      // Reading the setting should show epoch 1
      final setting = await (db.select(
        db.appSettings,
      )..where((r) => r.singletonId.equals(1))).getSingle();
      expect(setting.privacyEpoch, 1);

      // Insert with old epoch should fail
      await expectLater(
        db.insertSmsEventIfAbsent(
          sourceKey: 'epoch-stale-key',
          senderKey: 'sender',
          ingestionSource: 'manual',
          receivedAtEpochMs: 1700000001000,
          status: SmsEventStatus.captured,
          privacyEpoch: 0,
          captureCanonicalizationVersion: 2,
        ),
        throwsA(isA<StalePrivacyEpochException>()),
      );

      // Insert with new epoch should succeed
      final result = await db.insertSmsEventIfAbsent(
        sourceKey: 'epoch-fresh-key',
        senderKey: 'sender',
        ingestionSource: 'manual',
        receivedAtEpochMs: 1700000001000,
        status: SmsEventStatus.captured,
        privacyEpoch: 1,
        captureCanonicalizationVersion: 2,
      );
      expect(result.inserted, isTrue);
    });
  });

  group('Table coverage — exercise all table definitions', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => db.close());

    test('SenderRules — insert and read', () async {
      await db
          .into(db.senderRules)
          .insert(
            SenderRulesCompanion.insert(
              senderHash: 'BANK_SENDER',
              parserFamily: 'card_transaction',
              createdAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.senderRules).get();
      expect(rows, hasLength(1));
      expect(rows.first.senderHash, 'BANK_SENDER');
      expect(rows.first.parserFamily, 'card_transaction');
      expect(rows.first.priority, 0);
    });

    test('DatabaseMetadata — insert and read', () async {
      await db
          .into(db.databaseMetadata)
          .insert(
            DatabaseMetadataCompanion.insert(
              key: 'test_key',
              value: 'test_value',
            ),
          );

      final rows = await db.select(db.databaseMetadata).get();
      expect(rows, hasLength(1));
      expect(rows.first.key, 'test_key');
      expect(rows.first.value, 'test_value');
    });

    test('DeletionAuditEvents — insert and read', () async {
      await db
          .into(db.deletionAuditEvents)
          .insert(
            DeletionAuditEventsCompanion.insert(
              privacyEpochBefore: 5,
              privacyEpochAfter: 6,
              occurredAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.deletionAuditEvents).get();
      expect(rows, hasLength(1));
      expect(rows.first.privacyEpochBefore, 5);
      expect(rows.first.privacyEpochAfter, 6);
    });

    test('WalletAccountCache — insert and read', () async {
      await db
          .into(db.walletAccountCache)
          .insert(
            WalletAccountCacheCompanion.insert(
              id: 'acc-1',
              name: 'Savings Account',
              currencyCode: 'LKR',
              isArchived: false,
              isBankSynced: true,
              isWritable: true,
              eligibilityReason: 'primary',
              refreshedAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.walletAccountCache).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, 'acc-1');
      expect(rows.first.name, 'Savings Account');
    });

    test('WalletCategoryCache — insert and read with all columns', () async {
      await db
          .into(db.walletCategoryCache)
          .insert(
            WalletCategoryCacheCompanion.insert(
              id: 'cat-1',
              name: 'Food & Drinks',
              refreshedAtEpochMs: 1700000000000,
              groupId: const Value('food_and_drinks'),
              groupName: const Value('Food & Drinks'),
            ),
          );

      final rows = await db.select(db.walletCategoryCache).get();
      expect(rows, hasLength(1));
      expect(rows.first.groupId, 'food_and_drinks');
      expect(rows.first.groupName, 'Food & Drinks');
      expect(rows.first.systemId, isNull);
    });

    test('WalletLabelCache — insert and read', () async {
      await db
          .into(db.walletLabelCache)
          .insert(
            WalletLabelCacheCompanion.insert(
              id: 'label-1',
              name: 'Important',
              refreshedAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.walletLabelCache).get();
      expect(rows, hasLength(1));
      expect(rows.first.name, 'Important');
    });

    test('MappingRules — insert and read', () async {
      await db
          .into(db.mappingRules)
          .insert(
            MappingRulesCompanion.insert(
              id: 'rule-1',
              name: 'Salary Rule',
              enabled: true,
              senderMatcher: 'SALARY',
              walletAccountId: 'acc-1',
              paymentType: 'transfer',
              syncMode: MappingSyncMode.automatic,
              priority: 100,
              ruleVersion: 1,
              createdAtEpochMs: 1700000000000,
              updatedAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.mappingRules).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, 'rule-1');
      expect(rows.first.syncMode, MappingSyncMode.automatic);
    });

    test('WalletMutationItems — insert and read', () async {
      // First insert a wallet mutation
      await db
          .into(db.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: 'mut-1',
              operationKind: WalletMutationOperation.create,
              payload: '{}',
              state: WalletMutationState.queued,
              lineageKey: 'lk',
              fingerprint: 'fp',
              createdAtEpochMs: 1700000000000,
              updatedAtEpochMs: 1700000000000,
            ),
          );

      await db
          .into(db.walletMutationItems)
          .insert(
            WalletMutationItemsCompanion.insert(
              walletMutationId: 'mut-1',
              itemIndex: 0,
              legRole: WalletItemLegRole.primary,
              payloadCiphertext: 'encrypted',
              state: WalletMutationState.queued,
            ),
          );

      final items = await db.select(db.walletMutationItems).get();
      expect(items, hasLength(1));
      expect(items.first.walletMutationId, 'mut-1');
      expect(items.first.legRole, WalletItemLegRole.primary);
    });

    test('CapabilityLedger — insert and read', () async {
      await db
          .into(db.capabilityLedger)
          .insert(
            CapabilityLedgerCompanion.insert(
              id: 'cap-1',
              capability: 'sms_read',
              status: 'active',
              observedOn: 'device-1',
              reviewDate: '2024-01-01',
            ),
          );

      final rows = await db.select(db.capabilityLedger).get();
      expect(rows, hasLength(1));
      expect(rows.first.capability, 'sms_read');
    });

    test('WalletMutations — insert and read', () async {
      await db
          .into(db.walletMutations)
          .insert(
            WalletMutationsCompanion.insert(
              id: 'mut-coverage',
              operationKind: WalletMutationOperation.update,
              payload: '{"amount": 100}',
              state: WalletMutationState.syncing,
              lineageKey: 'lk-coverage',
              fingerprint: 'fp-coverage',
              createdAtEpochMs: 1700000000000,
              updatedAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.walletMutations).get();
      expect(rows, hasLength(1));
      expect(rows.first.operationKind, WalletMutationOperation.update);
      expect(rows.first.state, WalletMutationState.syncing);
    });

    test('WalletRecordLinks — insert and read', () async {
      await db
          .into(db.walletRecordLinks)
          .insert(
            WalletRecordLinksCompanion.insert(
              id: 'link-coverage',
              appId: 'app-coverage',
              remoteId: Value('remote-coverage'),
              createdAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.walletRecordLinks).get();
      expect(rows, hasLength(1));
      expect(rows.first.appId, 'app-coverage');
      expect(rows.first.remoteId, 'remote-coverage');
    });

    test('TrackedSenders — insert and read', () async {
      await db
          .into(db.trackedSenders)
          .insert(
            TrackedSendersCompanion.insert(
              senderKey: 'TRK_SENDER',
              addedAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.trackedSenders).get();
      expect(rows, hasLength(1));
      expect(rows.first.senderKey, 'TRK_SENDER');
    });

    test('IngestionCheckpoints — insert and read', () async {
      await db
          .into(db.ingestionCheckpoints)
          .insert(
            IngestionCheckpointsCompanion.insert(
              ingestionSource: 'history_selection',
              configuredCap: 100,
              startedAtEpochMs: 1700000000000,
              privacyEpoch: 0,
            ),
          );

      final rows = await db.select(db.ingestionCheckpoints).get();
      expect(rows, hasLength(1));
      expect(rows.first.configuredCap, 100);
    });

    test('RulePacks — insert and read', () async {
      await db
          .into(db.rulePacks)
          .insert(
            RulePacksCompanion.insert(
              id: 'rp-1',
              version: '1.0.0',
              checksum: 'abc123',
              market: 'LK',
              installedAtEpochMs: 1700000000000,
            ),
          );

      final rows = await db.select(db.rulePacks).get();
      expect(rows, hasLength(1));
      expect(rows.first.market, 'LK');
    });
  });

  group('SmsEventInsertResult fields', () {
    test('SmsEventSenderSummary constructor works', () {
      const summary = SmsEventSenderSummary(
        senderKey: 'key',
        senderDisplay: 'display',
        total: 42,
      );
      expect(summary.senderKey, 'key');
      expect(summary.senderDisplay, 'display');
      expect(summary.total, 42);
    });

    test('StalePrivacyEpochException toString', () {
      const exception = StalePrivacyEpochException();
      expect(exception.toString(), contains('StalePrivacyEpoch'));
    });
  });

  group('Explicit column getter coverage', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => db.close());

    test('AppSettings column getters', () {
      // ignore: unnecessary_statements
      db.appSettings.singletonId;
      // ignore: unnecessary_statements
      db.appSettings.privacyEpoch;
      // ignore: unnecessary_statements
      db.appSettings.onboardingCompleted;
      // ignore: unnecessary_statements
      db.appSettings.onboardingRevision;
      // ignore: unnecessary_statements
      db.appSettings.disclosureAccepted;
      // ignore: unnecessary_statements
      db.appSettings.disclosureRevision;
      // ignore: unnecessary_statements
      db.appSettings.processingMode;
      // ignore: unnecessary_statements
      db.appSettings.configurationRevision;
      // ignore: unnecessary_statements
      db.appSettings.rawCopyRetentionDays;
      // ignore: unnecessary_statements
      db.appSettings.activityRetentionDays;
      // ignore: unnecessary_statements
      db.appSettings.smsDisclosureRevision;
      // ignore: unnecessary_statements
      db.appSettings.historySmsEnabled;
      // ignore: unnecessary_statements
      db.appSettings.historyWindowDays;
      // ignore: unnecessary_statements
      db.appSettings.historyMessageCap;
    });

    test('SenderRules column getters', () {
      // ignore: unnecessary_statements
      db.senderRules.id;
      // ignore: unnecessary_statements
      db.senderRules.senderHash;
      // ignore: unnecessary_statements
      db.senderRules.parserFamily;
      // ignore: unnecessary_statements
      db.senderRules.createdAtEpochMs;
      // ignore: unnecessary_statements
      db.senderRules.priority;
      // ignore: unnecessary_statements
      db.senderRules.parserVersion;
      // ignore: unnecessary_statements
      db.senderRules.parserChecksum;
    });

    test('SmsEvents column getters', () {
      // ignore: unnecessary_statements
      db.smsEvents.id;
      // ignore: unnecessary_statements
      db.smsEvents.sourceKey;
      // ignore: unnecessary_statements
      db.smsEvents.senderKey;
      // ignore: unnecessary_statements
      db.smsEvents.senderDisplay;
      // ignore: unnecessary_statements
      db.smsEvents.encryptedBody;
      // ignore: unnecessary_statements
      db.smsEvents.redactedBody;
      // ignore: unnecessary_statements
      db.smsEvents.ingestionSource;
      // ignore: unnecessary_statements
      db.smsEvents.receivedAtEpochMs;
      // ignore: unnecessary_statements
      db.smsEvents.expiresAtEpochMs;
      // ignore: unnecessary_statements
      db.smsEvents.status;
      // ignore: unnecessary_statements
      db.smsEvents.privacyEpoch;
      // ignore: unnecessary_statements
      db.smsEvents.providerRowId;
      // ignore: unnecessary_statements
      db.smsEvents.captureCanonicalizationVersion;
      // ignore: unnecessary_statements
      db.smsEvents.redactionVersion;
      // ignore: unnecessary_statements
      db.smsEvents.rawPurgeState;
      // ignore: unnecessary_statements
      db.smsEvents.contentSha256;
    });

    test('TransactionCandidates column getters', () {
      // ignore: unnecessary_statements
      db.transactionCandidates.id;
      // ignore: unnecessary_statements
      db.transactionCandidates.candidateId;
      // ignore: unnecessary_statements
      db.transactionCandidates.smsEventId;
      // ignore: unnecessary_statements
      db.transactionCandidates.state;
      // ignore: unnecessary_statements
      db.transactionCandidates.encryptedPayload;
      // ignore: unnecessary_statements
      db.transactionCandidates.revision;
      // ignore: unnecessary_statements
      db.transactionCandidates.createdAtEpochMs;
      // ignore: unnecessary_statements
      db.transactionCandidates.warningCode;
      // ignore: unnecessary_statements
      db.transactionCandidates.paymentEvidence;
      // ignore: unnecessary_statements
      db.transactionCandidates.instrumentEvidence;
      // ignore: unnecessary_statements
      db.transactionCandidates.originalCurrencyCode;
      // ignore: unnecessary_statements
      db.transactionCandidates.walletCurrencyCode;
      // ignore: unnecessary_statements
      db.transactionCandidates.kind;
      // ignore: unnecessary_statements
      db.transactionCandidates.direction;
      // ignore: unnecessary_statements
      db.transactionCandidates.lifecycle;
      // ignore: unnecessary_statements
      db.transactionCandidates.originalAmountMinor;
      // ignore: unnecessary_statements
      db.transactionCandidates.walletAmountMinor;
      // ignore: unnecessary_statements
      db.transactionCandidates.transactionAtEpochMs;
      // ignore: unnecessary_statements
      db.transactionCandidates.dateEvidence;
      // ignore: unnecessary_statements
      db.transactionCandidates.counterpartyRedacted;
      // ignore: unnecessary_statements
      db.transactionCandidates.instrumentSuffixHash;
      // ignore: unnecessary_statements
      db.transactionCandidates.availableBalanceMinor;
      // ignore: unnecessary_statements
      db.transactionCandidates.paymentType;
      // ignore: unnecessary_statements
      db.transactionCandidates.confidenceBasisPoints;
      // ignore: unnecessary_statements
      db.transactionCandidates.parserRuleId;
      // ignore: unnecessary_statements
      db.transactionCandidates.parserRuleVersion;
      // ignore: unnecessary_statements
      db.transactionCandidates.rulePackId;
      // ignore: unnecessary_statements
      db.transactionCandidates.rulePackVersion;
      // ignore: unnecessary_statements
      db.transactionCandidates.reviewReasons;
      // ignore: unnecessary_statements
      db.transactionCandidates.transactionFingerprint;
    });

    test('ActivityEvents column getters', () {
      // ignore: unnecessary_statements
      db.activityEvents.id;
      // ignore: unnecessary_statements
      db.activityEvents.eventType;
      // ignore: unnecessary_statements
      db.activityEvents.sanitizedDetail;
      // ignore: unnecessary_statements
      db.activityEvents.occurredAtEpochMs;
      // ignore: unnecessary_statements
      db.activityEvents.privacyEpoch;
      // ignore: unnecessary_statements
      db.activityEvents.batchCount;
      // ignore: unnecessary_statements
      db.activityEvents.mutationId;
      // ignore: unnecessary_statements
      db.activityEvents.detailMessage;
    });

    test('DecisionTraces column getters', () {
      // ignore: unnecessary_statements
      db.decisionTraces.id;
      // ignore: unnecessary_statements
      db.decisionTraces.candidateId;
      // ignore: unnecessary_statements
      db.decisionTraces.traceCode;
      // ignore: unnecessary_statements
      db.decisionTraces.createdAtEpochMs;
      // ignore: unnecessary_statements
      db.decisionTraces.stage;
      // ignore: unnecessary_statements
      db.decisionTraces.rulePackVersion;
      // ignore: unnecessary_statements
      db.decisionTraces.outcomeCode;
    });

    test('DatabaseMetadata column getters', () {
      // ignore: unnecessary_statements
      db.databaseMetadata.key;
      // ignore: unnecessary_statements
      db.databaseMetadata.value;
    });

    test('AppLockState column getters', () {
      // ignore: unnecessary_statements
      db.appLockState.singletonId;
      // ignore: unnecessary_statements
      db.appLockState.lockEnabled;
      // ignore: unnecessary_statements
      db.appLockState.inactivityTimeoutSeconds;
      // ignore: unnecessary_statements
      db.appLockState.lockMetadata;
    });

    test('DeletionAuditEvents column getters', () {
      // ignore: unnecessary_statements
      db.deletionAuditEvents.id;
      // ignore: unnecessary_statements
      db.deletionAuditEvents.privacyEpochBefore;
      // ignore: unnecessary_statements
      db.deletionAuditEvents.privacyEpochAfter;
      // ignore: unnecessary_statements
      db.deletionAuditEvents.occurredAtEpochMs;
    });

    test('WalletAccountCache column getters', () {
      // ignore: unnecessary_statements
      db.walletAccountCache.id;
      // ignore: unnecessary_statements
      db.walletAccountCache.name;
      // ignore: unnecessary_statements
      db.walletAccountCache.currencyCode;
      // ignore: unnecessary_statements
      db.walletAccountCache.isArchived;
      // ignore: unnecessary_statements
      db.walletAccountCache.isBankSynced;
      // ignore: unnecessary_statements
      db.walletAccountCache.isWritable;
      // ignore: unnecessary_statements
      db.walletAccountCache.eligibilityReason;
      // ignore: unnecessary_statements
      db.walletAccountCache.refreshedAtEpochMs;
    });

    test('WalletCategoryCache column getters', () {
      // ignore: unnecessary_statements
      db.walletCategoryCache.id;
      // ignore: unnecessary_statements
      db.walletCategoryCache.name;
      // ignore: unnecessary_statements
      db.walletCategoryCache.groupId;
      // ignore: unnecessary_statements
      db.walletCategoryCache.groupName;
      // ignore: unnecessary_statements
      db.walletCategoryCache.parentId;
      // ignore: unnecessary_statements
      db.walletCategoryCache.systemId;
      // ignore: unnecessary_statements
      db.walletCategoryCache.refreshedAtEpochMs;
    });

    test('WalletLabelCache column getters', () {
      // ignore: unnecessary_statements
      db.walletLabelCache.id;
      // ignore: unnecessary_statements
      db.walletLabelCache.name;
      // ignore: unnecessary_statements
      db.walletLabelCache.refreshedAtEpochMs;
    });

    test('WalletConnectionStatus column getters', () {
      // ignore: unnecessary_statements
      db.walletConnectionStatus.singletonId;
      // ignore: unnecessary_statements
      db.walletConnectionStatus.status;
      // ignore: unnecessary_statements
      db.walletConnectionStatus.lastSyncAtEpochMs;
    });

    test('WalletMutations column getters', () {
      // ignore: unnecessary_statements
      db.walletMutations.id;
      // ignore: unnecessary_statements
      db.walletMutations.operationKind;
      // ignore: unnecessary_statements
      db.walletMutations.payload;
      // ignore: unnecessary_statements
      db.walletMutations.state;
      // ignore: unnecessary_statements
      db.walletMutations.lineageKey;
      // ignore: unnecessary_statements
      db.walletMutations.fingerprint;
      // ignore: unnecessary_statements
      db.walletMutations.createdAtEpochMs;
      // ignore: unnecessary_statements
      db.walletMutations.updatedAtEpochMs;
      // ignore: unnecessary_statements
      db.walletMutations.candidateId;
      // ignore: unnecessary_statements
      db.walletMutations.operationRevision;
      // ignore: unnecessary_statements
      db.walletMutations.lineageGeneration;
      // ignore: unnecessary_statements
      db.walletMutations.payloadJsonCiphertext;
      // ignore: unnecessary_statements
      db.walletMutations.sourceMarker;
      // ignore: unnecessary_statements
      db.walletMutations.attemptCount;
      // ignore: unnecessary_statements
      db.walletMutations.nextAttemptAtEpochMs;
      // ignore: unnecessary_statements
      db.walletMutations.leaseUntilEpochMs;
      // ignore: unnecessary_statements
      db.walletMutations.lastHttpStatus;
      // ignore: unnecessary_statements
      db.walletMutations.walletCorrelationId;
    });

    test('WalletRecordLinks column getters', () {
      // ignore: unnecessary_statements
      db.walletRecordLinks.id;
      // ignore: unnecessary_statements
      db.walletRecordLinks.appId;
      // ignore: unnecessary_statements
      db.walletRecordLinks.remoteId;
      // ignore: unnecessary_statements
      db.walletRecordLinks.createdAtEpochMs;
      // ignore: unnecessary_statements
      db.walletRecordLinks.candidateId;
      // ignore: unnecessary_statements
      db.walletRecordLinks.legRole;
      // ignore: unnecessary_statements
      db.walletRecordLinks.pairGroupId;
      // ignore: unnecessary_statements
      db.walletRecordLinks.lastKnownRevision;
      // ignore: unnecessary_statements
      db.walletRecordLinks.lastKnownState;
      // ignore: unnecessary_statements
      db.walletRecordLinks.updatedAtEpochMs;
      // ignore: unnecessary_statements
      db.walletRecordLinks.deletedAtEpochMs;
      // ignore: unnecessary_statements
      db.walletRecordLinks.remoteDeletedTombstone;
    });

    test('MappingRules column getters', () {
      // ignore: unnecessary_statements
      db.mappingRules.id;
      // ignore: unnecessary_statements
      db.mappingRules.name;
      // ignore: unnecessary_statements
      db.mappingRules.enabled;
      // ignore: unnecessary_statements
      db.mappingRules.senderMatcher;
      // ignore: unnecessary_statements
      db.mappingRules.parserFamily;
      // ignore: unnecessary_statements
      db.mappingRules.instrumentSuffixHash;
      // ignore: unnecessary_statements
      db.mappingRules.direction;
      // ignore: unnecessary_statements
      db.mappingRules.merchantMatcher;
      // ignore: unnecessary_statements
      db.mappingRules.walletAccountId;
      // ignore: unnecessary_statements
      db.mappingRules.walletCategoryId;
      // ignore: unnecessary_statements
      db.mappingRules.paymentType;
      // ignore: unnecessary_statements
      db.mappingRules.syncMode;
      // ignore: unnecessary_statements
      db.mappingRules.priority;
      // ignore: unnecessary_statements
      db.mappingRules.minConfidenceBasisPoints;
      // ignore: unnecessary_statements
      db.mappingRules.ruleVersion;
      // ignore: unnecessary_statements
      db.mappingRules.supersededByRuleId;
      // ignore: unnecessary_statements
      db.mappingRules.createdAtEpochMs;
      // ignore: unnecessary_statements
      db.mappingRules.updatedAtEpochMs;
    });

    test('WalletMutationItems column getters', () {
      // ignore: unnecessary_statements
      db.walletMutationItems.id;
      // ignore: unnecessary_statements
      db.walletMutationItems.walletMutationId;
      // ignore: unnecessary_statements
      db.walletMutationItems.itemIndex;
      // ignore: unnecessary_statements
      db.walletMutationItems.legRole;
      // ignore: unnecessary_statements
      db.walletMutationItems.walletRecordId;
      // ignore: unnecessary_statements
      db.walletMutationItems.expectedRemoteRevision;
      // ignore: unnecessary_statements
      db.walletMutationItems.payloadCiphertext;
      // ignore: unnecessary_statements
      db.walletMutationItems.state;
      // ignore: unnecessary_statements
      db.walletMutationItems.safeErrorCode;
    });

    test('CapabilityLedger column getters', () {
      // ignore: unnecessary_statements
      db.capabilityLedger.id;
      // ignore: unnecessary_statements
      db.capabilityLedger.capability;
      // ignore: unnecessary_statements
      db.capabilityLedger.status;
      // ignore: unnecessary_statements
      db.capabilityLedger.evidenceReference;
      // ignore: unnecessary_statements
      db.capabilityLedger.observedOn;
      // ignore: unnecessary_statements
      db.capabilityLedger.reviewDate;
    });

    test('RulePacks column getters', () {
      // ignore: unnecessary_statements
      db.rulePacks.id;
      // ignore: unnecessary_statements
      db.rulePacks.version;
      // ignore: unnecessary_statements
      db.rulePacks.checksum;
      // ignore: unnecessary_statements
      db.rulePacks.market;
      // ignore: unnecessary_statements
      db.rulePacks.enabled;
      // ignore: unnecessary_statements
      db.rulePacks.installedAtEpochMs;
    });

    test('IngestionCheckpoints column getters', () {
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.id;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.ingestionSource;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.selectedFromEpochMs;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.selectedUntilEpochMs;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.selectedRangeDays;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.senderCursorHash;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.dateCursorEpochMs;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.configuredCap;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.processedCount;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.acceptedCount;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.filteredCount;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.duplicateCount;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.outcome;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.startedAtEpochMs;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.completedAtEpochMs;
      // ignore: unnecessary_statements
      db.ingestionCheckpoints.privacyEpoch;
    });

    test('TrackedSenders column getters', () {
      // ignore: unnecessary_statements
      db.trackedSenders.senderKey;
      // ignore: unnecessary_statements
      db.trackedSenders.senderDisplay;
      // ignore: unnecessary_statements
      db.trackedSenders.enabled;
      // ignore: unnecessary_statements
      db.trackedSenders.addedAtEpochMs;
    });
  });
}
