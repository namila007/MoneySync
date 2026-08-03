import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/logging/native_log_pigeon.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/me/namila/money_sync/NativeLogPigeon.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'me.namila.money_sync',
      errorClassName: 'NativeLogFlutterError',
    ),
  ),
)
@FlutterApi()
abstract class NativeLogFlutterApi {
  void onNativeLog(
    int priority,
    String tag,
    String message,
    String? safeErrorCode,
  );
}
