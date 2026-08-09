import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_permission/domain/request_sms_permission.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

ProviderContainer makeContainer(SmsPermissionGateway gateway) {
  final container = ProviderContainer(
    overrides: [smsPermissionGatewayProvider.overrideWithValue(gateway)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('SmsPermissionNotifier', () {
    test('granted then notRequested across a resume reports revoked', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.granted);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.granted),
      );

      gateway.status = SmsPermissionStatus.notRequested;
      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.revoked),
      );
    });

    test('notRequested then granted does not report revoked', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.notRequested);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.notRequested),
      );

      gateway.status = SmsPermissionStatus.granted;
      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.granted),
      );
    });

    test('first observation never reports revoked', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.denied);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.denied),
      );
    });

    test('granted then denied across a resume reports revoked', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.granted);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      gateway.status = SmsPermissionStatus.denied;
      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.revoked),
      );
    });

    test('granted then permanentlyDenied reports revoked', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.granted);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      gateway.status = SmsPermissionStatus.permanentlyDenied;
      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.revoked),
      );
    });

    test('multiple transitions: granted -> denied(reports revoked) -> '
        'notRequested(stays revoked)', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.granted);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      gateway.status = SmsPermissionStatus.denied;
      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.revoked),
      );

      gateway.status = SmsPermissionStatus.notRequested;
      await notifier.refresh();
      expect(
        container.read(smsPermissionStatusProvider),
        const AsyncValue.data(SmsPermissionStatus.notRequested),
        reason:
            'After revoked is reported, the next real status is used directly',
      );
    });

    test('request with null disclosure revision refuses', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.notRequested);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();
      await notifier.request(acceptedDisclosureRevision: null);
      expect(gateway.requestCalled, isFalse);
    });

    test(
      'request with the accepted disclosure revision reaches the gateway',
      () async {
        final gateway = _MutableGateway(SmsPermissionStatus.notRequested);
        final container = makeContainer(gateway);
        final notifier = container.read(smsPermissionStatusProvider.notifier);

        final outcome = await notifier.request(acceptedDisclosureRevision: 1);

        expect(gateway.requestCalled, isTrue);
        expect(outcome, isA<SmsPermissionRequestCompleted>());
      },
    );

    test('playManual never reaches the gateway request path', () async {
      final gateway = _MutableGateway(SmsPermissionStatus.unavailableInBuild);
      final container = makeContainer(gateway);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      final outcome = await notifier.request(acceptedDisclosureRevision: 1);

      expect(
        gateway.requestCalled,
        isFalse,
        reason: 'playManual must never ask for an SMS permission',
      );
      expect(outcome, isA<SmsPermissionRequestUnavailable>());
    });

    test(
      'a gateway that throws an Error resolves to error, not loading',
      () async {
        final container = makeContainer(_ThrowingGateway(StateError('boom')));
        final notifier = container.read(smsPermissionStatusProvider.notifier);

        await notifier.refresh();

        final state = container.read(smsPermissionStatusProvider);
        expect(
          state.isLoading,
          isFalse,
          reason:
              'A stuck AsyncValue.loading() renders an unfalsifiable spinner',
        );
        expect(state.hasError, isTrue);
      },
    );

    test('a missing gateway override resolves to error, not loading', () async {
      // No override at all: smsPermissionGatewayProvider throws StateError.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(smsPermissionStatusProvider.notifier);

      await notifier.refresh();

      final state = container.read(smsPermissionStatusProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isTrue);
    });
  });
}

final class _ThrowingGateway implements SmsPermissionGateway {
  _ThrowingGateway(this.failure);

  final Object failure;

  @override
  Future<SmsPermissionStatus> current() async => throw failure;

  @override
  Future<SmsPermissionStatus> request() async => throw failure;

  @override
  Future<void> openAppSettings() async => throw failure;
}

final class _MutableGateway implements SmsPermissionGateway {
  _MutableGateway(this.status);
  SmsPermissionStatus status;
  bool requestCalled = false;

  @override
  Future<SmsPermissionStatus> current() async => status;

  @override
  Future<SmsPermissionStatus> request() async {
    requestCalled = true;
    return SmsPermissionStatus.granted;
  }

  @override
  Future<void> openAppSettings() async {}
}
