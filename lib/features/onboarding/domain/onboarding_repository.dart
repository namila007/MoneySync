import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';

abstract interface class OnboardingRepository {
  Future<OnboardingState?> load();
  Future<void> complete({required int disclosureRevision});
  Future<void> acceptRevision({required int disclosureRevision});
}
