import 'package:money_sync/features/sms_ingestion/data/share_intent_pigeon.g.dart';

/// Receives share-intent payloads from the Kotlin layer and forwards them
/// to the Dart-side ingest pipeline via a callback.
final class ManualShareGateway extends ShareIntentFlutterApi {
  ManualShareGateway({required this.onSharedTextReceived});

  final void Function(SharedTextPayload payload) onSharedTextReceived;

  @override
  void onSharedText(SharedTextPayload payload) {
    onSharedTextReceived(payload);
  }
}
