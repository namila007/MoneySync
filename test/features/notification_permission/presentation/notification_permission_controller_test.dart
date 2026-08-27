import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_gateway.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/domain/request_notification_permission.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';

ProviderContainer makeContainer(NotificationPermissionGateway gateway) {
  final container = ProviderContainer(
    overrides: [
      notificationPermissionGatewayProvider.overrideWithValue(gateway),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('NotificationPermissionNotifier', () {
    test('first observation resolves to the gateway status', () async {
      final gateway = _MutableGateway(NotificationPermissionStatus.granted);
      final container = makeContainer(gateway);
      final notifier = container.read(
        notificationPermissionStatusProvider.notifier,
      );

      await notifier.refresh();
      expect(
        container.read(notificationPermissionStatusProvider),
        const AsyncValue.data(NotificationPermissionStatus.granted),
      );
    });

    test('notRequested then granted transitions correctly', () async {
      final gateway = _MutableGateway(
        NotificationPermissionStatus.notRequested,
      );
      final container = makeContainer(gateway);
      final notifier = container.read(
        notificationPermissionStatusProvider.notifier,
      );

      await notifier.refresh();
      expect(
        container.read(notificationPermissionStatusProvider),
        const AsyncValue.data(NotificationPermissionStatus.notRequested),
      );

      gateway.status = NotificationPermissionStatus.granted;
      await notifier.refresh();
      expect(
        container.read(notificationPermissionStatusProvider),
        const AsyncValue.data(NotificationPermissionStatus.granted),
      );
    });

    test('request when requestable reaches the gateway', () async {
      final gateway = _MutableGateway(
        NotificationPermissionStatus.notRequested,
      );
      final container = makeContainer(gateway);
      final notifier = container.read(
        notificationPermissionStatusProvider.notifier,
      );

      final outcome = await notifier.request();

      expect(gateway.requestCalled, isTrue);
      expect(outcome, isA<NotificationPermissionRequestCompleted>());
    });

    test('request when already granted does not call request', () async {
      final gateway = _MutableGateway(NotificationPermissionStatus.granted);
      final container = makeContainer(gateway);
      final notifier = container.read(
        notificationPermissionStatusProvider.notifier,
      );

      final outcome = await notifier.request();

      expect(gateway.requestCalled, isFalse);
      expect(outcome, isA<NotificationPermissionRequestCompleted>());
    });

    test('request when permanentlyDenied does not call request', () async {
      final gateway = _MutableGateway(
        NotificationPermissionStatus.permanentlyDenied,
      );
      final container = makeContainer(gateway);
      final notifier = container.read(
        notificationPermissionStatusProvider.notifier,
      );

      final outcome = await notifier.request();

      expect(gateway.requestCalled, isFalse);
      expect(outcome, isA<NotificationPermissionRequestCompleted>());
    });

    test(
      'a gateway that throws an Error resolves to error, not loading',
      () async {
        final container = makeContainer(_ThrowingGateway(StateError('boom')));
        final notifier = container.read(
          notificationPermissionStatusProvider.notifier,
        );

        await notifier.refresh();

        final state = container.read(notificationPermissionStatusProvider);
        expect(state.isLoading, isFalse);
        expect(state.hasError, isTrue);
      },
    );

    test('a missing gateway override resolves to error, not loading', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        notificationPermissionStatusProvider.notifier,
      );

      await notifier.refresh();

      final state = container.read(notificationPermissionStatusProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isTrue);
    });
  });

  group('RequestNotificationPermission', () {
    test('passes through granted without re-requesting', () async {
      final gateway = _MutableGateway(NotificationPermissionStatus.granted);
      final useCase = RequestNotificationPermission(gateway: gateway);

      final outcome = await useCase();
      expect(outcome, isA<NotificationPermissionRequestCompleted>());
      final completed = outcome as NotificationPermissionRequestCompleted;
      expect(completed.status, NotificationPermissionStatus.granted);
      expect(gateway.requestCalled, isFalse);
    });

    test('passes permanentlyDenied without re-requesting', () async {
      final gateway = _MutableGateway(
        NotificationPermissionStatus.permanentlyDenied,
      );
      final useCase = RequestNotificationPermission(gateway: gateway);

      final outcome = await useCase();
      expect(outcome, isA<NotificationPermissionRequestCompleted>());
      final completed = outcome as NotificationPermissionRequestCompleted;
      expect(completed.status, NotificationPermissionStatus.permanentlyDenied);
      expect(gateway.requestCalled, isFalse);
    });

    test('requests when status is denied', () async {
      final gateway = _MutableGateway(NotificationPermissionStatus.denied);
      final useCase = RequestNotificationPermission(gateway: gateway);

      await useCase();
      expect(gateway.requestCalled, isTrue);
    });

    test('requests when status is notRequested', () async {
      final gateway = _MutableGateway(
        NotificationPermissionStatus.notRequested,
      );
      final useCase = RequestNotificationPermission(gateway: gateway);

      await useCase();
      expect(gateway.requestCalled, isTrue);
    });
  });
}

final class _ThrowingGateway implements NotificationPermissionGateway {
  _ThrowingGateway(this.failure);

  final Object failure;

  @override
  Future<NotificationPermissionStatus> current() async => throw failure;

  @override
  Future<NotificationPermissionStatus> request() async => throw failure;

  @override
  Future<void> openAppSettings() async => throw failure;
}

final class _MutableGateway implements NotificationPermissionGateway {
  _MutableGateway(this.status);
  NotificationPermissionStatus status;
  bool requestCalled = false;

  @override
  Future<NotificationPermissionStatus> current() async => status;

  @override
  Future<NotificationPermissionStatus> request() async {
    requestCalled = true;
    return NotificationPermissionStatus.granted;
  }

  @override
  Future<void> openAppSettings() async {}
}
