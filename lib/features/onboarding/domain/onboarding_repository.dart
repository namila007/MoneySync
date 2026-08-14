import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';

abstract interface class OnboardingRepository {
  Future<OnboardingState?> load();
  Future<void> complete({required int disclosureRevision});
  Future<void> acceptRevision({required int disclosureRevision});
  Future<void> acceptSmsDisclosure({required int smsDisclosureRevision});

  /// Marks the current onboarding sequence revision as acknowledged without
  /// implying any SMS-disclosure consent (M4.3: skipping the supplement must
  /// bump the stored revision so the supplement is offered at most once).
  Future<void> acceptOnboardingRevision({required int onboardingRevision});
}
