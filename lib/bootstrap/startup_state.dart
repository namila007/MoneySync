import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/database/database_health.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_repository.dart';

enum StartupStatus { initializing, recoveryRequired, onboardingRequired, ready }

final class StartupState {
  const StartupState({
    this.status = StartupStatus.initializing,
    this.health,
    this.requestedRoute,
  });
  final StartupStatus status;
  final DatabaseHealth? health;
  final String? requestedRoute;
}

final startupStateProvider = NotifierProvider<StartupNotifier, StartupState>(
  StartupNotifier.new,
);

class StartupNotifier extends Notifier<StartupState> {
  @override
  StartupState build() => const StartupState();

  Future<void> initialize({
    required DatabaseHealthRepository healthRepo,
    required OnboardingRepository onboardingRepo,
  }) async {
    final log = Logger('startup');
    log.info('StartupNotifier.initialize() called');
    state = const StartupState(status: StartupStatus.initializing);

    final health = await healthRepo.check();
    log.info('Database health check: ${health.status.name} (code=${health.safeCode})');
    if (health.status != DatabaseHealthStatus.ready) {
      state = StartupState(
        status: StartupStatus.recoveryRequired,
        health: health,
      );
      log.info('Startup result: recoveryRequired - ${health.safeCode}');
      return;
    }

    final onboarding = await onboardingRepo.load();
    log.info('Onboarding load: ${onboarding != null ? "found (complete=${onboarding.isComplete})" : "null"}');
    if (onboarding == null || !onboarding.isComplete) {
      state = const StartupState(status: StartupStatus.onboardingRequired);
      log.info('Startup result: onboardingRequired');
      return;
    }

    state = const StartupState(status: StartupStatus.ready);
    log.info('Startup result: ready');
  }
}
