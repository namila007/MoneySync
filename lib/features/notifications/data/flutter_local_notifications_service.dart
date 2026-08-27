import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/notification_request.dart';
import '../domain/notification_service.dart';

class FlutterLocalNotificationsService implements NotificationService {
  FlutterLocalNotificationsService({required this.plugin});

  final FlutterLocalNotificationsPlugin plugin;

  Future<void> initialize({
    required String androidDefaultIcon,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    final androidSettings = AndroidInitializationSettings(androidDefaultIcon);
    final settings = InitializationSettings(android: androidSettings);
    await plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  @override
  Future<void> show(NotificationRequest request) async {
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final channel = AndroidNotificationChannel(
        request.channelId,
        request.channelName,
        importance: Importance.low,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    final androidDetails = AndroidNotificationDetails(
      request.channelId,
      request.channelName,
      importance: Importance.low,
      priority: Priority.low,
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.show(
      id: request.id.value,
      title: request.title,
      body: request.body,
      notificationDetails: details,
    );
  }

  @override
  Future<void> cancel(NotificationId id) async {
    await plugin.cancel(id: id.value);
  }
}
