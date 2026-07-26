import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/bootstrap/startup_state.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';

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
      if (persisted != null && persisted.isComplete && !_loaded) {
        _loaded = true;
        state = persisted;
        log.info('Onboarding state restored: complete, revision=${persisted.disclosureRevision}');
      } else if (persisted == null) {
        log.info('No persisted onboarding state found - showing onboarding flow');
      } else if (_loaded) {
        log.info('Onboarding already loaded in this session');
      } else {
        log.info('Onboarding found but not complete - showing flow');
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
      state = state.nextStep();
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

  void goBack() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(state.currentStep);
    if (currentIndex > 0) {
      final previous = steps[currentIndex - 1];
      state = OnboardingState(
        currentStep: previous,
        disclosureRevision: state.disclosureRevision,
        isComplete: false,
      );
    }
  }
}
