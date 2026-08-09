import 'sms_permission_gateway.dart';
import 'sms_permission_status.dart';

final class ObserveSmsPermission {
  const ObserveSmsPermission(this._gateway);
  final SmsPermissionGateway _gateway;

  Future<SmsPermissionStatus> call() => _gateway.current();
}
