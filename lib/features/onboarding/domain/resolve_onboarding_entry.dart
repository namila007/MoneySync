import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';

sealed class OnboardingEntry {
  const OnboardingEntry();
}

final class OnboardingEntryFresh extends OnboardingEntry {
  const OnboardingEntryFresh();
}

final class OnboardingEntryResume extends OnboardingEntry {
  const OnboardingEntryResume(this.step);
  final OnboardingStep step;
}

final class OnboardingEntrySupplement extends OnboardingEntry {
  const OnboardingEntrySupplement(this.startAt);
  final OnboardingStep startAt;
}

final class OnboardingEntryNone extends OnboardingEntry {
  const OnboardingEntryNone();
}

final class ResolveOnboardingEntry {
  const ResolveOnboardingEntry();

  OnboardingEntry call({
    required OnboardingState? stored,
    required int currentOnboardingRevision,
  }) {
    if (stored == null) return const OnboardingEntryFresh();
    if (!stored.isComplete) {
      return OnboardingEntryResume(stored.currentStep);
    }
    if ((stored.onboardingRevision ?? 0) < currentOnboardingRevision) {
      return const OnboardingEntrySupplement(
        OnboardingStep.smsAccessDisclosure,
      );
    }
    return const OnboardingEntryNone();
  }
}
