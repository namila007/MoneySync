import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

/// Real v1→v7 and v6→v7 upgrades with pre-migration rows seeded, per M4.14
/// §3.5. Drift reads the schema version from `PRAGMA user_version`, so the
/// setup pins it and creates the exact old-shape tables, then opens
/// `AppDatabase` to run the real `onUpgrade`.
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

  /// The v1 table set with one real row; later blocks add their columns on
  /// top of it, so this is what a genuine v1 database holds.
  void seedV1Schema(dynamic db) {
    db.execute(
      'CREATE TABLE app_settings ('
      'singleton_id INTEGER NOT NULL PRIMARY KEY, '
      'privacy_epoch INTEGER NOT NULL DEFAULT 0)',
    );
    db.execute(
      'CREATE TABLE parser_rules ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'sender_hash TEXT NOT NULL UNIQUE, '
      'parser_family TEXT NOT NULL, '
      'created_at_epoch_ms INTEGER NOT NULL)',
    );
    db.execute(
      'CREATE TABLE sms_events ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'source_key TEXT NOT NULL UNIQUE, '
      'sender_hash TEXT NOT NULL, '
      'encrypted_body TEXT, '
      'redacted_body TEXT, '
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
      'CREATE TABLE schema_metadata (key TEXT NOT NULL PRIMARY KEY, '
      'value TEXT NOT NULL)',
    );
    db.execute(
      'INSERT INTO app_settings (singleton_id, privacy_epoch) VALUES (1, 0)',
    );
    db.execute(
      "INSERT INTO sms_events (source_key, sender_hash, redacted_body, "
      "ingestion_source, received_at_epoch_ms, status, privacy_epoch) VALUES "
      "('v1_${'e' * 64}', 'SAMPATH BANK', 'legacy', 'history_selection', "
      "100, 'captured', 0)",
    );
    db.execute(
      "INSERT INTO schema_metadata (key, value) VALUES "
      "('tracked_senders', ?)",
      [
        jsonEncode(['SAMPATH BANK']),
      ],
    );
  }

  /// The v6 table set (all columns a v6 database holds), with real v6 rows
  /// including legacy statuses and v1-era source keys. [includeContentSha256]
  /// is false to shape a genuine v5 database (the v6 block adds the column).
  void seedV6Schema(dynamic db, {bool includeContentSha256 = true}) {
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
      'CREATE TABLE wallet_category_cache ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'name TEXT NOT NULL, '
      'refreshed_at_epoch_ms INTEGER NOT NULL)',
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
      'CREATE TABLE sms_events ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'source_key TEXT NOT NULL UNIQUE, '
      'sender_hash TEXT NOT NULL, '
      'encrypted_body TEXT, '
      'redacted_body TEXT, '
      'ingestion_source TEXT NOT NULL, '
      'received_at_epoch_ms INTEGER NOT NULL, '
      'expires_at_epoch_ms INTEGER, '
      'status TEXT NOT NULL, '
      'privacy_epoch INTEGER NOT NULL, '
      'provider_row_id INTEGER, '
      'capture_canonicalization_version INTEGER NOT NULL DEFAULT 1, '
      'redaction_version INTEGER NOT NULL DEFAULT 1, '
      "raw_purge_state TEXT NOT NULL DEFAULT 'pending'"
      '${includeContentSha256 ? ", content_sha256 TEXT" : ""})',
    );
    db.execute(
      'CREATE TABLE parser_rules ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'sender_hash TEXT NOT NULL UNIQUE, '
      'parser_family TEXT NOT NULL, '
      'created_at_epoch_ms INTEGER NOT NULL, '
      'parser_version TEXT, '
      'parser_checksum TEXT)',
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
      'CREATE TABLE schema_metadata (key TEXT NOT NULL PRIMARY KEY, '
      'value TEXT NOT NULL)',
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

    if (includeContentSha256) {
      db.execute(
        'INSERT INTO sms_events (source_key, sender_hash, redacted_body, '
        'ingestion_source, received_at_epoch_ms, status, privacy_epoch, '
        'capture_canonicalization_version, content_sha256) VALUES '
        "(?, ?, 'old msg', 'history_selection', 1000, 'captured', 0, 1, 'hash1'), "
        "(?, ?, 'legacy filtered', 'history_selection', 2000, "
        "'filtered_otp', 0, 1, 'hash2'), "
        "(?, ?, 'new key', 'manual_paste', 3000, 'review', 0, 2, 'hash3'), "
        "(?, ?, 'bogus status', 'history_selection', 4000, "
        "'not-a-status', 0, 2, 'hash4')",
        [
          'v1_${'a' * 64}',
          'SAMPATHTX',
          'v1_${'b' * 64}',
          'SAMPATH BANK',
          'v2_${'c' * 64}',
          'NDB',
          'v2_${'d' * 64}',
          'UNKNOWN',
        ],
      );
    } else {
      db.execute(
        'INSERT INTO sms_events (source_key, sender_hash, redacted_body, '
        'ingestion_source, received_at_epoch_ms, status, privacy_epoch, '
        'capture_canonicalization_version) VALUES '
        "(?, ?, 'old msg', 'history_selection', 1000, 'captured', 0, 1), "
        "(?, ?, 'legacy filtered', 'history_selection', 2000, "
        "'filtered_otp', 0, 1), "
        "(?, ?, 'new key', 'manual_paste', 3000, 'review', 0, 2), "
        "(?, ?, 'bogus status', 'history_selection', 4000, "
        "'not-a-status', 0, 2)",
        [
          'v1_${'a' * 64}',
          'SAMPATHTX',
          'v1_${'b' * 64}',
          'SAMPATH BANK',
          'v2_${'c' * 64}',
          'NDB',
          'v2_${'d' * 64}',
          'UNKNOWN',
        ],
      );
    }
    db.execute(
      "INSERT INTO schema_metadata (key, value) VALUES "
      "('tracked_senders', ?), ('other_key', 'keep-me')",
      [
        jsonEncode(['SAMPATHTX', 'NDB']),
      ],
    );
    db.execute(
      "INSERT INTO parser_rules (sender_hash, parser_family, "
      'created_at_epoch_ms) VALUES (\'SAMPATH\', \'account\', 100)',
    );
  }

  group('v6 → v7 migration', () {
    test(
      'renames sender columns, backfills display, normalizes status',
      () async {
        final db = await migrateFrom(6, seedV6Schema);
        addTearDown(db.close);

        final events = await db.select(db.smsEvents).get();
        expect(events, hasLength(4));
        expect(
          events.map((e) => e.senderKey),
          containsAll(['SAMPATHTX', 'NDB', 'SAMPATH BANK']),
        );
        expect(
          events.map((e) => e.senderDisplay),
          containsAll(['SAMPATHTX', 'NDB']),
        );
        for (final event in events) {
          expect(
            SmsEventStatus.values,
            contains(event.status),
            reason: 'every stored status must be a valid enum member',
          );
        }
        expect(
          events.firstWhere((e) => e.redactedBody == 'bogus status').status,
          SmsEventStatus.captured,
        );
      },
    );

    test('legacy v1 source keys keep their capture version', () async {
      final db = await migrateFrom(6, seedV6Schema);
      addTearDown(db.close);

      final events = await db.select(db.smsEvents).get();
      final v1Row = events.firstWhere((e) => e.sourceKey.startsWith('v1_'));
      final v2Row = events.firstWhere((e) => e.sourceKey.startsWith('v2_'));
      expect(v1Row.captureCanonicalizationVersion, 1);
      expect(v2Row.captureCanonicalizationVersion, 2);
    });

    test(
      'migrates tracked senders out of schema_metadata and deletes the key',
      () async {
        final db = await migrateFrom(6, seedV6Schema);
        addTearDown(db.close);

        final tracked = await db.select(db.trackedSenders).get();
        expect(tracked.map((t) => t.senderKey).toSet(), {'SAMPATHTX', 'NDB'});
        expect(tracked.every((t) => t.enabled), isTrue);

        final metadata = await db.select(db.databaseMetadata).get();
        expect(metadata.map((m) => m.key), isNot(contains('tracked_senders')));
        expect(metadata.map((m) => m.key), contains('other_key'));
      },
    );

    test('parser_rules accepts two families for one sender', () async {
      final db = await migrateFrom(6, seedV6Schema);
      addTearDown(db.close);

      await db
          .into(db.senderRules)
          .insert(
            SenderRulesCompanion.insert(
              senderHash: 'SAMPATH',
              parserFamily: 'card',
              createdAtEpochMs: 200,
            ),
          );

      final rows = await db.select(db.senderRules).get();
      expect(rows.map((r) => r.parserFamily).toSet(), {'account', 'card'});
      expect(rows.every((r) => r.priority == 0), isTrue);
    });

    test('creates both pagination indexes', () async {
      final db = await migrateFrom(6, seedV6Schema);
      addTearDown(db.close);

      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name IN ('idx_sms_events_received_desc', "
            "'idx_sms_events_sender_received', "
            "'idx_parser_rules_sender_family')",
          )
          .get();
      expect(indexes.map((r) => r.read<String>('name')).toSet(), {
        'idx_sms_events_received_desc',
        'idx_sms_events_sender_received',
        'idx_parser_rules_sender_family',
      });
    });

    test('no rows are lost across the upgrade', () async {
      final db = await migrateFrom(6, seedV6Schema);
      addTearDown(db.close);

      expect(await db.select(db.smsEvents).get(), hasLength(4));
      expect(await db.select(db.senderRules).get(), hasLength(1));
      final setting = await (db.select(
        db.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();
      expect(setting.privacyEpoch, 0);
    });
  });

  group('full v1 → v7 migration', () {
    test('migrates real v1 rows end to end', () async {
      final db = await migrateFrom(1, seedV1Schema);
      addTearDown(db.close);

      expect(db.schemaVersion, 14);
      final events = await db.select(db.smsEvents).get();
      expect(events, hasLength(1));
      final event = events.single;
      expect(event.senderKey, 'SAMPATH BANK');
      expect(event.senderDisplay, 'SAMPATH BANK');
      expect(event.captureCanonicalizationVersion, 1);
      expect(event.status, SmsEventStatus.captured);

      final tracked = await db.select(db.trackedSenders).get();
      expect(tracked.map((t) => t.senderKey), contains('SAMPATH BANK'));
      expect(
        (await db.select(db.databaseMetadata).get()).map((m) => m.key),
        isNot(contains('tracked_senders')),
      );

      await db
          .into(db.smsEvents)
          .insert(
            SmsEventsCompanion.insert(
              sourceKey: 'k7',
              senderKey: 'SENDER',
              ingestionSource: 'manual',
              receivedAtEpochMs: 1,
              status: SmsEventStatus.review,
              privacyEpoch: 0,
              captureCanonicalizationVersion: const Value(2),
            ),
          );
      final fresh = await (db.select(
        db.smsEvents,
      )..where((row) => row.sourceKey.equals('k7'))).getSingle();
      expect(fresh.captureCanonicalizationVersion, 2);
    });

    test('reaches schema 7 from v5', () async {
      final db = await migrateFrom(
        5,
        (db) => seedV6Schema(db, includeContentSha256: false),
      );
      addTearDown(db.close);
      expect(db.schemaVersion, 14);
      expect(await db.select(db.trackedSenders).get(), isNotEmpty);
      final events = await db.select(db.smsEvents).get();
      expect(events, hasLength(4));
      // content_sha256 was added by the v6 block; no backfill expected.
      expect(events.first.contentSha256, isNull);
      expect(events.first.captureCanonicalizationVersion, 1);
    });
  });
}
