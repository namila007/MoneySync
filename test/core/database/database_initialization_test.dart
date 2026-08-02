import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:money_sync/core/database/app_database.dart';

void main() {
  group('Database initialization', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.inMemoryForTesting();
    });

    tearDown(() => database.close());

    test(
      'app_settings singleton row exists with default values after open',
      () async {
        final setting = await (database.select(
          database.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.privacyEpoch, 0);
        expect(setting.onboardingCompleted, false);
        expect(setting.disclosureAccepted, false);
        expect(setting.processingMode, 'review');
        expect(setting.configurationRevision, 0);
      },
    );

    test(
      'app_lock_state singleton row exists with default values after open',
      () async {
        final lockState = await (database.select(
          database.appLockState,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(lockState.lockEnabled, false);
        expect(lockState.inactivityTimeoutSeconds, 300);
        expect(lockState.lockMetadata, isNull);
      },
    );

    test(
      'wallet_connection_status singleton row exists with default values after open',
      () async {
        final status = await (database.select(
          database.walletConnectionStatus,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(status.status, 'disconnected');
        expect(status.lastSyncAtEpochMs, isNull);
      },
    );

    test('onboarding completion persists through write/read cycle', () async {
      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        const AppSettingsCompanion(
          onboardingCompleted: Value(true),
          onboardingRevision: Value(1),
          disclosureAccepted: Value(true),
          disclosureRevision: Value(1),
        ),
      );

      final setting = await (database.select(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(setting.onboardingCompleted, true);
      expect(setting.onboardingRevision, 1);
      expect(setting.disclosureAccepted, true);
      expect(setting.disclosureRevision, 1);
    });

    test('app lock state persists through write/read cycle', () async {
      await (database.update(
        database.appLockState,
      )..where((row) => row.singletonId.equals(1))).write(
        const AppLockStateCompanion(
          lockEnabled: Value(true),
          inactivityTimeoutSeconds: Value(60),
        ),
      );

      final lockState = await (database.select(
        database.appLockState,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(lockState.lockEnabled, true);
      expect(lockState.inactivityTimeoutSeconds, 60);
    });

    test('configuration revision can be incremented', () async {
      final before = await (database.select(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      await (database.update(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).write(
        AppSettingsCompanion(
          configurationRevision: Value(before.configurationRevision + 1),
          processingMode: const Value('manual'),
        ),
      );

      final after = await (database.select(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(after.configurationRevision, before.configurationRevision + 1);
      expect(after.processingMode, 'manual');
    });

    test('wallet_connection_status transitions correctly', () async {
      await (database.update(
        database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).write(
        const WalletConnectionStatusCompanion(
          status: Value('connected'),
          lastSyncAtEpochMs: Value(1700000000000),
        ),
      );

      var status = await (database.select(
        database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(status.status, 'connected');
      expect(status.lastSyncAtEpochMs, 1700000000000);

      await (database.update(
        database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).write(
        const WalletConnectionStatusCompanion(status: Value('disconnected')),
      );

      status = await (database.select(
        database.walletConnectionStatus,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(status.status, 'disconnected');
    });

    test('privacy epoch can be advanced atomically', () async {
      final newEpoch = await database.advancePrivacyEpoch(expectedCurrent: 0);

      expect(newEpoch, 1);

      final setting = await (database.select(
        database.appSettings,
      )..where((row) => row.singletonId.equals(1))).getSingle();

      expect(setting.privacyEpoch, 1);
    });

    test('advancePrivacyEpoch fails when expected current is wrong', () async {
      await expectLater(
        database.advancePrivacyEpoch(expectedCurrent: 99),
        throwsA(isA<StalePrivacyEpochException>()),
      );
    });

    test(
      'processing mode defaults to review and can be changed to manual',
      () async {
        var setting = await (database.select(
          database.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.processingMode, 'review');

        await (database.update(database.appSettings)
              ..where((row) => row.singletonId.equals(1)))
            .write(const AppSettingsCompanion(processingMode: Value('manual')));

        setting = await (database.select(
          database.appSettings,
        )..where((row) => row.singletonId.equals(1))).getSingle();

        expect(setting.processingMode, 'manual');
      },
    );
  });
}
