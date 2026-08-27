import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';

class NotificationPermissionPage extends ConsumerWidget {
  const NotificationPermissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(notificationPermissionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
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
                  ref
                      .read(notificationPermissionStatusProvider.notifier)
                      .refresh();
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
    NotificationPermissionStatus status,
  ) {
    final (glyph, label) = switch (status) {
      NotificationPermissionStatus.granted => ('\u25cf', 'On'),
      _ => ('\u25cb', 'Off'),
    };
    final statusText = switch (status) {
      NotificationPermissionStatus.granted => 'Granted',
      NotificationPermissionStatus.permanentlyDenied =>
        'Blocked in system settings',
      _ => 'Not granted',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
        if (status == NotificationPermissionStatus.notRequested ||
            status == NotificationPermissionStatus.denied)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(notificationPermissionStatusProvider.notifier)
                      .request();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Turn on notifications'),
              ),
            ],
          ),
        if (status == NotificationPermissionStatus.permanentlyDenied)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(notificationPermissionStatusProvider.notifier)
                      .openSystemSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open system settings'),
              ),
            ],
          ),
        if (status == NotificationPermissionStatus.granted) ...[
          const Divider(height: 32),
          ListTile(
            title: const Text('Turn off notifications'),
            subtitle: const Text('Opens Android notification settings.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref
                  .read(notificationPermissionStatusProvider.notifier)
                  .openSystemSettings();
            },
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
