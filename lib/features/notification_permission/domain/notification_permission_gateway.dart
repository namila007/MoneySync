import 'notification_permission_status.dart';

abstract interface class NotificationPermissionGateway {
  Future<NotificationPermissionStatus> current();
  Future<NotificationPermissionStatus> request();
  Future<void> openAppSettings();
}
