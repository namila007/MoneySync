import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';

import 'sms_permission_pigeon.g.dart';

final class PigeonSmsPermissionGateway implements SmsPermissionGateway {
  PigeonSmsPermissionGateway({SmsPermissionHostApi? api})
    : _api = api ?? SmsPermissionHostApi();

  final SmsPermissionHostApi _api;

  @override
  Future<SmsPermissionStatus> current() async =>
      mapTransport(await _api.currentStatus());

  @override
  Future<SmsPermissionStatus> request() async =>
      mapTransport(await _api.requestReadSms());

  @override
  Future<void> openAppSettings() => _api.openAppSettings();

  SmsPermissionStatus mapTransport(TransportSmsPermissionStatus s) =>
      switch (s) {
        TransportSmsPermissionStatus.unavailableInBuild =>
          SmsPermissionStatus.unavailableInBuild,
        TransportSmsPermissionStatus.notRequested =>
          SmsPermissionStatus.notRequested,
        TransportSmsPermissionStatus.granted => SmsPermissionStatus.granted,
        TransportSmsPermissionStatus.denied => SmsPermissionStatus.denied,
        TransportSmsPermissionStatus.permanentlyDenied =>
          SmsPermissionStatus.permanentlyDenied,
        TransportSmsPermissionStatus.revoked => SmsPermissionStatus.revoked,
      };
}
