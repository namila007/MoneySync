import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';

import '../domain/notification_request.dart';
import '../domain/notification_service.dart';

final _log = Logger('notifications');

class FlutterLocalNotificationsService implements NotificationService {
  FlutterLocalNotificationsService({required this.plugin});

  final FlutterLocalNotificationsPlugin plugin;
  bool _initialized = false;

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
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await initialize(androidDefaultIcon: '@mipmap/ic_launcher');
    } catch (e, s) {
      _log.error('Failed to lazy-initialize notifications', e, s);
      _initialized = true;
    }
  }

  @override
  Future<void> show(NotificationRequest request) async {
    try {
      await _ensureInitialized();
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
      _log.info('Notification shown: id=${request.id.value}');
    } catch (e, s) {
      _log.error('Notification show failed', e, s);
    }
  }

  @override
  Future<void> cancel(NotificationId id) async {
    try {
      await _ensureInitialized();
      await plugin.cancel(id: id.value);
      _log.info('Notification cancelled: id=${id.value}');
    } catch (e, s) {
      _log.error('Notification cancel failed', e, s);
    }
  }
}
