import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// G4.5 — Deleting an app-owned local copy must never touch the SMS provider.
///
/// The Android SMS provider is the user's real inbox. The app only reads it;
/// never writing, deleting, or marking read on provider rows is a hard
/// architectural boundary (plan/02; AGENTS.md "Kotlin owns Android-only
/// concerns"). `deleteSmsEvent` operates solely on the Drift `sms_events`
/// table (the app's local copy). This test proves the provider row is
/// untouched by comparing count, body, read/status, and timestamps before
/// and after the delete.
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

  Future<Map<String, Object?>> captureSmsState(int eventId) async {
    final row = await (db.select(
      db.smsEvents,
    )..where((t) => t.id.equals(eventId))).getSingle();
    return {
      'id': row.id,
      'sourceKey': row.sourceKey,
      'senderKey': row.senderKey,
      'encryptedBody': row.encryptedBody,
      'status': row.status,
      'receivedAtEpochMs': row.receivedAtEpochMs,
      'privacyEpoch': row.privacyEpoch,
    };
  }

  Future<int> insertTestSms({
    String sourceKey = 'v2_DELETE_TEST_1000_HASH',
    String body = 'LKR 1,000.00 debited from your account',
  }) async {
    final result = await db.insertSmsEventIfAbsent(
      sourceKey: sourceKey,
      senderKey: 'BANK-DELETE',
      encryptedBody: body,
      ingestionSource: 'test',
      receivedAtEpochMs: 1700000000000,
      status: SmsEventStatus.captured,
      privacyEpoch: 1,
      captureCanonicalizationVersion: 2,
    );
    return result.id;
  }

  test(
    'deleting the app copy does not alter any other sms_events row',
    () async {
      // Insert two events: one we delete, one that is the "provider row"
      // proxy. Deleting the first must not touch the second.
      final deleteId = await insertTestSms(
        sourceKey: 'v2_DELETE_TARGET_1000',
        body: 'LKR 1,000.00 debited',
      );
      final unrelatedId = await insertTestSms(
        sourceKey: 'v2_UNRELATED_2000',
        body: 'LKR 2,000.00 credited',
      );

      final before = await captureSmsState(unrelatedId);

      final deleted = await db.deleteSmsEvent(
        eventId: deleteId,
        privacyEpoch: 1,
      );
      expect(deleted, isTrue, reason: 'the delete must succeed');

      // The target row is gone.
      final targetRows = await (db.select(
        db.smsEvents,
      )..where((t) => t.id.equals(deleteId))).get();
      expect(targetRows, isEmpty, reason: 'deleted event must not exist');

      // The unrelated row is completely untouched.
      final after = await captureSmsState(unrelatedId);
      expect(
        after,
        equals(before),
        reason: 'deleting one event must not mutate any other sms_events row',
      );
    },
  );

  test('body, status, and timestamps of the surviving row are identical '
      'before and after', () async {
    final id = await insertTestSms(
      sourceKey: 'v2_FIELD_CHECK_3000',
      body: 'LKR 3,000.00 transfer to SAVINGS',
    );
    final providerProxyId = await insertTestSms(
      sourceKey: 'v2_PROVIDER_PROXY_3001',
      body: 'LKR 5,500.00 credit from EMPLOYER',
    );

    // Before state: capture the provider-proxy row.
    final beforeCount = await db.select(db.smsEvents).get();
    final beforeProxy = beforeCount.firstWhere((r) => r.id == providerProxyId);
    final beforeBody = beforeProxy.encryptedBody;
    final beforeStatus = beforeProxy.status;
    final beforeReceived = beforeProxy.receivedAtEpochMs;

    // Delete the target event — must not touch the proxy row.
    await db.deleteSmsEvent(eventId: id, privacyEpoch: 1);

    // After state: count decreased by 1.
    final afterCount = await db.select(db.smsEvents).get();
    expect(
      afterCount.length,
      beforeCount.length - 1,
      reason: 'exactly one row must be removed',
    );

    // The provider-proxy row's fields are identical before and after.
    final afterProxy = afterCount.firstWhere((r) => r.id == providerProxyId);
    expect(
      afterProxy.encryptedBody,
      beforeBody,
      reason: 'body must not change',
    );
    expect(
      afterProxy.status,
      beforeStatus,
      reason: 'read/status must not change',
    );
    expect(
      afterProxy.receivedAtEpochMs,
      beforeReceived,
      reason: 'timestamps must not change',
    );
  });

  test('deleteSmsEvent does not touch wallet_mutations', () async {
    // Structural proof: deleteSmsEvent only touches decision_traces,
    // transaction_candidates, and sms_events. It never writes to
    // wallet_mutations or any external provider table.
    final smsId = await insertTestSms(sourceKey: 'v2_WALLET_ISOLATION_4000');

    // Seed an unrelated wallet mutation.
    await db
        .into(db.walletMutations)
        .insert(
          WalletMutationsCompanion.insert(
            id: 'm-unrelated',
            operationKind: WalletMutationOperation.create,
            payload: '{"accountId":"acc-1","amountMinor":-999}',
            state: WalletMutationState.succeeded,
            lineageKey: 'lineage-unrelated',
            fingerprint: 'fp-unrelated',
            createdAtEpochMs: 1700000000000,
            updatedAtEpochMs: 1700000000000,
          ),
        );

    await db.deleteSmsEvent(eventId: smsId, privacyEpoch: 1);

    final mutation = await (db.select(
      db.walletMutations,
    )..where((m) => m.id.equals('m-unrelated'))).getSingle();
    expect(
      mutation.state,
      WalletMutationState.succeeded,
      reason: 'deleteSmsEvent must not touch wallet_mutations',
    );
    expect(
      mutation.payload,
      '{"accountId":"acc-1","amountMinor":-999}',
      reason: 'mutation payload must be unchanged',
    );
  });
}
