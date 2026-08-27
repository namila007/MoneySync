import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/notifications/data/flutter_local_notifications_service.dart';
import 'package:money_sync/features/notifications/domain/notification_request.dart';

class FakeAndroidPlugin extends AndroidFlutterLocalNotificationsPlugin {
  final List<AndroidNotificationChannel> channels = [];
  final List<Map<String, Object?>> shown = [];
  final List<int> cancelled = [];

  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    channels.add(channel);
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    AndroidNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    shown.add(<String, Object?>{'id': id, 'title': title, 'body': body});
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelled.add(id);
  }
}

void main() {
  late FlutterLocalNotificationsService service;
  late FakeAndroidPlugin fakeAndroid;
  late FlutterLocalNotificationsPlugin plugin;

  setUp(() {
    fakeAndroid = FakeAndroidPlugin();
    plugin = FlutterLocalNotificationsPlugin();
    FlutterLocalNotificationsPlatform.instance = fakeAndroid;
    service = FlutterLocalNotificationsService(plugin: plugin);
  });

  group('FlutterLocalNotificationsService', () {
    test('show creates channel and posts notification', () async {
      const request = NotificationRequest(
        id: NotificationId(1),
        channelId: 'test_channel',
        channelName: 'Test Channel',
        title: 'Test',
        body: 'Body',
      );

      await service.show(request);

      expect(fakeAndroid.channels, hasLength(1));
      expect(fakeAndroid.channels.first.id, 'test_channel');
      expect(fakeAndroid.channels.first.name, 'Test Channel');
      expect(fakeAndroid.shown, hasLength(1));
      expect(fakeAndroid.shown.first['id'], 1);
      expect(fakeAndroid.shown.first['title'], 'Test');
      expect(fakeAndroid.shown.first['body'], 'Body');
    });

    test(
      'showing same id twice creates channel once and posts twice',
      () async {
        const request = NotificationRequest(
          id: NotificationId(2),
          channelId: 'test_channel',
          channelName: 'Test Channel',
          title: 'First',
          body: 'First body',
        );
        await service.show(request);

        const updated = NotificationRequest(
          id: NotificationId(2),
          channelId: 'test_channel',
          channelName: 'Test Channel',
          title: 'Updated',
          body: 'Updated body',
        );
        await service.show(updated);

        expect(fakeAndroid.channels, hasLength(2));
        expect(fakeAndroid.shown, hasLength(2));
        expect(fakeAndroid.shown.last['title'], 'Updated');
      },
    );

    test('cancel removes notification by id', () async {
      const request = NotificationRequest(
        id: NotificationId(3),
        channelId: 'test_channel',
        channelName: 'Test Channel',
        title: 'To cancel',
        body: 'Will be removed',
      );
      await service.show(request);
      await service.cancel(const NotificationId(3));

      expect(fakeAndroid.cancelled, [3]);
    });

    test('cancel does not throw for non-existent id', () async {
      await expectLater(service.cancel(const NotificationId(999)), completes);
      expect(fakeAndroid.cancelled, [999]);
    });
  });
}
