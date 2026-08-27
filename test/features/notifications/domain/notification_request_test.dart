import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/notifications/domain/notification_request.dart';

void main() {
  group('NotificationRequest', () {
    test('fields round-trip through constructor', () {
      const id = NotificationId(42);
      const request = NotificationRequest(
        id: id,
        channelId: 'sms_scan',
        channelName: 'SMS Scan',
        title: 'Scanning',
        body: 'Background SMS scan in progress',
      );

      expect(request.id.value, 42);
      expect(request.channelId, 'sms_scan');
      expect(request.channelName, 'SMS Scan');
      expect(request.title, 'Scanning');
      expect(request.body, 'Background SMS scan in progress');
      expect(request.ongoing, isFalse);
    });

    test('ongoing defaults to false', () {
      const request = NotificationRequest(
        id: NotificationId(1),
        channelId: 'ch',
        channelName: 'Ch',
        title: 't',
        body: 'b',
      );
      expect(request.ongoing, isFalse);
    });

    test('ongoing can be set to true', () {
      const request = NotificationRequest(
        id: NotificationId(1),
        channelId: 'ch',
        channelName: 'Ch',
        title: 't',
        body: 'b',
        ongoing: true,
      );
      expect(request.ongoing, isTrue);
    });

    test('NotificationId equality', () {
      const a = NotificationId(1);
      const b = NotificationId(1);
      const c = NotificationId(2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
