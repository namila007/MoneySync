import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_revisions.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

/// Ordered spy: one shared operation log across the onboarding repository and
/// the SMS gateway, so tests assert the SEQUENCE of consent writes versus
/// permission requests (M4.3), not merely that both eventually happened.
final class _OrderedSpy {
  _OrderedSpy(this.db, {this.gatewayStatus = SmsPermissionStatus.notRequested});

  final AppDatabase db;
  final SmsPermissionStatus gatewayStatus;
  final operations = <String>[];
  var repoThrowsOnSmsDisclosure = false;

  OnboardingRepository get repo => _SpyOnboardingRepository(this);

  SmsPermissionGateway get gateway =>
      _SpySmsPermissionGateway(this, gatewayStatus);
}

final class _SpyOnboardingRepository implements OnboardingRepository {
  _SpyOnboardingRepository(this.spy)
    : inner = DriftOnboardingRepository(database: spy.db);

  final _OrderedSpy spy;
  final DriftOnboardingRepository inner;

  @override
  Future<OnboardingState?> load() => inner.load();

  @override
  Future<void> complete({required int disclosureRevision}) =>
      inner.complete(disclosureRevision: disclosureRevision);

  @override
  Future<void> acceptRevision({required int disclosureRevision}) =>
      inner.acceptRevision(disclosureRevision: disclosureRevision);

  @override
  Future<void> acceptSmsDisclosure({required int smsDisclosureRevision}) {
    spy.operations.add('writeSmsDisclosure');
    if (spy.repoThrowsOnSmsDisclosure) {
      return Future.error(StateError('simulated Drift write failure'));
    }
    return inner.acceptSmsDisclosure(
      smsDisclosureRevision: smsDisclosureRevision,
    );
  }

  @override
  Future<void> acceptOnboardingRevision({required int onboardingRevision}) {
    spy.operations.add('writeOnboardingRevision');
    return inner.acceptOnboardingRevision(
      onboardingRevision: onboardingRevision,
    );
  }
}

final class _SpySmsPermissionGateway implements SmsPermissionGateway {
  _SpySmsPermissionGateway(this.spy, this.status);

  final _OrderedSpy spy;
  final SmsPermissionStatus status;

  @override
  Future<SmsPermissionStatus> current() async => status;

  @override
  Future<SmsPermissionStatus> request() async {
    spy.operations.add('requestSmsPermission');
    return status;
  }

  @override
  Future<void> openAppSettings() async {}
}

/// Seeds a completed revision-1 row so the supplement path triggers and the
/// page opens directly on the SMS disclosure step.
Future<AppDatabase> _databaseWithCompletedRevisionOne() async {
  final db = AppDatabase.inMemoryForTesting();
  await (db.update(
    db.appSettings,
  )..where((row) => row.singletonId.equals(1))).write(
    const AppSettingsCompanion(
      onboardingCompleted: Value(true),
      onboardingRevision: Value(1),
    ),
  );
  return db;
}

Widget _host({
  required AppDatabase db,
  required _OrderedSpy spy,
  required AppConfig config,
}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      appDatabaseProvider.overrideWith((ref) async => db),
      onboardingRepositoryProvider.overrideWith((ref) async => spy.repo),
      smsPermissionGatewayProvider.overrideWithValue(spy.gateway),
    ],
    child: const MaterialApp(home: OnboardingPage()),
  );
}

Future<AppSetting> _settings(AppDatabase db) =>
    db.select(db.appSettings).getSingle();

void main() {
  group('consent ordering (M4.3)', () {
    testWidgets('Continue writes smsDisclosureRevision BEFORE the request', (
      tester,
    ) async {
      final db = await _databaseWithCompletedRevisionOne();
      addTearDown(db.close);
      final spy = _OrderedSpy(db);
      await tester.pumpWidget(
        _host(db: db, spy: spy, config: const AppConfig.privateFull()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reading your bank messages'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(spy.operations, ['writeSmsDisclosure', 'requestSmsPermission']);
      final row = await _settings(db);
      expect(row.smsDisclosureRevision, kSmsDisclosureRevision);
    });

    testWidgets('Not now records no consent and never calls the gateway', (
      tester,
    ) async {
      final db = await _databaseWithCompletedRevisionOne();
      addTearDown(db.close);
      final spy = _OrderedSpy(db);
      await tester.pumpWidget(
        _host(db: db, spy: spy, config: const AppConfig.privateFull()),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.textContaining('Not now'));
      await tester.tap(find.textContaining('Not now'));
      await tester.pumpAndSettle();

      expect(spy.operations, isNot(contains('writeSmsDisclosure')));
      expect(spy.operations, isNot(contains('requestSmsPermission')));
      // Skipping still bumps the stored revision so the supplement is
      // offered at most once (M4.3 re-entry policy).
      expect(spy.operations, contains('writeOnboardingRevision'));
      final row = await _settings(db);
      expect(row.smsDisclosureRevision, isNull);
      expect(row.onboardingRevision, kOnboardingRevision);
    });

    testWidgets('back-press on the disclosure step writes nothing', (
      tester,
    ) async {
      final db = await _databaseWithCompletedRevisionOne();
      addTearDown(db.close);
      final spy = _OrderedSpy(db);
      await tester.pumpWidget(
        _host(db: db, spy: spy, config: const AppConfig.privateFull()),
      );
      await tester.pumpAndSettle();

      final before = List<String>.from(spy.operations);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pumpAndSettle();

      expect(spy.operations, before);
      final row = await _settings(db);
      expect(row.smsDisclosureRevision, isNull);
    });

    test('a request is never issued when the disclosure write fails', () async {
      final db = await _databaseWithCompletedRevisionOne();
      addTearDown(db.close);
      final spy = _OrderedSpy(db)..repoThrowsOnSmsDisclosure = true;
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(const AppConfig.privateFull()),
          appDatabaseProvider.overrideWith((ref) async => db),
          onboardingRepositoryProvider.overrideWith((ref) async => spy.repo),
          smsPermissionGatewayProvider.overrideWithValue(spy.gateway),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(onboardingStateProvider.notifier);
      await container.pump();
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.currentStep, OnboardingStep.smsAccessDisclosure);

      // The persistence failure must propagate so the disclosure step's
      // handler never reaches the permission request.
      await expectLater(notifier.grantSmsAccess(), throwsStateError);

      expect(spy.operations, isNot(contains('requestSmsPermission')));
      // The failed consent must not advance the step machine.
      expect(notifier.state.currentStep, OnboardingStep.smsAccessDisclosure);
      final row = await _settings(db);
      expect(row.smsDisclosureRevision, isNull);
    });

    testWidgets('playManual skips smsAccessDisclosure entirely', (
      tester,
    ) async {
      final db = AppDatabase.inMemoryForTesting();
      addTearDown(db.close);
      final spy = _OrderedSpy(
        db,
        gatewayStatus: SmsPermissionStatus.unavailableInBuild,
      );
      await tester.pumpWidget(
        _host(db: db, spy: spy, config: const AppConfig.playManual()),
      );
      await tester.pumpAndSettle();

      // First-run flow: welcome -> ... -> smsAccessDecision.
      for (var i = 0; i < 6; i++) {
        expect(find.text('Reading your bank messages'), findsNothing);
        await tester.ensureVisible(find.text('Next'));
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Reading your bank messages'), findsNothing);
      expect(find.text('Paste or share to import'), findsOneWidget);
      expect(spy.operations, isNot(contains('requestSmsPermission')));
    });
  });
}
