import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('trackingStateOrDefault()', () {
    test('returns v16 defaults on a fresh in-memory database', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      final state = await db.trackingStateOrDefault();

      expect(state.id, 1);
      expect(state.lastScanAtEpochMs, isNull);
      expect(state.lastScanOutcome, isNull);
      expect(state.lastSafeErrorCode, isNull);
      expect(state.privacyEpoch, 0);
    });

    test('returns persisted row after update', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db.updateTrackingState(
        lastScanAtEpochMs: const Value(1000),
        lastScanOutcome: const Value('ok'),
      );

      final state = await db.trackingStateOrDefault();

      expect(state.lastScanAtEpochMs, 1000);
      expect(state.lastScanOutcome, 'ok');
      expect(state.lastSafeErrorCode, isNull);
    });
  });

  group('updateTrackingState()', () {
    test('partial update only touches provided fields', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db.updateTrackingState(
        lastScanAtEpochMs: const Value(1000),
        lastScanOutcome: const Value('ok'),
        privacyEpoch: const Value(5),
      );

      // Update only lastScanOutcome, other fields preserved.
      await db.updateTrackingState(lastScanOutcome: const Value('failed'));

      final state = await db.trackingStateOrDefault();

      expect(state.lastScanAtEpochMs, 1000);
      expect(state.lastScanOutcome, 'failed');
      expect(state.privacyEpoch, 5);
    });

    test('clears nullable fields when null is passed', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);

      await db.updateTrackingState(
        lastScanAtEpochMs: const Value(1000),
        lastSafeErrorCode: const Value('SOME_ERROR'),
      );

      await db.updateTrackingState(
        lastScanAtEpochMs: const Value(null),
        lastSafeErrorCode: const Value(null),
      );

      final state = await db.trackingStateOrDefault();

      expect(state.lastScanAtEpochMs, isNull);
      expect(state.lastSafeErrorCode, isNull);
    });
  });
}
