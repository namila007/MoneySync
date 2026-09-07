import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../domain/notification_permission_gateway.dart';
import '../domain/notification_permission_status.dart';

final _log = Logger('notification_permission');

class PermissionHandlerNotificationGateway
    implements NotificationPermissionGateway {
  @override
  Future<NotificationPermissionStatus> current() async {
    try {
      final status = await ph.Permission.notification.status;
      final mapped = _mapStatus(status);
      _log.info('Notification permission current: $mapped');
      return mapped;
    } catch (e, s) {
      _log.error('Notification permission current failed', e, s);
      return NotificationPermissionStatus.denied;
    }
  }

  @override
  Future<NotificationPermissionStatus> request() async {
    try {
      final status = await ph.Permission.notification.request();
      final mapped = _mapStatus(status);
      _log.info('Notification permission request: $mapped');
      return mapped;
    } catch (e, s) {
      _log.error('Notification permission request failed', e, s);
      return NotificationPermissionStatus.denied;
    }
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
