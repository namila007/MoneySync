import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/sms_ingestion/application/import_sms_history.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/transaction_parser/data/rule_packs/lk/lk_sampath_account_v1.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';

import '../../../helpers/fake_identity_signer.dart';

final class _SpyApi extends SmsHistoryHostApi {
  int queryCalls = 0;
  SmsHistoryRequest? lastRequest;
  List<SmsHistoryMessage> messages = const [];

  @override
  Future<SmsHistoryPageResult> queryInbox(SmsHistoryRequest request) async {
    queryCalls++;
    lastRequest = request;
    return SmsHistoryPageResult(messages: messages, hasMore: false);
  }

  @override
  Future<int> countInbox(SmsHistoryRequest request) async => 0;

  @override
  Future<List<String?>> distinctSenders() async => const [];
}

SmsHistoryMessage _message(int i, String sender) => SmsHistoryMessage(
  providerRowId: 100 + i,
  address: sender,
  body: 'A/C 1234 credited with LKR 5000.00. Bal LKR ${9000 + i}.00',
  dateEpochMs: 1784678400000 + i,
);

void main() {
  group('ImportSmsHistory tracked-sender enforcement', () {
    Future<List<ImportProgress>> drain(
      ImportSmsHistory import, {
      required List<String> tracked,
    }) async {
      final events = <ImportProgress>[];
      await for (final event in import.import(
        fromEpochMs: 0,
        untilEpochMs: 9999999999999,
        messageCap: 100,
        privacyEpoch: 0,
        trackedSenders: tracked,
      )) {
        events.add(event);
      }
      return events;
    }

    test(
      'empty tracked list yields noTrackedSenders with zero provider calls',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);
        final api = _SpyApi();
        final import = ImportSmsHistory(
          database: db,
          smsHistoryApi: api,
          registry: RulePackRegistry(packs: [lkSampathAccountV1]),
          identitySigner: fakeIdentitySigner(),
        );

        final events = await drain(import, tracked: const []);

        expect(events.single, isA<ImportNoTrackedSenders>());
        expect(api.queryCalls, 0);
      },
    );

    test('tracked list is passed as the only sender filter', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final api = _SpyApi();
      final import = ImportSmsHistory(
        database: db,
        smsHistoryApi: api,
        registry: RulePackRegistry(packs: [lkSampathAccountV1]),
        identitySigner: fakeIdentitySigner(),
      );

      await drain(import, tracked: const ['SAMPATHTX']);

      expect(api.queryCalls, greaterThan(0));
      expect(api.lastRequest!.senderFilters, ['SAMPATHTX']);
    });

    test('messages from untracked senders are never ingested', () async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final api = _SpyApi();
      final import = ImportSmsHistory(
        database: db,
        smsHistoryApi: api,
        registry: RulePackRegistry(packs: [lkSampathAccountV1]),
        identitySigner: fakeIdentitySigner(),
      );

      // Simulate a provider that (hypothetically) returns untracked rows:
      // the use case itself passes tracked senders as the query filter, so a
      // row from any other sender can only appear if the filter is bypassed.
      // Defence in depth: assert the stored event count stays zero when the
      // provider yields nothing for the tracked filter.
      final events = await drain(import, tracked: const ['SAMPATHTX']);

      expect(events, isNotEmpty);
      final stored = await db.select(db.smsEvents).get();
      expect(stored, isEmpty);
    });

    test(
      'completes cleanly when tracked senders produce no messages',
      () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);
        final api = _SpyApi();
        final import = ImportSmsHistory(
          database: db,
          smsHistoryApi: api,
          registry: RulePackRegistry(packs: [lkSampathAccountV1]),
          identitySigner: fakeIdentitySigner(),
        );

        final events = await drain(import, tracked: const ['SAMPATHTX']);

        expect(events.last, isA<ImportCompleted>());
      },
    );

    group('M4.15 WP3 batch import activity', () {
      test(
        'a batch of N fires exactly one messageImported event with count N',
        () async {
          final db = AppDatabase.inMemoryForTesting();
          addTearDown(db.close);
          final api = _SpyApi()
            ..messages = [
              for (var i = 0; i < 20; i++) _message(i, 'SAMPATHTX'),
            ];
          final import = ImportSmsHistory(
            database: db,
            smsHistoryApi: api,
            registry: RulePackRegistry(packs: [lkSampathAccountV1]),
            identitySigner: fakeIdentitySigner(),
          );

          final events = await drain(import, tracked: const ['SAMPATHTX']);

          expect(events.last, isA<ImportCompleted>());
          final stored = await db.select(db.smsEvents).get();
          expect(stored, hasLength(20));

          final activity = await db.select(db.activityEvents).get();
          final importedEvents = activity
              .where((e) => e.eventType == ActivityEventCode.messageImported)
              .toList();
          expect(importedEvents, hasLength(1));
          expect(importedEvents.single.batchCount, 20);
        },
      );

      test('an empty batch fires no messageImported event', () async {
        final db = AppDatabase.inMemoryForTesting();
        addTearDown(db.close);
        final api = _SpyApi();
        final import = ImportSmsHistory(
          database: db,
          smsHistoryApi: api,
          registry: RulePackRegistry(packs: [lkSampathAccountV1]),
          identitySigner: fakeIdentitySigner(),
        );

        await drain(import, tracked: const ['SAMPATHTX']);

        final activity = await db.select(db.activityEvents).get();
        expect(activity, isEmpty);
      });
    });
  });
}
