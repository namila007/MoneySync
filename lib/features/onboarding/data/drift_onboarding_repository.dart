import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';

final class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository({required this.database});

  final AppDatabase database;

  @override
  Future<OnboardingState?> load() async {
    final setting = await (database.select(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingleOrNull();
    if (setting == null) return null;
    if (!setting.onboardingCompleted) return null;
    return OnboardingState(
      currentStep: OnboardingStep.disclosure,
      disclosureRevision: setting.disclosureRevision ?? 1,
      isComplete: setting.onboardingCompleted,
    );
  }

  @override
  Future<void> complete({required int disclosureRevision}) async {
    await (database.update(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).write(
      const AppSettingsCompanion(
        onboardingCompleted: Value(true),
        onboardingRevision: Value(1),
        disclosureAccepted: Value(true),
      ),
    );
  }

  @override
  Future<void> acceptRevision({required int disclosureRevision}) async {
    await (database.update(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).write(
      AppSettingsCompanion(
        disclosureAccepted: const Value(true),
        disclosureRevision: Value(disclosureRevision),
      ),
    );
  }
}
