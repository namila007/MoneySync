import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/features/onboarding/presentation/steps/sms_access_decision_step.dart';
import 'package:money_sync/features/onboarding/presentation/steps/sms_access_disclosure_step.dart';

class OnboardingReviewWrapper extends StatelessWidget {
  const OnboardingReviewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OnboardingReviewPage();
  }
}

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingStateProvider);

    if (state.isComplete) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              _StepIndicator(
                current: state.completedStepCount,
                total: state.totalStepCount,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: switch (state.currentStep) {
                    OnboardingStep.welcome => const _WelcomeStep(),
                    OnboardingStep.privacyExplanation =>
                      const _PrivacyExplanationStep(),
                    OnboardingStep.sourceSmsPromise =>
                      const _SourceSmsPromiseStep(),
                    OnboardingStep.deviceProtection =>
                      const _DeviceProtectionStep(),
                    OnboardingStep.permissionEducation =>
                      const _PermissionEducationStep(),
                    OnboardingStep.disclosure => const _DisclosureStep(),
                    OnboardingStep.smsAccessDisclosure =>
                      const SmsAccessDisclosureStep(),
                    OnboardingStep.smsAccessDecision =>
                      const SmsAccessDecisionStep(),
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!state.isComplete) _BackButton(state: state),
                  _ForwardButton(state: state),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= current
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class _BackButton extends ConsumerWidget {
  const _BackButton({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.currentStep == OnboardingStep.welcome) {
      return const SizedBox.shrink();
    }

    return OutlinedButton(
      onPressed: () {
        ref.read(onboardingStateProvider.notifier).goBack();
      },
      child: const Text('Back'),
    );
  }
}

class _ForwardButton extends ConsumerWidget {
  const _ForwardButton({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The SMS disclosure and decision steps own their advance actions. Showing
    // a generic Next beside them lets the user walk past the disclosure without
    // recording consent or ever reaching the system permission dialog.
    if (state.providesOwnAdvanceAction) {
      return const SizedBox.shrink();
    }

    return FilledButton(
      onPressed: () {
        final currentState = ref.read(onboardingStateProvider);
        if (currentState.isLastStep) {
          ref.read(onboardingStateProvider.notifier).complete();
        } else {
          ref.read(onboardingStateProvider.notifier).advanceToNextStep();
        }
      },
      child: Text(state.isLastStep ? 'Accept & finish' : 'Next'),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.chrome_reader_mode_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to MoneySync',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Your local-first SMS transaction assistant. '
          'MoneySync helps you review and track bank transactions '
          'without sending your data to anyone.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'This setup takes about two minutes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PrivacyExplanationStep extends StatelessWidget {
  const _PrivacyExplanationStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Your data stays on your device',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'MoneySync operates entirely on your device.\n'
          'No cloud accounts, no analytics, no tracking.\n'
          'All financial data is encrypted at rest.\n'
          'You can delete everything at any time.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _SourceSmsPromiseStep extends StatelessWidget {
  const _SourceSmsPromiseStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.sms_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'MoneySync reads SMS but never changes them',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'The app only reads transaction SMS from known bank senders.\n'
          'It never marks messages as read, archives, or deletes your SMS.\n'
          'SMS permissions are optional and can be granted later.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _DeviceProtectionStep extends StatelessWidget {
  const _DeviceProtectionStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.fingerprint,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Protect your financial data',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'We recommend enabling device authentication to '
          'access the app.\n\n'
          'Use your fingerprint or lock screen to open MoneySync.\n'
          'Financial screens are protected from screenshots.\n'
          'The database is encrypted even without app lock.\n'
          'You can change this later in Settings.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _PermissionEducationStep extends StatelessWidget {
  const _PermissionEducationStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'About permissions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'MoneySync requests permissions only when needed.\n\n'
          'SMS permission is optional \u2014 you choose when to grant it.\n'
          'No access to your contacts, location, or files.\n'
          'Wallet connection is optional and requires your token.\n'
          'No notifications or background services without your consent.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _DisclosureStep extends StatelessWidget {
  const _DisclosureStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.description_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Privacy disclosure',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'By continuing, you acknowledge:\n\n'
          'MoneySync operates locally on your device.\n'
          'No personal data is sent to any server.\n'
          'The Wallet connection is optional and uses HTTPS.\n'
          'You can clear all app-local data from Settings.\n'
          'SMS permissions require explicit consent.\n'
          'The app is provided as-is for review purposes.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Text(
          'Disclosure revision 1 \u2022 July 2026',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _OnboardingReviewPage extends StatelessWidget {
  const _OnboardingReviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Setup complete',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'You have completed the initial setup of MoneySync.\n\n'
                'Your encrypted database is ready. Device authentication '
                'can be configured in Security & Privacy.\n\n'
                'Wallet connection and SMS import can be set up individually '
                'when you need them.',
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What was configured',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\u2022 Local-only privacy first approach\n'
                        '\u2022 Database encryption at rest\n'
                        '\u2022 Read-only SMS policy\n'
                        '\u2022 Optional device authentication\n'
                        '\u2022 Review-mode processing default\n'
                        '\u2022 No data sent to any server',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
