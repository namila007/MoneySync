import 'dart:async';

import 'package:money_sync/core/database/app_database.dart'
    hide TransactionCandidate;
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/transaction_parser/domain/interpret_message.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:logging/logging.dart';

final class ImportSmsHistory {
  ImportSmsHistory({
    required this.database,
    required this.smsHistoryApi,
    required this.registry,
    required this.identitySigner,
    this.candidateHook,
  });

  final AppDatabase database;
  final SmsHistoryHostApi smsHistoryApi;

  /// Registry of active packs, injected from the data layer — packs are data
  /// (M4.14 WP5), never a static here.
  final RulePackRegistry registry;

  /// Keyed-HMAC boundary for canonical identity (M4.14 WP4).
  final SourceIdentitySigner identitySigner;

  /// Optional M6.5 auto-create hook. Passed through to [IngestManualMessage].
  final Future<bool> Function(
    TransactionCandidate candidate,
    int eventId,
    String candidatePayload,
  )?
  candidateHook;

  static const pageSize = 25;
  static const hardCap = 500;

  Future<InterpretationResult> _interpret({
    required String rawBody,
    required String sender,
    required DateTime receivedAtUtc,
  }) async => InterpretMessage(registry: registry)(
    rawBody: rawBody,
    sender: sender,
    receivedAtUtc: receivedAtUtc,
  );

  final _log = Logger('sms.history');
  bool _cancelRequested = false;

  void cancel() {
    _cancelRequested = true;
    _log.info('Import cancelled by user');
  }

  /// One aggregated `messageImported` activity event per batch run (M4.15
  /// WP3) instead of one per message. Best-effort: a failed activity write
  /// must never fail the import itself.
  Future<void> _recordBatchImportActivity({
    required int imported,
    required int privacyEpoch,
  }) async {
    if (imported <= 0) return;
    try {
      await database.insertActivity(
        activityType: ActivityEventCode.messageImported,
        safeDetailCode: ActivityStateTransition.logEvent,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: privacyEpoch,
        count: imported,
        detailMessage: '$imported messages imported',
      );
      _log.info('Recorded aggregate import activity: $imported messages');
    } catch (e) {
      _log.warning('Aggregate import activity not recorded', e);
    }
  }

  /// One aggregated `candidateNeedsReview` event per batch (Bug 8.2) instead
  /// of one per interpreted message. Mirrors _recordBatchImportActivity.
  Future<void> _recordBatchCandidateActivity({
    required int count,
    required int privacyEpoch,
  }) async {
    if (count <= 0) return;
    try {
      await database.insertActivity(
        activityType: ActivityEventCode.candidateNeedsReview,
        safeDetailCode: ActivityStateTransition.needsReview,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: privacyEpoch,
        count: count,
        detailMessage: '$count transactions need review',
      );
      _log.info('Recorded aggregate candidate activity: $count need review');
    } catch (e) {
      _log.warning('Aggregate candidate activity not recorded', e);
    }
  }

  Stream<ImportProgress> import({
    required int fromEpochMs,
    required int untilEpochMs,
    required int messageCap,
    required int privacyEpoch,
    required List<String> trackedSenders,
  }) async* {
    _cancelRequested = false;

    if (trackedSenders.isEmpty) {
      _log.warning('Import refused: no tracked senders configured');
      yield const ImportNoTrackedSenders();
      return;
    }

    final cap = messageCap.clamp(1, hardCap);
    var offset = 0;
    var imported = 0;
    var filtered = 0;
    var duplicates = 0;
    var candidatesNeedingReview = 0;
    var pages = 0;

    try {
      while (true) {
        if (_cancelRequested) {
          _log.info(
            'Import cancelled after $imported imported, $filtered filtered',
          );
          await _recordBatchImportActivity(
            imported: imported,
            privacyEpoch: privacyEpoch,
          );
          await _recordBatchCandidateActivity(
            count: candidatesNeedingReview,
            privacyEpoch: privacyEpoch,
          );
          yield ImportProgress.cancelled(imported, filtered, duplicates);
          return;
        }

        final pageSizeEffective = (pageSize < (cap - imported))
            ? pageSize
            : (cap - imported);
        if (pageSizeEffective <= 0) {
          _log.info('Cap reached: $imported of $cap');
          await _recordBatchImportActivity(
            imported: imported,
            privacyEpoch: privacyEpoch,
          );
          await _recordBatchCandidateActivity(
            count: candidatesNeedingReview,
            privacyEpoch: privacyEpoch,
          );
          yield ImportProgress.capReached(imported, filtered, duplicates);
          return;
        }

        final request = SmsHistoryRequest(
          fromEpochMs: fromEpochMs,
          untilEpochMs: untilEpochMs,
          limit: pageSizeEffective,
          offset: offset,
          senderFilters: trackedSenders,
        );

        SmsHistoryPageResult page;
        try {
          page = await smsHistoryApi.queryInbox(request);
        } catch (e) {
          _log.severe('Query failed at offset $offset', e);
          yield ImportProgress.error('Failed to read messages: $e');
          return;
        }

        final messages = page.messages.whereType<SmsHistoryMessage>().toList();
        if (messages.isEmpty) {
          _log.info('No more messages at offset $offset');
          break;
        }

        final setting = await (database.select(
          database.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        if (setting.privacyEpoch != privacyEpoch) {
          _log.warning('Privacy epoch advanced during import');
          yield ImportProgress.blockedByEpoch();
          return;
        }

        final ingest = IngestManualMessage(
          database: database,
          interpret: _interpret,
          identitySigner: identitySigner,
          candidateHook: candidateHook,
        );
        for (final msg in messages) {
          if (_cancelRequested) break;
          if (imported >= cap) break;

          final outcome = await ingest(
            rawBody: msg.body,
            rawSender: msg.address,
            source: IngestionSource.historySelection,
            userOverrodeFilter: false,
            epochMs: msg.dateEpochMs,
            privacyEpoch: privacyEpoch,
            // One aggregate event per batch, recorded at the terminal state.
            recordImportActivity: false,
            recordCandidateActivity: false,
          );

          switch (outcome) {
            case ManualIngestStored(:final autoCreated):
              imported++;
              if (!autoCreated) candidatesNeedingReview++;
            case ManualIngestAlreadyPresent():
              duplicates++;
            case ManualIngestFiltered():
              filtered++;
            case ManualIngestRejected():
              filtered++;
            case ManualIngestBlockedByEpoch():
              yield ImportProgress.blockedByEpoch();
              return;
          }
        }

        offset += messages.length;
        pages++;

        _log.info(
          'Page $pages: $imported imported, $filtered filtered, $duplicates duplicates',
        );

        yield ImportProgress.progress(
          imported,
          filtered,
          duplicates,
          page.hasMore,
        );

        if (!page.hasMore) break;
      }

      _log.info(
        'Import complete: $imported imported, $filtered filtered, $duplicates duplicates',
      );
      await _recordBatchImportActivity(
        imported: imported,
        privacyEpoch: privacyEpoch,
      );
      await _recordBatchCandidateActivity(
        count: candidatesNeedingReview,
        privacyEpoch: privacyEpoch,
      );
      yield ImportProgress.completed(imported, filtered, duplicates);
    } catch (e) {
      _log.severe('Import failed', e);
      yield ImportProgress.error('Import failed: $e');
    }
  }
}

sealed class ImportProgress {
  const ImportProgress();

  const factory ImportProgress.progress(
    int imported,
    int filtered,
    int duplicates,
    bool hasMore,
  ) = ImportInProgress;

  const factory ImportProgress.completed(
    int imported,
    int filtered,
    int duplicates,
  ) = ImportCompleted;

  const factory ImportProgress.cancelled(
    int imported,
    int filtered,
    int duplicates,
  ) = ImportCancelled;

  const factory ImportProgress.capReached(
    int imported,
    int filtered,
    int duplicates,
  ) = ImportCapReached;

  const factory ImportProgress.error(String message) = ImportStatusError;
  const factory ImportProgress.blockedByEpoch() = ImportBlockedByEpoch;
  const factory ImportProgress.noTrackedSenders() = ImportNoTrackedSenders;
}

class ImportNoTrackedSenders extends ImportProgress {
  const ImportNoTrackedSenders();
}

class ImportInProgress extends ImportProgress {
  const ImportInProgress(
    this.imported,
    this.filtered,
    this.duplicates,
    this.hasMore,
  );
  final int imported;
  final int filtered;
  final int duplicates;
  final bool hasMore;
}

class ImportCompleted extends ImportProgress {
  const ImportCompleted(this.imported, this.filtered, this.duplicates);
  final int imported;
  final int filtered;
  final int duplicates;
}

class ImportCancelled extends ImportProgress {
  const ImportCancelled(this.imported, this.filtered, this.duplicates);
  final int imported;
  final int filtered;
  final int duplicates;
}

class ImportCapReached extends ImportProgress {
  const ImportCapReached(this.imported, this.filtered, this.duplicates);
  final int imported;
  final int filtered;
  final int duplicates;
}

class ImportStatusError extends ImportProgress {
  const ImportStatusError(this.message);
  final String message;
}

class ImportBlockedByEpoch extends ImportProgress {
  const ImportBlockedByEpoch();
}
