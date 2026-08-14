import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// App-owned content governed by the short-retention privacy policy.
enum AppOwnedContent { otp, unrelated, rejected, processedRaw, activity }

/// A user choice for retaining encrypted, app-owned raw copies.
final class RawCopyRetention {
  const RawCopyRetention._(this.duration);

  static const disabled = RawCopyRetention._(Duration.zero);
  static const maximumDuration = Duration(days: 30);

  final Duration duration;

  factory RawCopyRetention.keepFor(Duration duration) {
    if (duration <= Duration.zero || duration > maximumDuration) {
      throw ArgumentError(
        'Raw-copy retention must be greater than zero and no more than 30 days.',
      );
    }
    return RawCopyRetention._(duration);
  }

  bool get isEnabled => duration > Duration.zero;
}

/// The outcome for a single app-owned item. It never controls a source SMS.
final class RetentionDecision {
  const RetentionDecision.purgeAt(this.purgeAt);

  final DateTime purgeAt;

  @override
  bool operator ==(Object other) =>
      other is RetentionDecision && other.purgeAt == purgeAt;

  @override
  int get hashCode => purgeAt.hashCode;
}

/// Deterministic default retention policy for app-owned data only.
final class RetentionPolicy {
  const RetentionPolicy();

  static const activityRetention = Duration(days: 180);

  RetentionDecision decide({
    required AppOwnedContent content,
    required DateTime observedAt,
    RawCopyRetention rawCopyPreference = RawCopyRetention.disabled,
  }) {
    final timestamp = observedAt.toUtc();
    return switch (content) {
      AppOwnedContent.otp ||
      AppOwnedContent.unrelated ||
      AppOwnedContent.rejected => RetentionDecision.purgeAt(timestamp),
      AppOwnedContent.processedRaw => RetentionDecision.purgeAt(
        timestamp.add(rawCopyPreference.duration),
      ),
      AppOwnedContent.activity => RetentionDecision.purgeAt(
        timestamp.add(activityRetention),
      ),
    };
  }
}

final class RetentionSweepResult {
  const RetentionSweepResult({
    required this.purgedOnFilter,
    required this.purgedAfterProcessing,
    required this.purgedOnExpiry,
    required this.retainedByConsent,
    required this.skipped,
  });

  final int purgedOnFilter;
  final int purgedAfterProcessing;
  final int purgedOnExpiry;
  final int retainedByConsent;
  final int skipped;

  int get totalPurged =>
      purgedOnFilter + purgedAfterProcessing + purgedOnExpiry;
}

/// Purges expired encrypted bodies while preserving canonical identity.
///
/// Only [encrypted_body] is cleared; [source_key], [sender_hash],
/// [received_at_epoch_ms], and the candidate row survive so duplicate
/// detection keeps working after purge. Never touches `activity_events`.
final class RawBodyRetentionSweep {
  RawBodyRetentionSweep({required this.database, required this.retentionDays})
    : _clampedRetentionDays = retentionDays.clamp(0, 30);

  final AppDatabase database;
  final int retentionDays;
  final int _clampedRetentionDays;

  Future<RetentionSweepResult> call({required DateTime nowUtc}) async {
    final nowEpochMs = nowUtc.millisecondsSinceEpoch;

    int purgedOnFilter = 0;
    int purgedAfterProcessing = 0;
    int purgedOnExpiry = 0;
    int retainedByConsent = 0;
    int skipped = 0;

    await database.transaction(() async {
      final pendingEvents = await database
          .customSelect(
            "SELECT * FROM sms_events WHERE raw_purge_state = '${RawPurgeState.pending.name}'",
            readsFrom: {database.smsEvents},
          )
          .get();

      for (final row in pendingEvents) {
        final id = row.read<int>('id');
        final status = row.read<String>('status');

        final purgeState = _determinePurgeState(
          status,
          row.read<int?>('expires_at_epoch_ms'),
          nowEpochMs,
          row.read<String>('ingestion_source'),
        );

        switch (purgeState) {
          case RawPurgeState.purgedOnFilter:
            await _clearBodyAndTransition(database, id, purgeState);
            purgedOnFilter++;
          case RawPurgeState.purgedAfterProcessing:
            await _clearBodyAndTransition(database, id, purgeState);
            purgedAfterProcessing++;
          case RawPurgeState.purgedOnExpiry:
            await _clearBodyAndTransition(database, id, purgeState);
            purgedOnExpiry++;
          case RawPurgeState.purgedOnUserRequest:
            skipped++;
          case RawPurgeState.retainedByConsent:
            await _markRetained(database, id);
            retainedByConsent++;
          case RawPurgeState.pending:
            skipped++;
        }
      }
    });

    return RetentionSweepResult(
      purgedOnFilter: purgedOnFilter,
      purgedAfterProcessing: purgedAfterProcessing,
      purgedOnExpiry: purgedOnExpiry,
      retainedByConsent: retainedByConsent,
      skipped: skipped,
    );
  }

  RawPurgeState _determinePurgeState(
    String status,
    int? expiresAtEpochMs,
    int nowEpochMs,
    String ingestionSource,
  ) {
    if (_isFilteredStatus(status)) {
      return RawPurgeState.purgedOnFilter;
    }

    if (_clampedRetentionDays == 0) {
      return RawPurgeState.purgedAfterProcessing;
    }

    if (expiresAtEpochMs != null && expiresAtEpochMs <= nowEpochMs) {
      return RawPurgeState.purgedOnExpiry;
    }

    if (_clampedRetentionDays > 0) {
      return RawPurgeState.retainedByConsent;
    }

    return RawPurgeState.purgedAfterProcessing;
  }

  static bool _isFilteredStatus(String status) {
    // M4.14 §3.2: `ignored` is the closed-enum member for triage-filtered
    // messages. The legacy strings only exist in pre-v7 rows; the v7
    // migration remaps them, but keep matching defensively.
    return status == SmsEventStatus.ignored.name ||
        status == 'filtered_otp' ||
        status == 'filtered_unrelated' ||
        status == 'filtered_promotional' ||
        status == 'rejected';
  }

  Future<void> _clearBodyAndTransition(
    AppDatabase database,
    int eventId,
    RawPurgeState targetState,
  ) async {
    await (database.update(
      database.smsEvents,
    )..where((row) => row.id.equals(eventId))).write(
      SmsEventsCompanion(
        encryptedBody: const Value<String?>(null),
        rawPurgeState: Value(targetState),
      ),
    );
  }

  Future<void> _markRetained(AppDatabase database, int eventId) async {
    await (database.update(
      database.smsEvents,
    )..where((row) => row.id.equals(eventId))).write(
      const SmsEventsCompanion(
        rawPurgeState: Value(RawPurgeState.retainedByConsent),
      ),
    );
  }
}
