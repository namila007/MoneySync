import 'package:drift/drift.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_revisions.dart';
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
      currentStep: OnboardingStep.smsAccessDecision,
      disclosureRevision: setting.disclosureRevision ?? 1,
      isComplete: setting.onboardingCompleted,
      onboardingRevision: setting.onboardingRevision,
    );
  }

  @override
  Future<void> complete({required int disclosureRevision}) async {
    await (database.update(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).write(
      AppSettingsCompanion(
        onboardingCompleted: const Value(true),
        onboardingRevision: Value(kOnboardingRevision),
        disclosureAccepted: const Value(true),
        disclosureRevision: Value(disclosureRevision),
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

  @override
  Future<void> acceptSmsDisclosure({required int smsDisclosureRevision}) async {
    await (database.update(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).write(
      AppSettingsCompanion(smsDisclosureRevision: Value(smsDisclosureRevision)),
    );
  }

  @override
  Future<void> acceptOnboardingRevision({
    required int onboardingRevision,
  }) async {
    await (database.update(
      database.appSettings,
    )..where((row) => row.singletonId.equals(1))).write(
      AppSettingsCompanion(onboardingRevision: Value(onboardingRevision)),
    );
  }
}
