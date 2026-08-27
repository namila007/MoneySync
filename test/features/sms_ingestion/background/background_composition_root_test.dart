import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/notifications/data/fake_notification_service.dart';
import 'package:money_sync/features/sms_ingestion/background/background_composition_root.dart';
import 'package:money_sync/features/sms_ingestion/domain/scan_tracked_senders.dart';

void main() {
  group('BackgroundCompositionRoot', () {
    test('constructs with default parameters', () {
      final root = BackgroundCompositionRoot();
      expect(root, isNotNull);
    });

    test(
      'buildFromDatabase wires ScanTrackedSenders from in-memory DB',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        try {
          final root = BackgroundCompositionRoot(
            notificationService: FakeNotificationService(),
          );
          final scan = await root.buildFromDatabase(db);
          expect(scan, isA<ScanTrackedSenders>());
        } finally {
          await db.close();
        }
      },
    );
  });
}
