import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_revisions.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/domain/resolve_onboarding_entry.dart';

final onboardingStateProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

class OnboardingNotifier extends Notifier<OnboardingState> {
  var _loaded = false;

  @override
  OnboardingState build() {
    _loadFromDrift();
    return OnboardingState.initial();
  }

  Future<void> _loadFromDrift() async {
    final log = Logger('onboarding');
    try {
      final dbAsync = ref.read(appDatabaseProvider);
      final db = dbAsync.requireValue;
      log.info('Database available for onboarding load');
      final repo = DriftOnboardingRepository(database: db);
      final persisted = await repo.load();
      if (persisted == null) {
        log.info(
          'No persisted onboarding state found - showing onboarding flow',
        );
        return;
      }

      final resolveEntry = const ResolveOnboardingEntry();
      final entry = resolveEntry(
        stored: persisted,
        currentOnboardingRevision: kOnboardingRevision,
      );

      switch (entry) {
        case OnboardingEntrySupplement():
          if (!_loaded) {
            _loaded = true;
            state = OnboardingState.supplementAt(entry.startAt);
            log.info(
              'Onboarding supplement: starting at ${entry.startAt.name}',
            );
          }
        case OnboardingEntryResume():
          if (!_loaded) {
            _loaded = true;
            state = persisted;
            log.info('Onboarding resume: at ${persisted.currentStep.name}');
          }
        case OnboardingEntryNone():
          if (!_loaded) {
            _loaded = true;
            state = persisted;
            log.info(
              'Onboarding complete, no supplement needed: revision=${persisted.onboardingRevision}',
            );
          }
        case OnboardingEntryFresh():
          log.info('Onboarding state registered as fresh');
      }
    } catch (e, s) {
      log.error('Onboarding load failed', e, s);
    }
  }

  Future<void> advanceToNextStep() async {
    if (state.isComplete) return;
    final log = Logger('onboarding');
    if (state.isLastStep) {
      log.info('advanceToNextStep on last step -> redirecting to complete()');
      await complete();
      return;
    }
    log.info('advanceToNextStep: ${state.currentStep.name} -> next');
    state = state.nextStep();
    log.info('advanceToNextStep: now ${state.currentStep.name}');
  }

  Future<void> complete() async {
    final log = Logger('onboarding');
    log.info('Onboarding complete() called');
    if (!state.isComplete) {
      state = OnboardingState(
        currentStep: state.currentStep,
        disclosureRevision: state.disclosureRevision,
        isComplete: true,
        onboardingRevision: kOnboardingRevision,
      );
      log.info('Advanced to complete state');
    } else {
      log.info('Already complete — skipping Drift write');
      return;
    }
    try {
      final db = ref.read(appDatabaseProvider).requireValue;
      final repo = DriftOnboardingRepository(database: db);
      await repo.complete(disclosureRevision: state.disclosureRevision);
      log.info('Onboarding persisted to Drift');
    } catch (e, s) {
      log.error('Onboarding persistence failed', e, s);
      rethrow;
    }
  }

  Future<void> grantSmsAccess() async {
    final log = Logger('onboarding');
    log.info('User granted SMS access consent');
    try {
      final db = ref.read(appDatabaseProvider).requireValue;
      final repo = DriftOnboardingRepository(database: db);
      await repo.acceptSmsDisclosure(smsDisclosureRevision: 1);
      log.info('SMS disclosure revision persisted');
    } catch (e, s) {
      log.error('Failed to persist SMS disclosure', e, s);
    }
    state = state.nextStep();
  }

  Future<void> skipSmsAccess() async {
    final log = Logger('onboarding');
    log.info('User skipped SMS access');
    state = state.nextStep();
  }

  void goBack() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex > 0) {
      final previous = steps[currentIndex - 1];
      state = OnboardingState(
        currentStep: previous,
        disclosureRevision: state.disclosureRevision,
        isComplete: false,
        onboardingRevision: state.onboardingRevision,
      );
    }
  }
}
