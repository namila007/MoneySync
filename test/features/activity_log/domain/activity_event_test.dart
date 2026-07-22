import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/redaction.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';

void main() {
  test('activity event has only typed, allowlisted, sanitized metadata', () {
    final timestamp = DateTime(2026, 7, 22, 13, 30);
    final retryAt = DateTime(2026, 7, 22, 14);
    final event = ActivityEvent(
      timestamp: timestamp,
      code: ActivityEventCode.rawCopyPurged,
      severity: ActivitySeverity.info,
      entity: ActivityEntityReference(
        type: ActivityEntityType.smsEvent,
        id: 'sms_01',
      ),
      metadata: SanitizedActivityMetadata(
        bankLabel: BankLabel.institutionA,
        instrumentTail: InstrumentTail('12'),
        amount: ActivityAmount(
          minorUnits: 1250,
          currency: ActivityCurrency.lkr,
        ),
        stateTransition: ActivityStateTransition.rawCopyPurged,
        retryAt: retryAt,
        correlationId: CorrelationId('work_01'),
      ),
    );

    expect(event.timestamp, timestamp.toUtc());
    expect(event.timestamp.isUtc, isTrue);
    expect(event.code.wireValue, 'privacy.raw_copy.purged');
    expect(event.metadata.instrumentTail, InstrumentTail('12'));
    expect(event.metadata.retryAt, retryAt.toUtc());
    expect(event.metadata.retryAt!.isUtc, isTrue);
  });

  test('opaque IDs and correlation IDs reject arbitrary text', () {
    expect(
      () => ActivityEntityReference(
        type: ActivityEntityType.smsEvent,
        id: 'has space',
      ),
      throwsArgumentError,
    );
    expect(() => CorrelationId('contains space'), throwsArgumentError);
  });

  test(
    'activity IDs accept opaque boundary values and reject overlong values',
    () {
      final maximumLengthId = 'a' * 64;

      expect(
        ActivityEntityReference(
          type: ActivityEntityType.appSetting,
          id: maximumLengthId,
        ).id,
        maximumLengthId,
      );
      expect(CorrelationId('_').value, '_');
      expect(
        () => ActivityEntityReference(
          type: ActivityEntityType.walletRecord,
          id: 'x' * 65,
        ),
        throwsArgumentError,
      );
      expect(() => CorrelationId(''), throwsArgumentError);
    },
  );

  test(
    'metadata defaults to no optional details and normalizes retry time',
    () {
      final retryAt = DateTime(2026, 7, 22, 13, 30);
      final metadata = SanitizedActivityMetadata(
        retryAt: retryAt,
        safeErrorCode: SafeErrorCode.keyUnavailable,
      );

      expect(metadata.bankLabel, isNull);
      expect(metadata.instrumentTail, isNull);
      expect(metadata.amount, isNull);
      expect(metadata.stateTransition, isNull);
      expect(metadata.correlationId, isNull);
      expect(metadata.safeErrorCode, SafeErrorCode.keyUnavailable);
      expect(metadata.retryAt, retryAt.toUtc());
      expect(metadata.retryAt!.isUtc, isTrue);
    },
  );
}
