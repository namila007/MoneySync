import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/sms_ingestion/data/share_intent_pigeon.g.dart';

class ShareIntentNotifier extends Notifier<SharedTextPayload?> {
  @override
  SharedTextPayload? build() => null;

  void handleSharedText(SharedTextPayload payload) {
    state = payload;
  }

  void clear() {
    state = null;
  }
}

final shareIntentProvider =
    NotifierProvider<ShareIntentNotifier, SharedTextPayload?>(
      ShareIntentNotifier.new,
    );
