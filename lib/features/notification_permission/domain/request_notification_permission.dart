import 'notification_permission_gateway.dart';
import 'notification_permission_status.dart';

sealed class NotificationPermissionRequestOutcome {
  const NotificationPermissionRequestOutcome();
}

final class NotificationPermissionRequestCompleted
    extends NotificationPermissionRequestOutcome {
  const NotificationPermissionRequestCompleted(this.status);
  final NotificationPermissionStatus status;
}

final class RequestNotificationPermission {
  const RequestNotificationPermission({required this.gateway});

  final NotificationPermissionGateway gateway;

  Future<NotificationPermissionRequestOutcome> call() async {
    final status = await gateway.current();
    if (!status.isRequestable) {
      return NotificationPermissionRequestCompleted(status);
    }
    return NotificationPermissionRequestCompleted(await gateway.request());
  }
}
