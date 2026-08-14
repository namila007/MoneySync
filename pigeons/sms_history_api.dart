import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/features/sms_ingestion/data/sms_history_pigeon.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/me/namila/money_sync/sms/SmsHistoryPigeon.g.kt',
    kotlinOptions: KotlinOptions(package: 'me.namila.money_sync.sms'),
    dartPackageName: 'money_sync',
  ),
)
class SmsHistoryRequest {
  SmsHistoryRequest({
    required this.fromEpochMs,
    required this.untilEpochMs,
    required this.limit,
    required this.offset,
    this.senderFilters,
  });
  int fromEpochMs;
  int untilEpochMs;
  int limit;
  int offset;
  List<String?>? senderFilters;
}

class SmsHistoryMessage {
  SmsHistoryMessage({
    required this.providerRowId,
    required this.address,
    required this.body,
    required this.dateEpochMs,
  });
  int providerRowId;
  String address;
  String body;
  int dateEpochMs;
}

class SmsHistoryPageResult {
  SmsHistoryPageResult({required this.messages, required this.hasMore});
  List<SmsHistoryMessage?> messages;
  bool hasMore;
}

@HostApi()
abstract class SmsHistoryHostApi {
  SmsHistoryPageResult queryInbox(SmsHistoryRequest request);
  int countInbox(SmsHistoryRequest request);
  List<String?> distinctSenders();
}
