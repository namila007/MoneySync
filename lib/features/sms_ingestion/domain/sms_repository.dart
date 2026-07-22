import 'source_identity.dart';

/// Read-only capture queries exposed by the SMS-provider boundary.
final class SmsCaptureQuery {
  const SmsCaptureQuery({this.sourceMessageKey});

  final SourceMessageKey? sourceMessageKey;
}

/// A capture returned from app-owned storage or the source-provider boundary.
final class SmsCapture {
  const SmsCapture({required this.message, required this.identity});

  final SmsSourceMessage message;
  final SourceMessageIdentity identity;
}

final class SmsCaptureQueryResult {
  SmsCaptureQueryResult(Iterable<SmsCapture> captures)
    : captures = List<SmsCapture>.unmodifiable(captures);

  final List<SmsCapture> captures;
}

/// Bounded historical source query. A later Android adapter owns paging.
final class SmsHistoryQuery {
  SmsHistoryQuery({
    required this.fromUtc,
    required this.untilUtc,
    required this.maximum,
  }) {
    if (!fromUtc.isUtc || !untilUtc.isUtc) {
      throw ArgumentError('history bounds must be UTC');
    }
    if (untilUtc.isBefore(fromUtc)) {
      throw ArgumentError('history end must not precede start');
    }
    if (maximum <= 0) {
      throw ArgumentError.value(maximum, 'maximum', 'must be positive');
    }
  }

  final DateTime fromUtc;
  final DateTime untilUtc;
  final int maximum;
}

final class SmsHistoryPage {
  SmsHistoryPage({
    required Iterable<SmsSourceMessage> messages,
    required this.hasMore,
  }) : messages = List<SmsSourceMessage>.unmodifiable(messages);

  final List<SmsSourceMessage> messages;
  final bool hasMore;
}

/// The sole domain port for Android SMS-provider interaction.
///
/// Its shape intentionally contains only read operations. Platform adapters
/// must never alter an Android provider row.
abstract interface class SmsRepository {
  Future<SmsCaptureQueryResult> queryCaptures(SmsCaptureQuery query);

  Future<SmsHistoryPage> queryHistory(SmsHistoryQuery query);
}
