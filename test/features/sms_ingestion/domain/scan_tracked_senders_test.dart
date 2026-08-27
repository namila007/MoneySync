import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/notifications/data/fake_notification_service.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_ingestion/domain/scan_tracked_senders.dart';
import 'package:money_sync/features/sms_tracking/domain/tracked_senders.dart';
import 'package:money_sync/features/transaction_parser/data/rule_packs/lk/lk_sampath_account_v1.dart';
import 'package:money_sync/features/transaction_parser/domain/rule_pack_registry.dart';

import '../../../helpers/fake_identity_signer.dart';

/// Minimal SmsHistoryHostApi stub — returns canned responses.
final class _FakeSmsHistoryApi extends SmsHistoryHostApi {
  List<SmsHistoryMessage> messages = const [];
  bool shouldThrow = false;

  @override
  Future<SmsHistoryPageResult> queryInbox(SmsHistoryRequest request) async {
    if (shouldThrow) throw StateError('simulated API failure');
    return SmsHistoryPageResult(messages: messages, hasMore: false);
  }

  @override
  Future<int> countInbox(SmsHistoryRequest request) async => 0;

  @override
  Future<List<String?>> distinctSenders() async => const [];
}

/// Trivial in-memory TrackedSendersRepository.
final class _FakeTrackedSendersRepository implements TrackedSendersRepository {
  List<String> _senders = const [];

  void setSenders(List<String> senders) => _senders = senders;

  @override
  Future<List<TrackedSender>> load() async => [
    for (final s in _senders) TrackedSender.create(s, addedAtEpochMs: 0),
  ];

  @override
  Future<void> save(List<String> addresses) async => _senders = addresses;
}

SmsHistoryMessage _msg(int i, String sender) => SmsHistoryMessage(
  providerRowId: 100 + i,
  address: sender,
  body: 'A/C 1234 credited with LKR 5000.00. Bal LKR ${9000 + i}.00',
  dateEpochMs: 1784678400000 + i,
);

void main() {
  late AppDatabase db;
  late _FakeSmsHistoryApi api;
  late FakeNotificationService notifications;
  late _FakeTrackedSendersRepository trackedSendersRepo;
  late ScanTrackedSenders scan;

  setUp(() {
    db = AppDatabase.inMemoryForTesting();
    api = _FakeSmsHistoryApi();
    notifications = FakeNotificationService();
    trackedSendersRepo = _FakeTrackedSendersRepository();
    scan = ScanTrackedSenders(
      database: db,
      smsHistoryApi: api,
      registry: RulePackRegistry(packs: [lkSampathAccountV1]),
      identitySigner: fakeIdentitySigner(),
      notificationService: notifications,
      trackedSendersRepository: trackedSendersRepo,
    );
  });

  tearDown(() => db.close());

  group('ScanTrackedSenders — no-op paths', () {
    test('does nothing when autoImportEnabled is false', () async {
      // Default app_settings has autoImportEnabled = false.
      await scan();

      expect(notifications.shown, isEmpty);
      final state = await db.trackingStateOrDefault();
      expect(state.lastScanAtEpochMs, isNull);
    });

    test('does nothing when tracked senders list is empty', () async {
      await db.updateTrackingState(lastScanAtEpochMs: const Value.absent());
      await (db.update(db.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(const AppSettingsCompanion(autoImportEnabled: Value(true)));

      await scan();

      expect(notifications.shown, isEmpty);
      final state = await db.trackingStateOrDefault();
      expect(state.lastScanAtEpochMs, isNull);
    });
  });

  group('ScanTrackedSenders — success path', () {
    test('shows ongoing notification, imports, advances watermark', () async {
      await (db.update(db.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(const AppSettingsCompanion(autoImportEnabled: Value(true)));
      trackedSendersRepo.setSenders(['SAMPATHTX']);
      api.messages = [_msg(0, 'SAMPATHTX'), _msg(1, 'SAMPATHTX')];

      await scan();

      // Two notifications: ongoing=true then ongoing=false.
      expect(notifications.shown, hasLength(2));
      expect(notifications.shown[0].ongoing, isTrue);
      expect(notifications.shown[1].ongoing, isFalse);

      // Watermark advanced.
      final state = await db.trackingStateOrDefault();
      expect(state.lastScanAtEpochMs, isNotNull);
      expect(state.lastScanOutcome, 'ok');
    });

    test('shows "No new messages" when import yields zero', () async {
      await (db.update(db.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(const AppSettingsCompanion(autoImportEnabled: Value(true)));
      trackedSendersRepo.setSenders(['SAMPATHTX']);
      // No messages from the API.
      api.messages = const [];

      await scan();

      expect(notifications.shown, hasLength(2));
      expect(notifications.shown[1].body, contains('No new messages'));
      final state = await db.trackingStateOrDefault();
      expect(state.lastScanOutcome, 'ok');
    });
  });

  group('ScanTrackedSenders — failure path', () {
    test('does not advance watermark on API failure', () async {
      await (db.update(db.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(const AppSettingsCompanion(autoImportEnabled: Value(true)));
      trackedSendersRepo.setSenders(['SAMPATHTX']);
      api.shouldThrow = true;

      await scan();

      // Still shows two notifications: ongoing then failure.
      expect(notifications.shown, hasLength(2));
      expect(notifications.shown[1].ongoing, isFalse);
      expect(notifications.shown[1].body, contains("Couldn't check"));

      // Watermark NOT advanced.
      final state = await db.trackingStateOrDefault();
      expect(state.lastScanAtEpochMs, isNull);
      expect(state.lastScanOutcome, 'failed');
    });
  });

  group('ScanTrackedSenders — logging', () {
    test('logs error on import stream failure', () async {
      await (db.update(db.appSettings)
            ..where((row) => row.singletonId.equals(1)))
          .write(const AppSettingsCompanion(autoImportEnabled: Value(true)));
      trackedSendersRepo.setSenders(['SAMPATHTX']);
      api.shouldThrow = true;

      final captured = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(captured.add);
      addTearDown(sub.cancel);

      await scan();

      expect(
        captured.any(
          (r) =>
              r.level == Level.SEVERE &&
              r.loggerName == 'sms.scan' &&
              r.message == 'Scan failed: import error',
        ),
        isTrue,
      );
    });
  });
}
