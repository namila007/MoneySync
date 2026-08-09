import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';

void main() {
  group('SmsPermissionStatus', () {
    test('unavailableInBuild is neither requestable nor readable', () {
      const status = SmsPermissionStatus.unavailableInBuild;
      expect(status.canRead, isFalse);
      expect(status.isRequestable, isFalse);
      expect(status.requiresSystemSettings, isFalse);
    });

    test('granted is the only status where canRead is true', () {
      for (final status in SmsPermissionStatus.values) {
        if (status == SmsPermissionStatus.granted) {
          expect(status.canRead, isTrue);
        } else {
          expect(status.canRead, isFalse);
        }
      }
    });

    test(
      'permanentlyDenied requires system settings and is not requestable',
      () {
        const status = SmsPermissionStatus.permanentlyDenied;
        expect(status.requiresSystemSettings, isTrue);
        expect(status.isRequestable, isFalse);
        expect(status.canRead, isFalse);
      },
    );

    test('revoked is requestable again', () {
      const status = SmsPermissionStatus.revoked;
      expect(status.isRequestable, isTrue);
      expect(status.canRead, isFalse);
      expect(status.requiresSystemSettings, isFalse);
    });

    test('notRequested is requestable', () {
      const status = SmsPermissionStatus.notRequested;
      expect(status.isRequestable, isTrue);
      expect(status.canRead, isFalse);
      expect(status.requiresSystemSettings, isFalse);
    });

    test('denied is requestable', () {
      const status = SmsPermissionStatus.denied;
      expect(status.isRequestable, isTrue);
      expect(status.canRead, isFalse);
      expect(status.requiresSystemSettings, isFalse);
    });

    test('granted is not requestable and does not require system settings', () {
      const status = SmsPermissionStatus.granted;
      expect(status.isRequestable, isFalse);
      expect(status.requiresSystemSettings, isFalse);
      expect(status.canRead, isTrue);
    });
  });
}
