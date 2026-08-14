import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/settings/data/drift_configuration_repository.dart';

void main() {
  group('Secure window configuration', () {
    test('defaults to enabled when no stored value exists', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final repo = DriftConfigurationRepository(database: db);

      final config = await repo.load();

      expect(config.secureWindowEnabled, isTrue);
    });

    test('persists disable and re-loads it', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final repo = DriftConfigurationRepository(database: db);

      await repo.updateSecureWindowEnabled(false);

      expect((await repo.load()).secureWindowEnabled, isFalse);
    });

    test('persists re-enable', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final repo = DriftConfigurationRepository(database: db);

      await repo.updateSecureWindowEnabled(false);
      await repo.updateSecureWindowEnabled(true);

      expect((await repo.load()).secureWindowEnabled, isTrue);
    });
  });
}
