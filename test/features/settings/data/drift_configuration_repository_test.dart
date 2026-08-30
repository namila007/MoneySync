import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/settings/data/drift_configuration_repository.dart';

void main() {
  late AppDatabase db;
  late DriftConfigurationRepository repo;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    repo = DriftConfigurationRepository(database: db);
  });

  tearDown(() => db.close());

  group('updateAutoImportIntervalMinutes', () {
    test('persists the interval', () async {
      await repo.updateAutoImportIntervalMinutes(30);

      final state = await repo.load();
      expect(state.autoImportIntervalMinutes, 30);
    });

    test('clamps values below 15 to 15', () async {
      await repo.updateAutoImportIntervalMinutes(10);

      final state = await repo.load();
      expect(state.autoImportIntervalMinutes, 15);
    });

    test('accepts 60 minutes', () async {
      await repo.updateAutoImportIntervalMinutes(60);

      final state = await repo.load();
      expect(state.autoImportIntervalMinutes, 60);
    });

    test('increments configuration revision', () async {
      final before = await repo.load();
      await repo.updateAutoImportIntervalMinutes(30);
      final after = await repo.load();

      expect(after.configurationRevision, before.configurationRevision + 1);
    });
  });
}
