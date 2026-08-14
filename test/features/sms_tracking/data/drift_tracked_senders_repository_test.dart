import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_tracking/data/drift_tracked_senders_repository.dart';

void main() {
  group('DriftTrackedSendersRepository', () {
    test('missing row loads as empty list', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final repo = DriftTrackedSendersRepository(database: db);

      expect(await repo.load(), isEmpty);
    });

    test('round-trips saved addresses', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final repo = DriftTrackedSendersRepository(database: db);

      await repo.save(['SAMPATHTX', 'NATIONS_SMS']);
      final loaded = await repo.load();

      expect([for (final s in loaded) s.address], ['SAMPATHTX', 'NATIONS_SMS']);
    });

    test('overwrites previous value', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final repo = DriftTrackedSendersRepository(database: db);

      await repo.save(['A', 'B']);
      await repo.save(['C']);
      final loaded = await repo.load();

      expect([for (final s in loaded) s.address], ['C']);
    });

    test('stored over-long addresses are skipped', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      await db
          .into(db.trackedSenders)
          .insert(
            TrackedSendersCompanion.insert(senderKey: 'OK', addedAtEpochMs: 1),
          );
      await db
          .into(db.trackedSenders)
          .insert(
            TrackedSendersCompanion.insert(
              senderKey: 'X' * 33,
              addedAtEpochMs: 1,
            ),
          );
      final repo = DriftTrackedSendersRepository(database: db);

      final loaded = await repo.load();
      expect([for (final s in loaded) s.address], ['OK']);
    });
  });
}
