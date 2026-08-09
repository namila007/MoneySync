import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/features/sms_permission/domain/request_sms_permission.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

class SmsAccessDecisionStep extends ConsumerWidget {
  const SmsAccessDecisionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(smsPermissionStatusProvider);

    void onFinish() {
      ref.read(onboardingStateProvider.notifier).advanceToNextStep();
    }

    return statusAsync.when(
      loading: () => _DecisionContent(
        glyph: '\u25cb',
        label: 'Checking...',
        headline: 'Checking message reading status',
        primary: 'Please wait while we check your permission status.',
        showFinish: true,
        onFinish: onFinish,
      ),
      error: (e, _) => _DecisionContent(
        glyph: '\u25cb',
        label: 'Status unavailable',
        headline: 'Message reading status unavailable',
        primary:
            'MoneySync still works. Paste a bank message or share one '
            'from your SMS app, and it will be read the same way.',
        showFinish: true,
        onFinish: onFinish,
        secondaryLabel: 'Try again',
        onSecondary: () {
          ref.read(smsPermissionStatusProvider.notifier).refresh();
        },
      ),
      data: (status) {
        switch (status) {
          case SmsPermissionStatus.granted:
            return _DecisionContent(
              glyph: '\u25cf',
              label: 'On',
              headline: 'Message reading is on',
              primary:
                  'You can import a selected range of messages from Settings '
                  'whenever you want. Nothing is imported automatically.',
              showFinish: true,
              onFinish: onFinish,
            );
          case SmsPermissionStatus.unavailableInBuild:
            return _DecisionContent(
              glyph: '\u2013',
              label: 'Not in this build',
              headline: 'Paste or share to import',
              primary:
                  "This version of MoneySync doesn't read your SMS inbox at "
                  'all. Copy a bank message and paste it in, or use Share '
                  'from your SMS app.',
              showFinish: true,
              onFinish: onFinish,
            );
          case SmsPermissionStatus.permanentlyDenied:
            return _DecisionContent(
              glyph: '\u2298',
              label: 'Blocked in Settings',
              headline: 'Message reading is off',
              primary:
                  "That's fine — MoneySync still works. Paste a bank message "
                  'or share one from your SMS app, and it will be read the '
                  'same way.',
              showFinish: true,
              onFinish: onFinish,
              secondaryLabel: 'Open system settings',
              onSecondary: () {
                ref
                    .read(smsPermissionStatusProvider.notifier)
                    .openSystemSettings();
              },
            );
          default:
            return _DecisionContent(
              glyph: '\u25cb',
              label: 'Off',
              headline: 'Message reading is off',
              primary:
                  "That's fine — MoneySync still works. Paste a bank message "
                  'or share one from your SMS app, and it will be read the '
                  'same way.\n\nYou can turn message reading on later in '
                  'Settings \u2192 Message reading.',
              showFinish: true,
              onFinish: onFinish,
              secondaryLabel: 'Try again',
              onSecondary: () async {
                final outcome = await ref
                    .read(smsPermissionStatusProvider.notifier)
                    .request(acceptedDisclosureRevision: 1);
                if (outcome case SmsPermissionRequestCompleted _) {
                  // status is already refreshed via controller
                }
              },
            );
        }
      },
    );
  }
}

class _DecisionContent extends StatelessWidget {
  const _DecisionContent({
    required this.glyph,
    required this.label,
    required this.headline,
    required this.primary,
    required this.showFinish,
    this.onFinish,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String glyph;
  final String label;
  final String headline;
  final String primary;
  final bool showFinish;
  final VoidCallback? onFinish;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Text(
              glyph,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: label,
            child: Text(
              headline,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            primary,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          // No Expanded/Spacer here: OnboardingPage hosts every step inside a
          // SingleChildScrollView, so this Column is laid out with unbounded
          // height and a flex child would fail to lay out at all.
          const SizedBox(height: 32),
          if (showFinish)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onFinish,
                child: const Text('Finish'),
              ),
            ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
