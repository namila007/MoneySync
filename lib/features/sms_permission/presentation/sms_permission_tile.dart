import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

class SmsPermissionTile extends ConsumerWidget {
  const SmsPermissionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(smsPermissionStatusProvider);

    return state.when(
      loading: () => const ListTile(
        leading: Icon(Icons.sms_outlined),
        title: Text('Message reading'),
        subtitle: Text('Checking status\u2026'),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Message reading'),
        subtitle: Text(e.toString()),
        trailing: TextButton(
          onPressed: () =>
              ref.read(smsPermissionStatusProvider.notifier).refresh(),
          child: const Text('Retry'),
        ),
      ),
      data: (status) => _StatusTile(status: status),
    );
  }
}

class _StatusTile extends ConsumerWidget {
  const _StatusTile({required this.status});

  final SmsPermissionStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (glyph, label) = status._glyphAndLabel;
    final primaryCopy = status._primaryCopy;
    final action = status._actionLabel;

    return ListTile(
      leading: ExcludeSemantics(
        child: Text(glyph, style: theme.textTheme.headlineSmall),
      ),
      title: const Text('Message reading'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Read-only \u00b7 your inbox is never changed'),
          const SizedBox(height: 4),
          Row(
            children: [
              Semantics(label: label, child: Text(label)),
              const SizedBox(width: 8),
              Text(primaryCopy, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
      trailing: action != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: TextButton(
                onPressed: () => _onAction(context, ref),
                child: Text(action),
              ),
            )
          : null,
    );
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref) {
    switch (status) {
      case SmsPermissionStatus.notRequested:
      case SmsPermissionStatus.denied:
      case SmsPermissionStatus.revoked:
        return ref
            .read(smsPermissionStatusProvider.notifier)
            .request(acceptedDisclosureRevision: null);
      case SmsPermissionStatus.permanentlyDenied:
        return ref
            .read(smsPermissionStatusProvider.notifier)
            .openSystemSettings();
      case SmsPermissionStatus.granted:
      case SmsPermissionStatus.unavailableInBuild:
        return ref
            .read(smsPermissionStatusProvider.notifier)
            .openSystemSettings();
    }
  }
}

extension _StatusDisplay on SmsPermissionStatus {
  (String, String) get _glyphAndLabel => switch (this) {
    SmsPermissionStatus.granted => ('\u25cf', 'On'),
    SmsPermissionStatus.notRequested => ('\u25cb', 'Off'),
    SmsPermissionStatus.denied => ('\u25cb', 'Off'),
    SmsPermissionStatus.permanentlyDenied => ('\u2298', 'Blocked in Settings'),
    SmsPermissionStatus.revoked => ('\u26a0', 'Removed'),
    SmsPermissionStatus.unavailableInBuild => ('\u2013', 'Not in this build'),
  };

  String get _primaryCopy => switch (this) {
    SmsPermissionStatus.unavailableInBuild =>
      'This version of the app cannot read SMS.',
    SmsPermissionStatus.notRequested => 'Message reading is off.',
    SmsPermissionStatus.granted => 'Message reading is on. Read-only.',
    SmsPermissionStatus.denied => 'Permission not granted.',
    SmsPermissionStatus.permanentlyDenied =>
      'Permission blocked in system settings.',
    SmsPermissionStatus.revoked =>
      'Permission was removed. Importing is paused.',
  };

  String? get _actionLabel => switch (this) {
    SmsPermissionStatus.unavailableInBuild => null,
    SmsPermissionStatus.notRequested ||
    SmsPermissionStatus.denied ||
    SmsPermissionStatus.revoked => 'Request',
    SmsPermissionStatus.granted => 'Manage',
    SmsPermissionStatus.permanentlyDenied => 'Open settings',
  };
}
