import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';

void main() {
  group('NotificationPermissionStatus', () {
    test('granted is the only status where canNotify is true', () {
      for (final status in NotificationPermissionStatus.values) {
        if (status == NotificationPermissionStatus.granted) {
          expect(status.canNotify, isTrue);
        } else {
          expect(status.canNotify, isFalse);
        }
      }
    });

    test(
      'permanentlyDenied requires system settings and is not requestable',
      () {
        const status = NotificationPermissionStatus.permanentlyDenied;
        expect(status.requiresSystemSettings, isTrue);
        expect(status.isRequestable, isFalse);
        expect(status.canNotify, isFalse);
      },
    );

    test('notRequested is requestable', () {
      const status = NotificationPermissionStatus.notRequested;
      expect(status.isRequestable, isTrue);
      expect(status.canNotify, isFalse);
      expect(status.requiresSystemSettings, isFalse);
    });

    test('denied is requestable', () {
      const status = NotificationPermissionStatus.denied;
      expect(status.isRequestable, isTrue);
      expect(status.canNotify, isFalse);
      expect(status.requiresSystemSettings, isFalse);
    });

    test('granted is not requestable and does not require system settings', () {
      const status = NotificationPermissionStatus.granted;
      expect(status.isRequestable, isFalse);
      expect(status.requiresSystemSettings, isFalse);
      expect(status.canNotify, isTrue);
    });
  });
}
