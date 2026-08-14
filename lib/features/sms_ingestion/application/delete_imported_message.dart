import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';

sealed class DeleteMessageResult {
  const DeleteMessageResult();
}

final class DeleteMessageDeleted extends DeleteMessageResult {
  const DeleteMessageDeleted();
}

final class DeleteMessageNotFound extends DeleteMessageResult {
  const DeleteMessageNotFound();
}

final class DeleteMessageBlockedByEpoch extends DeleteMessageResult {
  const DeleteMessageBlockedByEpoch();
}

/// Deletes one imported message's app copy (event + candidate + traces) and
/// records it in the activity log. The Android SMS provider is never touched.
final class DeleteImportedMessage {
  DeleteImportedMessage({required this.database});

  final AppDatabase database;
  final _log = Logger('sms.delete');

  Future<DeleteMessageResult> call({
    required int eventId,
    required int privacyEpoch,
  }) async {
    try {
      final deleted = await database.deleteSmsEvent(
        eventId: eventId,
        privacyEpoch: privacyEpoch,
      );
      if (!deleted) return const DeleteMessageNotFound();
      await database.insertActivity(
        activityType: ActivityEventCode.smsEventDeleted,
        safeDetailCode: ActivityStateTransition.logEvent,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: privacyEpoch,
      );
      _log.info('Imported message deleted: event=$eventId');
      return const DeleteMessageDeleted();
    } on StalePrivacyEpochException {
      return const DeleteMessageBlockedByEpoch();
    }
  }
}
