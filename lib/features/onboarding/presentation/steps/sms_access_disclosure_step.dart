import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/onboarding/domain/sms_disclosure_copy.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

class SmsAccessDisclosureStep extends ConsumerWidget {
  const SmsAccessDisclosureStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Reading your bank messages',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // No Expanded/Spacer here: OnboardingPage hosts every step inside a
          // SingleChildScrollView, so this Column is laid out with unbounded
          // height and a flex child would fail to lay out at all.
          Text(
            kSmsDisclosureBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                // Persist consent first, then ask. The disclosure screen has to
                // be the last thing shown before the system dialog, and
                // RequestSmsPermission refuses outright unless the accepted
                // revision is already recorded. On playManual the gateway
                // reports unavailableInBuild and the use case returns
                // SmsPermissionRequestUnavailable without ever asking.
                final permissions = ref.read(
                  smsPermissionStatusProvider.notifier,
                );
                await ref
                    .read(onboardingStateProvider.notifier)
                    .grantSmsAccess();
                await permissions.request(acceptedDisclosureRevision: 1);
              },
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ref.read(onboardingStateProvider.notifier).skipSmsAccess();
              },
              child: const Text("Not now — I'll paste manually"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
