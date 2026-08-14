import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_ingestion/domain/manual_input_validation.dart';

void main() {
  group('ManualInputValidation', () {
    test('rejects empty input', () {
      final result = validateManualInput('');
      expect(result, isA<ManualInputRejected>());
      expect(
        (result as ManualInputRejected).reason,
        ManualInputRejection.empty,
      );
    });

    test('rejects input below kMinBodyLength', () {
      final result = validateManualInput('short');
      expect(result, isA<ManualInputRejected>());
      expect(
        (result as ManualInputRejected).reason,
        ManualInputRejection.tooShort,
      );
    });

    test('rejects input above kMaxBodyLength', () {
      final long = 'x' * (kMaxBodyLength + 1);
      final result = validateManualInput(long);
      expect(result, isA<ManualInputRejected>());
      expect(
        (result as ManualInputRejected).reason,
        ManualInputRejection.tooLong,
      );
    });

    test('rejects non text/plain mime', () {
      final result = validateManualInput(
        'LKR 1,250.00 debited from account',
        mimeType: 'image/png',
      );
      expect(
        result,
        const ManualInputRejected(ManualInputRejection.unsupportedMimeType),
      );
    });

    test(
      'a body starting with "Rejected:" is still accepted as text/plain',
      () {
        final result = validateManualInput(
          'Rejected: your card payment of LKR 500.00 was declined',
        );
        expect(result, isA<ManualInputAccepted>());
        expect(
          (result as ManualInputAccepted).normalizedBody,
          startsWith('Rejected:'),
        );
      },
    );

    test('empty sender becomes UNKNOWN', () {
      final result = validateManualInput(
        'LKR 1,250.00 debited from account',
        rawSender: '',
      );
      expect(result, isA<ManualInputAccepted>());
      expect((result as ManualInputAccepted).normalizedSender, 'UNKNOWN');
    });

    test('sender is uppercased', () {
      final result = validateManualInput(
        'LKR 1,250.00 debited from account',
        rawSender: 'sampath bank',
      );
      expect(result, isA<ManualInputAccepted>());
      expect((result as ManualInputAccepted).normalizedSender, 'SAMPATH BANK');
    });

    test('normalisation collapses spaces and tabs', () {
      final result = validateManualInput(
        'LKR    1,250.00\ndebited  from    account',
      );
      expect(result, isA<ManualInputAccepted>());
      final body = (result as ManualInputAccepted).normalizedBody;
      expect(body, contains('LKR 1,250.00\ndebited from account'));
    });

    test('normalisation preserves newlines', () {
      final result = validateManualInput(
        'LKR 1,250.00 debited\nfor TFR John\nDate: 2024-01-15',
      );
      expect(result, isA<ManualInputAccepted>());
      final body = (result as ManualInputAccepted).normalizedBody;
      expect(body.contains('\n'), isTrue);
    });

    test('redacted preview masks amounts and dates', () {
      final result = validateManualInput(
        'LKR 1,250.00 debited on 2024-01-15 10:30:00 from account',
      );
      expect(result, isA<ManualInputAccepted>());
      final preview = (result as ManualInputAccepted).redactedPreview;
      expect(preview, isNot(contains('1,250.00')));
      expect(preview, isNot(contains('2024-01-15 10:30:00')));
    });
  });
}
