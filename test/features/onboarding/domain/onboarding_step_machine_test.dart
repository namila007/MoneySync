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

    test('notificationPermissionDecision is the last step', () {
      expect(at(OnboardingStep.disclosure).isLastStep, isFalse);
      expect(at(OnboardingStep.smsAccessDecision).isLastStep, isFalse);
      expect(
        at(OnboardingStep.notificationPermissionDecision).isLastStep,
        isTrue,
      );
      expect(OnboardingState.initial().isLastStep, isFalse);
    });

    test(
      'nextStep from smsAccessDecision lands on notificationPermissionDecision',
      () {
        final decision = at(OnboardingStep.smsAccessDecision);
        expect(
          decision.nextStep().currentStep,
          OnboardingStep.notificationPermissionDecision,
        );
      },
    );

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

    test('totalStepCount is 9 in privateFull (SMS access available)', () {
      final state = OnboardingState.initial();
      expect(state.totalStepCount, 9);
      expect(state.nextStep().totalStepCount, 9);
    });

    test('totalStepCount is 8 when SMS is unavailable', () {
      final state = OnboardingState.initial(smsAccessAvailable: false);
      expect(state.totalStepCount, 8);
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
      expect(visited.last, OnboardingStep.notificationPermissionDecision);
    });

    test('SMS-unavailable progress shows 8 of 8 at the decision step', () {
      var state = OnboardingState.initial(smsAccessAvailable: false);
      while (
          state.currentStep != OnboardingStep.notificationPermissionDecision) {
        state = state.nextStep();
      }
      // Decision is the 8th visible step (index 7, zero-based); the indicator
      // colours dots index <= current, so all 8 dots are filled.
      expect(state.completedStepCount, 7);
      expect(state.totalStepCount, 8);
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
