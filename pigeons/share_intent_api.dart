import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/features/sms_ingestion/data/share_intent_pigeon.g.dart',
  kotlinOut:
      'android/app/src/main/kotlin/me/namila/money_sync/share/ShareIntentPigeon.g.kt',
  kotlinOptions: KotlinOptions(package: 'me.namila.money_sync.share'),
  dartPackageName: 'money_sync',
))
class SharedTextPayload {
  SharedTextPayload({required this.text, this.mimeType, this.sourcePackage});
  String text;
  String? mimeType;
  String? sourcePackage;
}

@FlutterApi()
abstract class ShareIntentFlutterApi {
  void onSharedText(SharedTextPayload payload);
}
