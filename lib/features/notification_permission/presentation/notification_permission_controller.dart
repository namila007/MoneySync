import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_gateway.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/domain/request_notification_permission.dart';

final notificationPermissionGatewayProvider =
    Provider<NotificationPermissionGateway>((ref) {
  throw StateError('notificationPermissionGatewayProvider must be overridden.');
});

final notificationPermissionStatusProvider = NotifierProvider<
  NotificationPermissionNotifier,
  AsyncValue<NotificationPermissionStatus>
>(NotificationPermissionNotifier.new);

class NotificationPermissionNotifier
    extends Notifier<AsyncValue<NotificationPermissionStatus>> {
  @override
  AsyncValue<NotificationPermissionStatus> build() {
    unawaited(refresh());
    return const AsyncValue.loading();
  }

  Future<void> refresh() async {
    try {
      final gateway = ref.read(notificationPermissionGatewayProvider);
      final status = await gateway.current();
      state = AsyncValue.data(status);
    } on Object catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<NotificationPermissionRequestOutcome> request() async {
    final gateway = ref.read(notificationPermissionGatewayProvider);
    final status = await gateway.current();
    if (!status.isRequestable) {
      final result = NotificationPermissionRequestCompleted(status);
      await refresh();
      return result;
    }
    final requested = await gateway.request();
    await refresh();
    return NotificationPermissionRequestCompleted(requested);
  }

  Future<void> openSystemSettings() async {
    final gateway = ref.read(notificationPermissionGatewayProvider);
    await gateway.openAppSettings();
  }
}
