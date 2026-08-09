import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/onboarding/domain/sms_disclosure_copy.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

class SmsAccessPage extends ConsumerWidget {
  const SmsAccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(smsPermissionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Message reading')),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Status unavailable'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  ref.read(smsPermissionStatusProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (status) => _buildContent(context, ref, status),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SmsPermissionStatus status,
  ) {
    final (glyph, label) = switch (status) {
      SmsPermissionStatus.granted => ('\u25cf', 'On'),
      _ => ('\u25cb', 'Off'),
    };
    final statusText = switch (status) {
      SmsPermissionStatus.granted => 'Granted \u00b7 read-only',
      SmsPermissionStatus.permanentlyDenied => 'Blocked in system settings',
      _ => 'Not granted',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (status == SmsPermissionStatus.revoked)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Message reading was turned off outside '
                      'the app. Importing is paused.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ExcludeSemantics(child: Text(glyph)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(label: label, child: Text(label)),
                        Text(statusText),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What this allows',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(kSmsDisclosureBody),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (status == SmsPermissionStatus.notRequested ||
            status == SmsPermissionStatus.denied ||
            status == SmsPermissionStatus.revoked)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(smsPermissionStatusProvider.notifier)
                      .request(acceptedDisclosureRevision: null);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Turn on message reading'),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '(shows the disclosure first)',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        if (status == SmsPermissionStatus.permanentlyDenied)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(smsPermissionStatusProvider.notifier)
                      .openSystemSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open system settings'),
              ),
            ],
          ),
        if (status == SmsPermissionStatus.unavailableInBuild)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'This version imports messages you paste or share. '
                'It cannot read your inbox.',
              ),
            ),
          ),
        if (status == SmsPermissionStatus.granted) ...[
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Import messages\u2026'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Import is not available yet \u2014 available in M4.8.',
            textAlign: TextAlign.center,
          ),
          const Divider(height: 32),
          ListTile(
            title: const Text('Turn off message reading'),
            subtitle: const Text(
              'Opens Android settings. Existing imported data is '
              'not deleted \u2014 use Delete app data for that.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref
                  .read(smsPermissionStatusProvider.notifier)
                  .openSystemSettings();
            },
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
