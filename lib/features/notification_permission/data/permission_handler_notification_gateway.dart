import 'package:permission_handler/permission_handler.dart' as ph;

import '../domain/notification_permission_gateway.dart';
import '../domain/notification_permission_status.dart';

class PermissionHandlerNotificationGateway
    implements NotificationPermissionGateway {
  @override
  Future<NotificationPermissionStatus> current() async {
    final status = await ph.Permission.notification.status;
    return _mapStatus(status);
  }

  @override
  Future<NotificationPermissionStatus> request() async {
    final status = await ph.Permission.notification.request();
    return _mapStatus(status);
  }

  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  NotificationPermissionStatus _mapStatus(ph.PermissionStatus status) =>
      switch (status) {
        ph.PermissionStatus.granted => NotificationPermissionStatus.granted,
        ph.PermissionStatus.denied => NotificationPermissionStatus.denied,
        ph.PermissionStatus.permanentlyDenied =>
          NotificationPermissionStatus.permanentlyDenied,
        _ => NotificationPermissionStatus.notRequested,
      };
}
