import 'sms_permission_status.dart';

abstract interface class SmsPermissionGateway {
  Future<SmsPermissionStatus> current();
  Future<SmsPermissionStatus> request();
  Future<void> openAppSettings();
}
