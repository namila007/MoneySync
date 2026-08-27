import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

class PermissionsPage extends ConsumerWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smsStatusAsync = ref.watch(smsPermissionStatusProvider);
    final notificationStatusAsync = ref.watch(
      notificationPermissionStatusProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _Section(
            title: 'Permissions',
            children: [
              smsStatusAsync.when(
                loading: () => const ListTile(
                  leading: Icon(Icons.sms_outlined),
                  title: Text('Message reading'),
                  subtitle: Text('Checking\u2026'),
                ),
                error: (e, _) => ListTile(
                  leading: const Icon(Icons.sms_outlined),
                  title: const Text('Message reading'),
                  subtitle: const Text('Status unavailable'),
                ),
                data: (status) {
                  final (label, symbol) = switch (status) {
                    SmsPermissionStatus.granted => ('\u25cf  On', '\u25cf'),
                    _ => ('\u25cb  Off', '\u25cb'),
                  };
                  return ListTile(
                    leading: ExcludeSemantics(child: Text(symbol)),
                    title: const Text('Message reading'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                    onTap: () => context.push('/settings/message-reading'),
                  );
                },
              ),
              notificationStatusAsync.when(
                loading: () => const ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  subtitle: Text('Checking\u2026'),
                ),
                error: (e, _) => ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Status unavailable'),
                ),
                data: (status) {
                  final (label, symbol) = switch (status) {
                    NotificationPermissionStatus.granted => (
                      '\u25cf  On',
                      '\u25cf',
                    ),
                    _ => ('\u25cb  Off', '\u25cb'),
                  };
                  return ListTile(
                    leading: ExcludeSemantics(child: Text(symbol)),
                    title: const Text('Notifications'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                    onTap: () =>
                        context.push('/settings/notification-permission'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
