import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_permission/data/pigeon_sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/data/sms_permission_pigeon.g.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';

void main() {
  group('PigeonSmsPermissionGateway', () {
    test(
      'maps every TransportSmsPermissionStatus to exactly one domain status',
      () {
        final gateway = PigeonSmsPermissionGateway();

        for (final transportValue in TransportSmsPermissionStatus.values) {
          final domainValue = gateway.mapTransport(transportValue);
          expect(
            domainValue,
            isA<SmsPermissionStatus>(),
            reason:
                'Transport value $transportValue must map to a domain status',
          );
        }
      },
    );

    test(
      'TransportSmsPermissionStatus.unavailableInBuild maps to unavailableInBuild',
      () {
        final gateway = PigeonSmsPermissionGateway();
        final result = gateway.mapTransport(
          TransportSmsPermissionStatus.unavailableInBuild,
        );
        expect(result, SmsPermissionStatus.unavailableInBuild);
      },
    );

    test('TransportSmsPermissionStatus.notRequested maps to notRequested', () {
      final gateway = PigeonSmsPermissionGateway();
      final result = gateway.mapTransport(
        TransportSmsPermissionStatus.notRequested,
      );
      expect(result, SmsPermissionStatus.notRequested);
    });

    test('TransportSmsPermissionStatus.granted maps to granted', () {
      final gateway = PigeonSmsPermissionGateway();
      final result = gateway.mapTransport(TransportSmsPermissionStatus.granted);
      expect(result, SmsPermissionStatus.granted);
    });

    test('TransportSmsPermissionStatus.denied maps to denied', () {
      final gateway = PigeonSmsPermissionGateway();
      final result = gateway.mapTransport(TransportSmsPermissionStatus.denied);
      expect(result, SmsPermissionStatus.denied);
    });

    test(
      'TransportSmsPermissionStatus.permanentlyDenied maps to permanentlyDenied',
      () {
        final gateway = PigeonSmsPermissionGateway();
        final result = gateway.mapTransport(
          TransportSmsPermissionStatus.permanentlyDenied,
        );
        expect(result, SmsPermissionStatus.permanentlyDenied);
      },
    );

    test('TransportSmsPermissionStatus.revoked maps to revoked', () {
      final gateway = PigeonSmsPermissionGateway();
      final result = gateway.mapTransport(TransportSmsPermissionStatus.revoked);
      expect(result, SmsPermissionStatus.revoked);
    });

    test('no transport value is silently unmapped', () {
      expect(
        TransportSmsPermissionStatus.values.length,
        SmsPermissionStatus.values.length,
        reason:
            'Both enums must have the same number of values to prevent '
            'unmapped transport states',
      );
    });
  });
}
