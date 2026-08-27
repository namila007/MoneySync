import '../domain/notification_request.dart';
import '../domain/notification_service.dart';

class FakeNotificationService implements NotificationService {
  final List<NotificationRequest> shown = [];
  final Set<NotificationId> cancelled = {};

  @override
  Future<void> show(NotificationRequest request) async {
    shown.add(request);
  }

  @override
  Future<void> cancel(NotificationId id) async {
    cancelled.add(id);
  }
}
