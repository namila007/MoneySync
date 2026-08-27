import 'package:money_sync/features/onboarding/domain/onboarding_revisions.dart';

enum OnboardingStep {
  welcome,
  privacyExplanation,
  sourceSmsPromise,
  deviceProtection,
  permissionEducation,
  disclosure,
  smsAccessDisclosure,
  smsAccessDecision,
  notificationPermissionDecision,
}

final class OnboardingState {
  const OnboardingState({
    required this.currentStep,
    required this.disclosureRevision,
    required this.isComplete,
    this.onboardingRevision,
    this.smsAccessAvailable = true,
  });

  factory OnboardingState.initial({bool smsAccessAvailable = true}) =>
      OnboardingState(
        currentStep: OnboardingStep.welcome,
        disclosureRevision: 1,
        isComplete: false,
        smsAccessAvailable: smsAccessAvailable,
      );

  factory OnboardingState.supplementAt(
    OnboardingStep step, {
    bool smsAccessAvailable = true,
  }) => OnboardingState(
    currentStep: step,
    disclosureRevision: 1,
    isComplete: false,
    onboardingRevision: kOnboardingRevision,
    smsAccessAvailable: smsAccessAvailable,
  );

  final OnboardingStep currentStep;
  final int disclosureRevision;
  final bool isComplete;
  final int? onboardingRevision;

  /// Whether this build can request SMS access at all. playManual cannot:
  /// the disclosure step is skipped and never counted (M4.3 §Step machine).
  final bool smsAccessAvailable;

  bool get isLastStep =>
      currentStep == OnboardingStep.notificationPermissionDecision;

  /// Steps that carry their own primary actions, so the page-level Next button
  /// must not be shown beside them. Advancing past the SMS disclosure with a
  /// generic Next would skip both the consent record and the permission
  /// request, which is exactly what the disclosure screen exists to gate.
  bool get providesOwnAdvanceAction =>
      currentStep == OnboardingStep.smsAccessDisclosure ||
      currentStep == OnboardingStep.smsAccessDecision ||
      currentStep == OnboardingStep.notificationPermissionDecision;

  OnboardingState nextStep() {
    if (isComplete) return this;
    return _skipUnavailableDisclosure(_advance());
  }

  OnboardingState goBack() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex <= 0) return this;
    var previous = _withStep(steps[currentIndex - 1]);
    if (!smsAccessAvailable &&
        previous.currentStep == OnboardingStep.smsAccessDisclosure) {
      previous = _withStep(steps[currentIndex - 2]);
    }
    return previous;
  }

  OnboardingState _advance() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex >= steps.length - 1) {
      return _withStep(currentStep, isComplete: true);
    }
    return _withStep(steps[currentIndex + 1]);
  }

  /// playManual never renders the SMS disclosure: stepping onto it advances
  /// again immediately, so the disclosure is unreachable in the flow.
  OnboardingState _skipUnavailableDisclosure(OnboardingState next) {
    if (!smsAccessAvailable &&
        next.currentStep == OnboardingStep.smsAccessDisclosure &&
        !next.isComplete) {
      return next._advance();
    }
    return next;
  }

  OnboardingState _withStep(OnboardingStep step, {bool? isComplete}) =>
      OnboardingState(
        currentStep: step,
        disclosureRevision: disclosureRevision,
        isComplete: isComplete ?? false,
        onboardingRevision: onboardingRevision,
        smsAccessAvailable: smsAccessAvailable,
      );

  int get completedStepCount {
    if (isComplete) return totalStepCount;
    final steps = OnboardingStep.values;
    var index = steps.indexOf(currentStep);
    if (!smsAccessAvailable &&
        index > steps.indexOf(OnboardingStep.smsAccessDisclosure)) {
      index -= 1;
    }
    return index;
  }

  int get totalStepCount =>
      OnboardingStep.values.length - (smsAccessAvailable ? 0 : 1);

  bool get hasAcceptedDisclosure => isComplete;
}
