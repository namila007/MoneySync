import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_ingestion/presentation/manual_import_controller.dart';

void main() {
  group('ManualImportController rate limiter', () {
    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            final db = AppDatabase.inMemoryForTesting();
            ref.onDispose(db.close);
            return db;
          }),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('allows 20 ingests within the window', () async {
      final container = createContainer();
      await container.read(appDatabaseProvider.future);
      final notifier = container.read(manualImportProvider.notifier);

      notifier.updateBody('valid message body over twelve characters long');

      for (var i = 0; i < 20; i++) {
        await notifier.confirm();
      }

      expect(notifier.state.resultType, ImportResultType.filtered);
      expect(notifier.state.resultMessage, isNot(contains('Too many imports')));
    });

    test('rejects the 21st ingest within the window', () async {
      final container = createContainer();
      await container.read(appDatabaseProvider.future);
      final notifier = container.read(manualImportProvider.notifier);

      notifier.updateBody('valid message body over twelve characters long');

      for (var i = 0; i < 20; i++) {
        await notifier.confirm();
      }
      await notifier.confirm();

      expect(notifier.state.resultType, ImportResultType.rejected);
      expect(notifier.state.resultMessage, contains('Too many imports'));
    });
  });
}
