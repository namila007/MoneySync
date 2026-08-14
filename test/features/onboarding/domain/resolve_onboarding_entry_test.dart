import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/domain/resolve_onboarding_entry.dart';

void main() {
  group('ResolveOnboardingEntry', () {
    const resolveEntry = ResolveOnboardingEntry();
    const currentRevision = 2;

    test('returns Fresh when no stored state exists', () {
      final entry = resolveEntry(
        stored: null,
        currentOnboardingRevision: currentRevision,
      );
      expect(entry, isA<OnboardingEntryFresh>());
    });

    test('returns Resume when stored state is incomplete', () {
      final incomplete = OnboardingState.initial();
      final entry = resolveEntry(
        stored: incomplete,
        currentOnboardingRevision: currentRevision,
      );
      expect(entry, isA<OnboardingEntryResume>());
    });

    test('returns None when complete at current revision', () {
      const completed = OnboardingState(
        currentStep: OnboardingStep.smsAccessDecision,
        disclosureRevision: 1,
        isComplete: true,
        onboardingRevision: 2,
      );
      final entry = resolveEntry(
        stored: completed,
        currentOnboardingRevision: currentRevision,
      );
      expect(entry, isA<OnboardingEntryNone>());
    });

    test('returns Supplement when complete at old revision', () {
      const completedRevision1 = OnboardingState(
        currentStep: OnboardingStep.disclosure,
        disclosureRevision: 1,
        isComplete: true,
        onboardingRevision: 1,
      );
      final entry = resolveEntry(
        stored: completedRevision1,
        currentOnboardingRevision: currentRevision,
      );
      expect(entry, isA<OnboardingEntrySupplement>());
      expect(
        (entry as OnboardingEntrySupplement).startAt,
        OnboardingStep.smsAccessDisclosure,
      );
    });

    test('returns Supplement when complete with null revision', () {
      const completedNoRevision = OnboardingState(
        currentStep: OnboardingStep.disclosure,
        disclosureRevision: 1,
        isComplete: true,
      );
      final entry = resolveEntry(
        stored: completedNoRevision,
        currentOnboardingRevision: currentRevision,
      );
      expect(entry, isA<OnboardingEntrySupplement>());
    });
  });
}
