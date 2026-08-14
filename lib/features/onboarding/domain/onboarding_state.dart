enum OnboardingStep {
  welcome,
  privacyExplanation,
  sourceSmsPromise,
  deviceProtection,
  permissionEducation,
  disclosure,
  smsAccessDisclosure,
  smsAccessDecision,
}

final class OnboardingState {
  const OnboardingState({
    required this.currentStep,
    required this.disclosureRevision,
    required this.isComplete,
    this.onboardingRevision,
  });

  factory OnboardingState.initial() => const OnboardingState(
    currentStep: OnboardingStep.welcome,
    disclosureRevision: 1,
    isComplete: false,
  );

  factory OnboardingState.supplementAt(OnboardingStep step) => OnboardingState(
    currentStep: step,
    disclosureRevision: 1,
    isComplete: false,
    onboardingRevision: 1,
  );

  final OnboardingStep currentStep;
  final int disclosureRevision;
  final bool isComplete;
  final int? onboardingRevision;

  bool get isLastStep => currentStep == OnboardingStep.smsAccessDecision;

  /// Steps that carry their own primary actions, so the page-level Next button
  /// must not be shown beside them. Advancing past the SMS disclosure with a
  /// generic Next would skip both the consent record and the permission
  /// request, which is exactly what the disclosure screen exists to gate.
  bool get providesOwnAdvanceAction =>
      currentStep == OnboardingStep.smsAccessDisclosure ||
      currentStep == OnboardingStep.smsAccessDecision;

  OnboardingState nextStep() {
    if (isComplete) return this;
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex >= steps.length - 1) {
      return OnboardingState(
        currentStep: currentStep,
        disclosureRevision: disclosureRevision,
        isComplete: true,
        onboardingRevision: onboardingRevision,
      );
    }
    return OnboardingState(
      currentStep: steps[currentIndex + 1],
      disclosureRevision: disclosureRevision,
      isComplete: false,
      onboardingRevision: onboardingRevision,
    );
  }

  int get completedStepCount {
    if (isComplete) return OnboardingStep.values.length;
    return OnboardingStep.values.indexOf(currentStep);
  }

  int get totalStepCount => OnboardingStep.values.length;

  bool get hasAcceptedDisclosure => isComplete;
}
