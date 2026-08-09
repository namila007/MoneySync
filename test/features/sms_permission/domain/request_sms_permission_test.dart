import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_permission/domain/request_sms_permission.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';

void main() {
  group('RequestSmsPermission', () {
    test('refuses when acceptedDisclosureRevision is null', () async {
      final gateway = _StubGateway(SmsPermissionStatus.notRequested);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 1,
      );

      final outcome = await useCase(acceptedDisclosureRevision: null);
      expect(outcome, isA<SmsPermissionRequestRefusedWithoutDisclosure>());
      expect(gateway.requestCalled, isFalse);
    });

    test('refuses when accepted revision is older than required', () async {
      final gateway = _SpyGateway(SmsPermissionStatus.notRequested);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 3,
      );

      final outcome = await useCase(acceptedDisclosureRevision: 2);
      expect(outcome, isA<SmsPermissionRequestRefusedWithoutDisclosure>());
      expect(gateway.requestCalled, isFalse);
    });

    test('never calls gateway.request when disclosure is missing', () async {
      final gateway = _SpyGateway(SmsPermissionStatus.notRequested);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 1,
      );

      await useCase(acceptedDisclosureRevision: null);
      expect(gateway.requestCalled, isFalse);
    });

    test('returns Unavailable in playManual without calling request', () async {
      final gateway = _SpyGateway(SmsPermissionStatus.unavailableInBuild);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 1,
      );

      final outcome = await useCase(acceptedDisclosureRevision: 1);
      expect(outcome, isA<SmsPermissionRequestUnavailable>());
      expect(gateway.requestCalled, isFalse);
    });

    test('passes through granted without re-requesting', () async {
      final gateway = _SpyGateway(SmsPermissionStatus.granted);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 1,
      );

      final outcome = await useCase(acceptedDisclosureRevision: 1);
      expect(outcome, isA<SmsPermissionRequestCompleted>());
      final completed = outcome as SmsPermissionRequestCompleted;
      expect(completed.status, SmsPermissionStatus.granted);
      expect(gateway.requestCalled, isFalse);
    });

    test('requests when disclosure accepted and status is denied', () async {
      final gateway = _SpyGateway(SmsPermissionStatus.denied);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 1,
      );

      final outcome = await useCase(acceptedDisclosureRevision: 1);
      expect(outcome, isA<SmsPermissionRequestCompleted>());
      expect(gateway.requestCalled, isTrue);
    });

    test(
      'requests when disclosure accepted and status is notRequested',
      () async {
        final gateway = _SpyGateway(SmsPermissionStatus.notRequested);
        final useCase = RequestSmsPermission(
          gateway: gateway,
          disclosureRevisionRequired: 1,
        );

        await useCase(acceptedDisclosureRevision: 1);
        expect(gateway.requestCalled, isTrue);
      },
    );

    test('passes permanentlyDenied without re-requesting', () async {
      final gateway = _SpyGateway(SmsPermissionStatus.permanentlyDenied);
      final useCase = RequestSmsPermission(
        gateway: gateway,
        disclosureRevisionRequired: 1,
      );

      final outcome = await useCase(acceptedDisclosureRevision: 1);
      expect(outcome, isA<SmsPermissionRequestCompleted>());
      final completed = outcome as SmsPermissionRequestCompleted;
      expect(completed.status, SmsPermissionStatus.permanentlyDenied);
      expect(gateway.requestCalled, isFalse);
    });
  });
}

final class _SpyGateway implements SmsPermissionGateway {
  _SpyGateway(this._status);
  final SmsPermissionStatus _status;
  bool requestCalled = false;

  @override
  Future<SmsPermissionStatus> current() async => _status;

  @override
  Future<SmsPermissionStatus> request() async {
    requestCalled = true;
    return SmsPermissionStatus.granted;
  }

  @override
  Future<void> openAppSettings() async {}
}

final class _StubGateway implements SmsPermissionGateway {
  _StubGateway(this._status);
  final SmsPermissionStatus _status;
  bool requestCalled = false;

  @override
  Future<SmsPermissionStatus> current() async => _status;

  @override
  Future<SmsPermissionStatus> request() async {
    requestCalled = true;
    return SmsPermissionStatus.granted;
  }

  @override
  Future<void> openAppSettings() async {}
}
