import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_revisions.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/domain/resolve_onboarding_entry.dart';

final onboardingStateProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

class OnboardingNotifier extends Notifier<OnboardingState> {
  var _loaded = false;

  bool get _smsAccessAvailable => ref
      .read(appConfigProvider)
      .capabilities
      .isEnabled(AppCapability.smsPermission);

  @override
  OnboardingState build() {
    _loadFromDrift();
    return OnboardingState.initial(smsAccessAvailable: _smsAccessAvailable);
  }

  Future<void> _loadFromDrift() async {
    final log = Logger('onboarding');
    try {
      final repo = await ref.read(onboardingRepositoryProvider.future);
      log.info('Database available for onboarding load');
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
            state = OnboardingState.supplementAt(
              entry.startAt,
              smsAccessAvailable: _smsAccessAvailable,
            );
            if (!_smsAccessAvailable) {
              // playManual never renders the disclosure step (M4.3).
              state = state.nextStep();
            }
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
        smsAccessAvailable: state.smsAccessAvailable,
      );
      log.info('Advanced to complete state');
    } else {
      log.info('Already complete — skipping Drift write');
      return;
    }
    try {
      final repo = await ref.read(onboardingRepositoryProvider.future);
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
      final repo = await ref.read(onboardingRepositoryProvider.future);
      await repo.acceptSmsDisclosure(
        smsDisclosureRevision: kSmsDisclosureRevision,
      );
      log.info('SMS disclosure revision persisted');
    } catch (e, s) {
      log.error('Failed to persist SMS disclosure', e, s);
      rethrow;
    }
    state = state.nextStep();
  }

  Future<void> skipSmsAccess() async {
    final log = Logger('onboarding');
    log.info('User skipped SMS access');
    try {
      final repo = await ref.read(onboardingRepositoryProvider.future);
      await repo.acceptOnboardingRevision(
        onboardingRevision: kOnboardingRevision,
      );
      log.info('Onboarding revision persisted after SMS skip');
    } catch (e, s) {
      log.error('Failed to persist onboarding revision after skip', e, s);
      rethrow;
    }
    state = state.nextStep();
  }

  void goBack() {
    state = state.goBack();
  }
}
