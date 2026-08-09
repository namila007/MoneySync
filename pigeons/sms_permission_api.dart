import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/features/sms_permission/data/sms_permission_pigeon.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/me/namila/money_sync/sms/SmsPermissionPigeon.g.kt',
    kotlinOptions: KotlinOptions(package: 'me.namila.money_sync.sms'),
    dartPackageName: 'money_sync',
  ),
)
enum TransportSmsPermissionStatus {
  unavailableInBuild,
  notRequested,
  granted,
  denied,
  permanentlyDenied,
  revoked,
}

@HostApi()
abstract class SmsPermissionHostApi {
  TransportSmsPermissionStatus currentStatus();

  @async
  TransportSmsPermissionStatus requestReadSms();

  void openAppSettings();
}
