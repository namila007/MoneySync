import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';

class NotificationPermissionDecisionStep extends ConsumerWidget {
  const NotificationPermissionDecisionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(notificationPermissionStatusProvider);

    void onFinish() {
      ref.read(onboardingStateProvider.notifier).advanceToNextStep();
    }

    return statusAsync.when(
      loading: () => _DecisionContent(
        glyph: '\u25cb',
        label: 'Checking...',
        headline: 'Checking notification status',
        primary: 'Please wait while we check your permission status.',
        showFinish: true,
        onFinish: onFinish,
      ),
      error: (e, _) => _DecisionContent(
        glyph: '\u25cb',
        label: 'Status unavailable',
        headline: 'Notification status unavailable',
        primary:
            'MoneySync still works without notifications. '
            'You can turn notifications on later in Settings \u2192 '
            'Permissions.',
        showFinish: true,
        onFinish: onFinish,
        secondaryLabel: 'Try again',
        onSecondary: () {
          ref.read(notificationPermissionStatusProvider.notifier).refresh();
        },
      ),
      data: (status) {
        switch (status) {
          case NotificationPermissionStatus.granted:
            return _DecisionContent(
              glyph: '\u25cf',
              label: 'On',
              headline: 'Notifications are on',
              primary:
                  'MoneySync can send you alerts about imported transactions '
                  'and import status.',
              showFinish: true,
              onFinish: onFinish,
            );
          case NotificationPermissionStatus.permanentlyDenied:
            return _DecisionContent(
              glyph: '\u2298',
              label: 'Blocked in Settings',
              headline: 'Notifications are off',
              primary:
                  "That\u2019s fine \u2014 MoneySync still works without them. "
                  'You can turn notifications on later in Settings \u2192 '
                  'Permissions.',
              showFinish: true,
              onFinish: onFinish,
              secondaryLabel: 'Open system settings',
              onSecondary: () {
                ref
                    .read(notificationPermissionStatusProvider.notifier)
                    .openSystemSettings();
              },
            );
          default:
            return _DecisionContent(
              glyph: '\u25cb',
              label: 'Off',
              headline: 'Notifications are off',
              primary:
                  "That\u2019s fine \u2014 MoneySync still works without them. "
                  'You can turn notifications on later in Settings \u2192 '
                  'Permissions.',
              showFinish: true,
              onFinish: onFinish,
              secondaryLabel: 'Try again',
              onSecondary: () {
                ref.read(notificationPermissionStatusProvider.notifier).request();
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
