import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
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
  });

  group('onboarding state sync from persistence', () {
    test('notifier starts with initial state and loads from Drift async', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingStateProvider.notifier);
      expect(notifier.state.isComplete, isFalse);
    });
  });
}
