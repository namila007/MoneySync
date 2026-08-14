import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Drift implementation of [ReviewOutboxWriter]: candidate revision, outbox
/// mutation + item, and activity event written in ONE transaction. Any
/// exception rolls all three back; a partial write is never observable (M5.9).
final class DriftReviewOutboxWriter implements ReviewOutboxWriter {
  DriftReviewOutboxWriter({required this._database});

  final AppDatabase _database;

  @override
  Future<bool> hasActiveLineage(String candidateId) async {
    final row = await _database
        .customSelect(
          'SELECT COUNT(*) AS n FROM wallet_mutations '
          'WHERE candidate_id = ? AND operation_kind = \'create\' '
          "AND state IN ('queued','syncing','reconciling',"
          "'unknown_delivery','retry_scheduled','succeeded')",
          variables: [Variable(candidateId)],
          readsFrom: {_database.walletMutations},
        )
        .getSingle();
    return row.read<int>('n') > 0;
  }

  @override
  Future<void> submitAtomically({
    required int smsEventId,
    required CandidateRecordState candidateState,
    required String encryptedPayload,
    required int revision,
    required int createdAtEpochMs,
    required int privacyEpoch,
    required WalletMutationIntent intent,
    required WalletItemLegRole itemLegRole,
    required String itemPayloadCiphertext,
    required ActivityEventCode activityType,
    required ActivityStateTransition safeDetailCode,
    required DecisionTraceCode decisionTraceCode,
  }) {
    return _database.transaction(() async {
      await _database.customInsert(
        'INSERT INTO transaction_candidates (sms_event_id, candidate_id, '
        'state, encrypted_payload, revision, created_at_epoch_ms) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        variables: [
          Variable(smsEventId),
          Variable(intent.candidateId),
          Variable(candidateState.name),
          Variable(encryptedPayload),
          Variable(revision),
          Variable(createdAtEpochMs),
        ],
      );
      await _database.customInsert(
        'INSERT INTO wallet_mutations (id, operation_kind, payload, state, '
        'lineage_key, fingerprint, created_at_epoch_ms, updated_at_epoch_ms, '
        'candidate_id, operation_revision, lineage_generation, '
        'payload_json_ciphertext) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable(intent.id),
          Variable(intent.operation.name),
          Variable(jsonEncode(intent.payload)),
          Variable(_storedState(intent.state)),
          Variable(intent.createLineageKey),
          Variable(intent.transactionFingerprint),
          Variable(createdAtEpochMs),
          Variable(createdAtEpochMs),
          Variable(intent.candidateId),
          Variable(intent.operationRevision),
          Variable(intent.lineageGeneration),
          Variable(jsonEncode(intent.payload)),
        ],
      );
      await _database.customInsert(
        'INSERT INTO wallet_mutation_item (wallet_mutation_id, item_index, '
        'leg_role, payload_ciphertext, state) VALUES (?, ?, ?, ?, ?)',
        variables: [
          Variable(intent.id),
          const Variable(0),
          Variable(itemLegRole.name),
          Variable(itemPayloadCiphertext),
          Variable(_storedState(intent.state)),
        ],
      );
      await _database.customInsert(
        'INSERT INTO activity_events (event_type, sanitized_detail, '
        'occurred_at_epoch_ms, privacy_epoch) VALUES (?, ?, ?, ?)',
        variables: [
          Variable(activityType.wireValue),
          Variable(safeDetailCode.name),
          Variable(createdAtEpochMs),
          Variable(privacyEpoch),
        ],
      );
      await _database.customInsert(
        'INSERT INTO decision_traces (candidate_id, trace_code, '
        'created_at_epoch_ms) SELECT id, ?, ? FROM transaction_candidates '
        'WHERE candidate_id = ?',
        variables: [
          Variable(decisionTraceCode.name),
          Variable(createdAtEpochMs),
          Variable(intent.candidateId),
        ],
      );
    }).catchError((Object error, StackTrace stack) {
      if (error is sqlite3.SqliteException &&
          error.extendedResultCode == 2067) {
        throw const UniqueLineageViolationException();
      }
      throw error;
    });
  }

  static String _storedState(WalletMutationState state) =>
      const WalletMutationStateConverter().toSql(state);
}
