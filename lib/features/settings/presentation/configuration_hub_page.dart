import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

class ConfigurationHubPage extends ConsumerWidget {
  const ConfigurationHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(appCapabilitiesProvider);
    final config = ref.watch(appConfigProvider);
    final smsStatusAsync = ref.watch(smsPermissionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HubSection(
            title: 'SECURITY & PRIVACY',
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('App lock'),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () => context.push('/settings/security'),
              ),
              const _ReadOnlyTile(
                title: 'Screenshot protection',
                value: 'Always on',
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Activity history'),
                trailing: const Icon(Icons.chevron_right, size: 16),
                // go, not push: /activity lives inside the ShellRoute, and
                // pushing a shell-owned route from outside the shell throws.
                onTap: () => context.go('/activity'),
              ),
            ],
          ),
          _HubSection(
            title: 'SMS & TRACKING',
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
                  subtitle: Text('Status unavailable'),
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
                    onTap: () =>
                        context.push('/settings/configuration/message-reading'),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History window'),
                trailing: const Text('7 days'),
                onTap: () =>
                    context.push('/settings/configuration/history-import'),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Scan maximum'),
                trailing: const Text('100'),
                onTap: () =>
                    context.push('/settings/configuration/history-import'),
              ),
              const _ReadOnlyTile(
                title: 'Incoming tracking',
                value: 'Not yet \u2014 M6',
              ),
            ],
          ),
          _CapabilitiesSection(capabilities: capabilities),
          _HubSection(
            title: 'DATA & DIAGNOSTICS',
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete app data'),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () => context.push('/settings/data'),
              ),
              _ReadOnlyTile(
                title: 'Build',
                value: config.flavor == AppFlavor.privateFull
                    ? 'privateFull'
                    : 'playManual',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubSection extends StatelessWidget {
  const _HubSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ReadOnlyTile extends StatelessWidget {
  const _ReadOnlyTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), trailing: Text(value));
  }
}

class _CapabilitiesSection extends StatelessWidget {
  const _CapabilitiesSection({required this.capabilities});
  final AppCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    return _HubSection(
      title: 'CAPABILITIES',
      children: [
        for (final capability in AppCapability.values)
          ListTile(
            enabled: false,
            leading: Icon(
              capabilities.isEnabled(capability)
                  ? Icons.check_circle_outline
                  : Icons.lock_outline,
            ),
            title: Text(_label(capability)),
            subtitle: Text(capabilities.explanationFor(capability)),
            trailing: Text(
              capabilities.isEnabled(capability) ? 'Enabled' : 'Disabled',
            ),
          ),
      ],
    );
  }

  String _label(AppCapability c) => switch (c) {
    AppCapability.smsPermission => 'SMS permission',
    AppCapability.walletCreate => 'Wallet creation',
    AppCapability.walletPatch => 'Wallet updates',
    AppCapability.walletDelete => 'Wallet deletion',
    AppCapability.historySms => 'SMS history',
    AppCapability.liveSms => 'Live SMS',
    AppCapability.mlKitEntities => 'ML entities',
    AppCapability.localLearning => 'Local learning',
    AppCapability.internalTransfer => 'Internal transfers',
    AppCapability.outsideTransfer => 'Outside transfers',
    AppCapability.automaticSync => 'Automatic sync',
    AppCapability.settingsExport => 'Settings export',
    AppCapability.modelTransfer => 'Model transfer',
  };
}
