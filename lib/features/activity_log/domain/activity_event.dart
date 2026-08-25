import '../../../core/privacy/redaction.dart';

enum ActivityEventCode {
  privacyEpochAdvanced('privacy.epoch.advanced'),
  rawCopyPurged('privacy.raw_copy.purged'),
  activityRetentionApplied('privacy.activity_retention.applied'),
  candidateNeedsReview('candidate.needs_review'),
  walletRecordCreated('wallet.record.created'),

  /// A create that did not end in a confirmed record — rejected, held for
  /// reconciliation, or scheduled for retry (M5.22 WP-N). Stored by `.name`
  /// like every other code, so adding it needs no migration.
  walletRecordFailed('wallet.record.failed'),
  walletConnected('wallet.connected'),
  walletDisconnected('wallet.disconnected'),
  walletRefreshed('wallet.refreshed'),
  mappingRuleCreated('mapping_rule.created'),
  logInfo('app.log.info'),
  logWarning('app.log.warning'),
  logError('app.log.error'),
  messageImported('sms.message.imported'),
  smsEventDeleted('sms.message.deleted');

  const ActivityEventCode(this.wireValue);

  final String wireValue;
}

enum ActivitySeverity { info, warning, error }

enum ActivityEntityType {
  smsEvent,
  transactionCandidate,
  walletRecord,
  appSetting,
}

final class ActivityEntityReference {
  ActivityEntityReference({required this.type, required String id})
    : id = _validateId(id);

  final ActivityEntityType type;
  final String id;

  static String _validateId(String value) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(value)) {
      throw ArgumentError('Entity IDs must be opaque safe IDs.');
    }
    return value;
  }
}

enum BankLabel { institutionA, institutionB, institutionC }

enum ActivityCurrency { lkr }

final class ActivityAmount {
  const ActivityAmount({required this.minorUnits, required this.currency});

  final int minorUnits;
  final ActivityCurrency currency;
}

enum ActivityStateTransition {
  rawCopyPurged,
  privacyEpochAdvanced,
  needsReview,
  logEvent,
}

enum SafeErrorCode { keyUnavailable, privacyEpochStale, retentionPurgeFailed }

final class CorrelationId {
  CorrelationId(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(value)) {
      throw ArgumentError('Correlation IDs must be opaque safe IDs.');
    }
    return value;
  }
}

/// Closed, typed fields only. Arbitrary maps and free text cannot be stored.
final class SanitizedActivityMetadata {
  SanitizedActivityMetadata({
    this.bankLabel,
    this.instrumentTail,
    this.amount,
    this.stateTransition,
    this.safeErrorCode,
    DateTime? retryAt,
    this.correlationId,
  }) : retryAt = retryAt?.toUtc();

  final BankLabel? bankLabel;
  final InstrumentTail? instrumentTail;
  final ActivityAmount? amount;
  final ActivityStateTransition? stateTransition;
  final SafeErrorCode? safeErrorCode;
  final DateTime? retryAt;
  final CorrelationId? correlationId;
}

/// A user-visible operational record, never a diagnostic dump.
final class ActivityEvent {
  ActivityEvent({
    required DateTime timestamp,
    required this.code,
    required this.severity,
    required this.entity,
    required this.metadata,
  }) : timestamp = timestamp.toUtc();

  final DateTime timestamp;
  final ActivityEventCode code;
  final ActivitySeverity severity;
  final ActivityEntityReference entity;
  final SanitizedActivityMetadata metadata;
}
