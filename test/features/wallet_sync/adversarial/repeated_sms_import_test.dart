import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';

/// G4.2 — Repeated import of the same SMS must produce zero new mutations.
///
/// The `source_key` column on `sms_events` is UNIQUE (M4.14 WP4).
/// `insertSmsEventIfAbsent` uses `InsertMode.insertOrIgnore`, so a second
/// insert with an identical source_key silently returns the existing row's
/// id with `inserted: false`. This prevents duplicate transaction candidates,
/// which would otherwise each generate a Wallet mutation and risk creating
/// duplicate financial records.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.inMemoryForTesting();
    // beforeOpen inserts app_settings with privacy_epoch=0; update to 1.
    await db.customStatement(
      'UPDATE app_settings SET privacy_epoch = 1 WHERE singleton_id = 1',
    );
  });
  tearDown(() => db.close());

  Future<int> insertSms({
    required String sourceKey,
    String senderKey = 'SENDER-BANK',
    String body = 'LKR 4,425.00 debited from your account',
    int receivedAt = 1700000000000,
  }) async {
    final result = await db.insertSmsEventIfAbsent(
      sourceKey: sourceKey,
      senderKey: senderKey,
      encryptedBody: body,
      ingestionSource: 'test',
      receivedAtEpochMs: receivedAt,
      status: SmsEventStatus.captured,
      privacyEpoch: 1,
      captureCanonicalizationVersion: 2,
    );
    return result.id;
  }

  test('importing the same source_key twice returns the same event id '
      'and inserts only one row', () async {
    const sourceKey = 'v2_SMS-BANK_1700000000000_SOMEHASH';

    final id1 = await insertSms(sourceKey: sourceKey);
    final id2 = await insertSms(sourceKey: sourceKey);

    // Both calls return the same id — the second is a no-op dedup.
    expect(
      id1,
      equals(id2),
      reason: 'source_key dedup must return the existing row id',
    );

    // Only one row exists in the table.
    final rows = await (db.select(
      db.smsEvents,
    )..where((t) => t.sourceKey.equals(sourceKey))).get();
    expect(
      rows.length,
      1,
      reason: 'insertOrIgnore on a UNIQUE column must not create a duplicate',
    );
  });

  test('different source_keys produce different event ids', () async {
    final id1 = await insertSms(sourceKey: 'v2_SMS-BANK_1000_HASH_A');
    final id2 = await insertSms(sourceKey: 'v2_SMS-BANK_2000_HASH_B');

    expect(
      id1,
      isNot(equals(id2)),
      reason: 'different source messages must be distinct events',
    );
  });

  test(
    'duplicate import returns inserted:false and does not create a new row',
    () async {
      const sourceKey = 'v2_SMS-BANK_1700000000000_DEDUP';

      final first = await db.insertSmsEventIfAbsent(
        sourceKey: sourceKey,
        senderKey: 'BANK',
        encryptedBody: 'LKR 100.00 debited',
        ingestionSource: 'test',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 1,
        captureCanonicalizationVersion: 2,
      );
      expect(first.inserted, isTrue, reason: 'first import must succeed');

      final second = await db.insertSmsEventIfAbsent(
        sourceKey: sourceKey,
        senderKey: 'BANK',
        encryptedBody: 'LKR 100.00 debited',
        ingestionSource: 'test',
        receivedAtEpochMs: 1700000000000,
        status: SmsEventStatus.captured,
        privacyEpoch: 1,
        captureCanonicalizationVersion: 2,
      );
      expect(
        second.inserted,
        isFalse,
        reason: 'second import with same source_key must be a no-op dedup',
      );
      expect(
        second.id,
        equals(first.id),
        reason: 'the returned id must point to the existing row',
      );
    },
  );
}
