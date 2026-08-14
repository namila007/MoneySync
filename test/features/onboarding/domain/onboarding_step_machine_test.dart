import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_revisions.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';

void main() {
  group('onboarding step machine', () {
    OnboardingState at(OnboardingStep step) => OnboardingState(
      currentStep: step,
      disclosureRevision: 1,
      isComplete: false,
    );

    test('smsAccessDecision is the last step, not disclosure', () {
      expect(at(OnboardingStep.disclosure).isLastStep, isFalse);
      expect(at(OnboardingStep.smsAccessDecision).isLastStep, isTrue);
      expect(OnboardingState.initial().isLastStep, isFalse);
    });

    test(
      'nextStep walks welcome -> ... -> smsAccessDecision then completes',
      () {
        var state = OnboardingState.initial();
        final visited = <OnboardingStep>[];
        while (!state.isComplete) {
          visited.add(state.currentStep);
          state = state.nextStep();
          expect(visited.length, lessThan(OnboardingStep.values.length + 1));
        }
        expect(visited, OnboardingStep.values);
      },
    );

    test('totalStepCount is 8 in privateFull (SMS access available)', () {
      final state = OnboardingState.initial();
      expect(state.totalStepCount, 8);
      expect(state.nextStep().totalStepCount, 8);
    });

    test('totalStepCount is 7 when SMS is unavailable', () {
      final state = OnboardingState.initial(smsAccessAvailable: false);
      expect(state.totalStepCount, 7);
    });

    test(
      'appending steps did not change the ordinal of any pre-existing step',
      () {
        const preExisting = [
          OnboardingStep.welcome,
          OnboardingStep.privacyExplanation,
          OnboardingStep.sourceSmsPromise,
          OnboardingStep.deviceProtection,
          OnboardingStep.permissionEducation,
          OnboardingStep.disclosure,
        ];
        for (var i = 0; i < preExisting.length; i++) {
          expect(OnboardingStep.values.indexOf(preExisting[i]), i);
        }
      },
    );

    test('SMS-unavailable flow skips smsAccessDisclosure entirely', () {
      var state = OnboardingState.initial(smsAccessAvailable: false);
      final visited = <OnboardingStep>[];
      while (!state.isComplete) {
        visited.add(state.currentStep);
        state = state.nextStep();
      }
      expect(visited, isNot(contains(OnboardingStep.smsAccessDisclosure)));
      expect(visited.last, OnboardingStep.smsAccessDecision);
    });

    test('SMS-unavailable progress shows 7 of 7 at the decision step', () {
      var state = OnboardingState.initial(smsAccessAvailable: false);
      while (state.currentStep != OnboardingStep.smsAccessDecision) {
        state = state.nextStep();
      }
      // Decision is the 7th visible step (index 6, zero-based); the indicator
      // colours dots index <= current, so all 7 dots are filled.
      expect(state.completedStepCount, 6);
      expect(state.totalStepCount, 7);
    });

    test('goBack from the decision step returns to the disclosure step', () {
      final decision = at(OnboardingStep.smsAccessDecision);
      expect(decision.goBack().currentStep, OnboardingStep.smsAccessDisclosure);
    });

    test(
      'goBack in an SMS-unavailable build skips over the hidden disclosure',
      () {
        final decision = OnboardingState(
          currentStep: OnboardingStep.smsAccessDecision,
          disclosureRevision: 1,
          isComplete: false,
          smsAccessAvailable: false,
        );
        expect(decision.goBack().currentStep, OnboardingStep.disclosure);
      },
    );

    test('supplementAt seeds kOnboardingRevision', () {
      final state = OnboardingState.supplementAt(
        OnboardingStep.smsAccessDisclosure,
      );
      expect(state.onboardingRevision, kOnboardingRevision);
    });
  });
}
