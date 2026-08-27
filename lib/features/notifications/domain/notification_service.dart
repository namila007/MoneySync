import 'notification_request.dart';

abstract interface class NotificationService {
  Future<void> show(NotificationRequest request);
  Future<void> cancel(NotificationId id);
}
