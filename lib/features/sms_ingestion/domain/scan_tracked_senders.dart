import 'dart:async';

import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart'
    hide TransactionCandidate;
import 'package:money_sync/features/notifications/domain/notification_request.dart';
import 'package:money_sync/features/notifications/domain/notification_service.dart';
import 'package:money_sync/features/sms_ingestion/application/import_sms_history.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/source_identity.dart';
import 'package:money_sync/features/sms_tracking/domain/tracked_senders.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';

const NotificationId _scanNotificationId = NotificationId(1001);
const String _scanChannelId = 'background_sms_scan';
const String _scanChannelName = 'Background SMS Scan';

/// Periodic background scan use case for auto-import (M6.4).
///
/// Separated from `callbackDispatcher` so it is unit-testable without a real
/// isolate. The headless isolate constructs this from its own composition root
/// and calls [call].
final class ScanTrackedSenders {
  const ScanTrackedSenders({
    required this.database,
    required this.smsHistoryApi,
    required this.registry,
    required this.identitySigner,
    required this.notificationService,
    required this.trackedSendersRepository,
    this.candidateHook,
  });

  final AppDatabase database;
  final SmsHistoryHostApi smsHistoryApi;
  final RulePackRegistry registry;
  final SourceIdentitySigner identitySigner;
  final NotificationService notificationService;
  final TrackedSendersRepository trackedSendersRepository;

  /// Optional M6.5 auto-create hook. Passed through to [ImportSmsHistory].
  final Future<bool> Function(
    TransactionCandidate candidate,
    int eventId,
    String candidatePayload,
    String normalizedSender,
  )?
  candidateHook;

  /// Default scan window for a never-scanned install: 7 days, matching
  /// `HistoryImportPreferences.windowDays`.
  static const _defaultWindowDays = 7;

  /// Reads tracking_state + app_settings, no-ops if autoImportEnabled is
  /// false, otherwise runs ImportSmsHistory.import() with fromEpochMs from
  /// the watermark, posts/updates the lifecycle notification, and writes
  /// the new watermark only after the import stream completes.
  Future<void> call() async {
    // 1. Check auto-import toggle.
    final setting = await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();

    if (!setting.autoImportEnabled) return;

    // 2. Read tracking state; compute fromEpochMs from watermark or default.
    final tracking = await database.trackingStateOrDefault();
    final now = DateTime.now();
    final fromEpochMs =
        tracking.lastScanAtEpochMs ??
        now
            .subtract(const Duration(days: _defaultWindowDays))
            .millisecondsSinceEpoch;
    final untilEpochMs = now.millisecondsSinceEpoch;
    final privacyEpoch = setting.privacyEpoch;

    // 3. Load tracked senders; bail if empty.
    final senders = await trackedSendersRepository.load();
    if (senders.isEmpty) return;

    final senderAddresses = [for (final s in senders) s.address];

    // 4. Post ongoing notification.
    await notificationService.show(
      const NotificationRequest(
        id: _scanNotificationId,
        channelId: _scanChannelId,
        channelName: _scanChannelName,
        title: 'Checking for new messages…',
        body: '',
        ongoing: true,
      ),
    );

    // 5. Drive the import stream to completion.
    final import = ImportSmsHistory(
      database: database,
      smsHistoryApi: smsHistoryApi,
      registry: registry,
      identitySigner: identitySigner,
      candidateHook: candidateHook,
    );

    var imported = 0;

    ImportProgress? terminal;
    await for (final progress in import.import(
      fromEpochMs: fromEpochMs,
      untilEpochMs: untilEpochMs,
      messageCap: setting.historyMessageCap,
      privacyEpoch: privacyEpoch,
      trackedSenders: senderAddresses,
    )) {
      switch (progress) {
        case ImportInProgress():
          imported = progress.imported;
        case ImportCompleted():
          imported = progress.imported;
          terminal = progress;
        case ImportCapReached():
          imported = progress.imported;
          terminal = progress;
        case ImportCancelled():
          terminal = progress;
        case ImportNoTrackedSenders():
          terminal = progress;
        case ImportStatusError():
          terminal = progress;
        case ImportBlockedByEpoch():
          terminal = progress;
      }
    }

    // 6–8. Handle terminal outcome.
    if (terminal is ImportCompleted || terminal is ImportCapReached) {
      // Success — advance watermark.
      final body = imported > 0 ? '$imported new' : 'No new messages';
      await notificationService.show(
        NotificationRequest(
          id: _scanNotificationId,
          channelId: _scanChannelId,
          channelName: _scanChannelName,
          title: 'Messages imported',
          body: body,
        ),
      );
      await database.updateTrackingState(
        lastScanAtEpochMs: Value(now.millisecondsSinceEpoch),
        lastScanOutcome: const Value('ok'),
        privacyEpoch: Value(privacyEpoch),
      );
    } else if (terminal is ImportStatusError ||
        terminal is ImportBlockedByEpoch) {
      // Failure — do NOT advance watermark.
      await notificationService.show(
        const NotificationRequest(
          id: _scanNotificationId,
          channelId: _scanChannelId,
          channelName: _scanChannelName,
          title: 'Messages imported',
          body: "Couldn't check for new messages",
        ),
      );
      await database.updateTrackingState(
        lastScanOutcome: const Value('failed'),
        lastSafeErrorCode: Value(
          terminal is ImportStatusError ? 'import_error' : 'epoch_blocked',
        ),
      );
    }
    // ImportCancelled / ImportNoTrackedSenders — no notification update, no
    // watermark change.
  }
}
