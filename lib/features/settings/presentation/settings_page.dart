import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final capabilities = ref.watch(appCapabilitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _ConfigurationSummary(flavor: config.flavor),
          ListTile(
            key: const ValueKey('open-wallet-connection'),
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Wallet connection'),
            subtitle: const Text(
              'Token and Wallet account connection settings',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoute.walletConnection.path),
          ),
          const Divider(),
          for (final capability in AppCapability.values)
            _CapabilityTile(
              capability: capability,
              enabled: capabilities.isEnabled(capability),
              explanation: capabilities.explanationFor(capability),
            ),
        ],
      ),
    );
  }
}

class _ConfigurationSummary extends StatelessWidget {
  const _ConfigurationSummary({required this.flavor});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    final flavorName = switch (flavor) {
      AppFlavor.privateFull => 'Private full',
      AppFlavor.playManual => 'Play manual',
    };

    return ListTile(
      title: const Text('Build configuration'),
      subtitle: Text(flavorName),
      leading: const Icon(Icons.info_outline),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  const _CapabilityTile({
    required this.capability,
    required this.enabled,
    required this.explanation,
  });

  final AppCapability capability;
  final bool enabled;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_labelFor(capability)),
      subtitle: Text(explanation),
      leading: Icon(
        enabled ? Icons.check_circle_outline : Icons.lock_outline,
        color: enabled ? Theme.of(context).colorScheme.primary : null,
      ),
      trailing: Text(enabled ? 'Enabled' : 'Disabled'),
    );
  }

  String _labelFor(AppCapability capability) => switch (capability) {
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
