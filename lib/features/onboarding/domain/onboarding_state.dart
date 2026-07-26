enum OnboardingStep {
  welcome,
  privacyExplanation,
  sourceSmsPromise,
  deviceProtection,
  permissionEducation,
  disclosure,
}

final class OnboardingState {
  const OnboardingState({
    required this.currentStep,
    required this.disclosureRevision,
    required this.isComplete,
  });

  factory OnboardingState.initial() => const OnboardingState(
    currentStep: OnboardingStep.welcome,
    disclosureRevision: 1,
    isComplete: false,
  );

  final OnboardingStep currentStep;
  final int disclosureRevision;
  final bool isComplete;

  bool get isLastStep => currentStep == OnboardingStep.disclosure;

  OnboardingState nextStep() {
    if (isComplete) return this;
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex >= steps.length - 1) {
      return OnboardingState(
        currentStep: currentStep,
        disclosureRevision: disclosureRevision,
        isComplete: true,
      );
    }
    return OnboardingState(
      currentStep: steps[currentIndex + 1],
      disclosureRevision: disclosureRevision,
      isComplete: false,
    );
  }

  int get completedStepCount {
    if (isComplete) return OnboardingStep.values.length;
    return OnboardingStep.values.indexOf(currentStep);
  }

  int get totalStepCount => OnboardingStep.values.length;

  bool get hasAcceptedDisclosure => isComplete;
}
