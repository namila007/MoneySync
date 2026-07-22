import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/privacy/redaction.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';

void main() {
  test('activity event has only typed, allowlisted, sanitized metadata', () {
    final event = ActivityEvent(
      timestamp: DateTime(2026, 7, 22, 13, 30),
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
        retryAt: DateTime(2026, 7, 22, 14),
        correlationId: CorrelationId('work_01'),
      ),
    );

    expect(event.timestamp, DateTime.utc(2026, 7, 22, 8));
    expect(event.code.wireValue, 'privacy.raw_copy.purged');
    expect(event.metadata.instrumentTail, InstrumentTail('12'));
    expect(event.metadata.retryAt, DateTime.utc(2026, 7, 22, 8, 30));
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
      final metadata = SanitizedActivityMetadata(
        retryAt: DateTime(2026, 7, 22, 13, 30),
        safeErrorCode: SafeErrorCode.keyUnavailable,
      );

      expect(metadata.bankLabel, isNull);
      expect(metadata.instrumentTail, isNull);
      expect(metadata.amount, isNull);
      expect(metadata.stateTransition, isNull);
      expect(metadata.correlationId, isNull);
      expect(metadata.safeErrorCode, SafeErrorCode.keyUnavailable);
      expect(metadata.retryAt, DateTime.utc(2026, 7, 22, 8));
    },
  );
}
