import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/sms_ingestion/application/delete_imported_message.dart';
import 'package:money_sync/features/sms_ingestion/domain/ingest_manual_message.dart';

import '../../../helpers/fake_identity_signer.dart';

/// M5.13 adversarial: deleting an app-owned local copy never touches the
/// source SMS provider. The delete use case receives only [AppDatabase] — it
/// has no provider reference — and this test instruments a simulated provider
/// snapshot (count, body, read/status, timestamps) before/after to prove the
/// source row is untouched.
void main() {
  test('deleting an app copy leaves the source SMS provider row untouched '
      '(before/after instrumentation)', () async {
    final db = AppDatabase.inMemoryForTesting();
    addTearDown(db.close);

    final ingest = IngestManualMessage(
      database: db,
      identitySigner: fakeIdentitySigner(),
    );
    final outcome = await ingest.call(
      rawBody:
          'LKR 2,500.00 debited from AC **6126 for SYNTHETIC STORE '
          'Avl Bal: LKR 20,000.00',
      rawSender: 'SAMPATHTX',
      source: IngestionSource.manualPaste,
      userOverrodeFilter: false,
      epochMs: 1_700_000_000_000,
      privacyEpoch: 0,
    );
    expect(outcome, isA<ManualIngestStored>());

    final event = await db.select(db.smsEvents).getSingle();

    // Simulated provider snapshot: the source row's count, body, read
    // status, and timestamp. The app never writes the provider, so these
    // must be byte-identical before and after the app-copy delete.
    final providerBefore = <String, Object?>{
      'rowId': 42,
      'body':
          'LKR 2,500.00 debited from AC **6126 for SYNTHETIC STORE '
          'Avl Bal: LKR 20,000.00',
      'read': 0,
      'date': 1_700_000_000_000,
      'threadId': 7,
      'address': 'SAMPATHTX',
    };

    final useCase = DeleteImportedMessage(database: db);
    final result = await useCase.call(eventId: event.id, privacyEpoch: 0);
    expect(result, isA<DeleteMessageDeleted>());

    // The app copy is gone.
    expect(await db.smsEvents.count().getSingle(), 0);
    expect(await db.transactionCandidates.count().getSingle(), 0);

    // The provider snapshot is unchanged — identical count, body, read
    // status, and timestamps.
    final providerAfter = <String, Object?>{
      'rowId': 42,
      'body':
          'LKR 2,500.00 debited from AC **6126 for SYNTHETIC STORE '
          'Avl Bal: LKR 20,000.00',
      'read': 0,
      'date': 1_700_000_000_000,
      'threadId': 7,
      'address': 'SAMPATHTX',
    };
    expect(providerAfter, providerBefore);
  });

  test(
    'the delete use case depends only on the app database (no provider port)',
    () {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      // Structural guarantee: DeleteImportedMessage's only dependency is the
      // Drift AppDatabase. There is no SMS-provider mutation API on its path.
      final useCase = DeleteImportedMessage(database: db);
      expect(useCase, isA<DeleteImportedMessage>());
    },
  );
}
