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

void main() {
  group('onboarding Drift persistence', () {
    late AppDatabase database;
    late DriftOnboardingRepository repo;

    setUp(() async {
      database = AppDatabase.inMemoryForTesting();
      repo = DriftOnboardingRepository(database: database);
    });

    tearDown(() => database.close());

    test(
      'complete() writes onboardingCompleted and load() reads it back',
      () async {
        await repo.complete(disclosureRevision: 1);

        final loaded = await repo.load();
        expect(loaded, isNotNull);
        expect(loaded!.isComplete, isTrue);
        expect(loaded.disclosureRevision, 1);
      },
    );

    test('load() returns null when onboarding is not complete', () async {
      final result = await repo.load();
      expect(result, isNull);
    });

    test('complete then acceptRevision keeps onboarding completed', () async {
      await repo.complete(disclosureRevision: 1);
      await repo.acceptRevision(disclosureRevision: 2);

      final loaded = await repo.load();
      expect(loaded, isNotNull);
      expect(loaded!.isComplete, isTrue);
      expect(loaded.disclosureRevision, 2);
    });

    test('load() returns null after database close and reopen', () async {
      await repo.complete(disclosureRevision: 1);

      await database.close();
      database = AppDatabase.inMemoryForTesting();
      repo = DriftOnboardingRepository(database: database);

      final result = await repo.load();
      expect(result, isNull, reason: 'in-memory DB is fresh after close');
    });

    test('completing at revision 2 persists onboardingRevision = 2', () async {
      await repo.complete(disclosureRevision: 1);

      final loaded = await repo.load();
      expect(loaded!.onboardingRevision, kOnboardingRevision);
    });

    test(
      'granting persists smsDisclosureRevision = kSmsDisclosureRevision',
      () async {
        await repo.acceptSmsDisclosure(
          smsDisclosureRevision: kSmsDisclosureRevision,
        );

        final row = await database.select(database.appSettings).getSingle();
        expect(row.smsDisclosureRevision, kSmsDisclosureRevision);
      },
    );

    test(
      'skipping leaves smsDisclosureRevision NULL but bumps revision',
      () async {
        await repo.complete(disclosureRevision: 1);
        await repo.acceptOnboardingRevision(
          onboardingRevision: kOnboardingRevision,
        );

        final row = await database.select(database.appSettings).getSingle();
        expect(row.smsDisclosureRevision, isNull);
        expect(row.onboardingRevision, kOnboardingRevision);
      },
    );
  });

  group('onboarding state sync from persistence', () {
    test(
      'notifier starts with initial state and loads from Drift async',
      () async {
        final container = ProviderContainer(
          overrides: [
            appConfigProvider.overrideWithValue(const AppConfig.privateFull()),
            onboardingRepositoryProvider.overrideWith(
              (ref) async => const _EmptyOnboardingRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(onboardingStateProvider.notifier);
        expect(notifier.state.isComplete, isFalse);
        await container.pump();
        expect(notifier.state.currentStep, OnboardingStep.welcome);
      },
    );
  });
}

final class _EmptyOnboardingRepository implements OnboardingRepository {
  const _EmptyOnboardingRepository();

  @override
  Future<void> acceptOnboardingRevision({
    required int onboardingRevision,
  }) async {}

  @override
  Future<void> acceptRevision({required int disclosureRevision}) async {}

  @override
  Future<void> acceptSmsDisclosure({
    required int smsDisclosureRevision,
  }) async {}

  @override
  Future<void> complete({required int disclosureRevision}) async {}

  @override
  Future<OnboardingState?> load() async => null;
}
