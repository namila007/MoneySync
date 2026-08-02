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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ConfigurationSummary(flavor: config.flavor),
          const SizedBox(height: 16),
          _ConfigurationSection(
            title: 'Security & Privacy',
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('App lock & biometric'),
                subtitle: const Text('Device protection configuration'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoute.securityPrivacy.path),
              ),
              ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: const Text('Show onboarding'),
                subtitle: const Text('Re-view the introduction flow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoute.onboardingReview.path),
              ),
              const _ReadOnlySettingTile(
                title: 'Secure window protection',
                value: 'Always on',
                explanation: 'Financial screens are protected.',
                icon: Icons.visibility_off_outlined,
              ),
            ],
          ),
          const _ConfigurationSection(
            title: 'SMS & Tracking',
            children: [
              _GatedSettingTile(
                key: ValueKey('settings-history-window'),
                title: 'SMS history window',
                explanation: 'Available in M4: SMS import remains disabled.',
                icon: Icons.sms_outlined,
              ),
              _GatedSettingTile(
                title: 'Incoming tracking',
                explanation: 'Available in M6: tracking remains disabled.',
                icon: Icons.notifications_off_outlined,
              ),
            ],
          ),
          _ConfigurationSection(
            title: 'Wallet',
            children: [
              ListTile(
                key: const ValueKey('open-wallet-connection'),
                minVerticalPadding: 12,
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Wallet connection'),
                subtitle: const Text('Open the dedicated connection screen.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoute.walletConnection.path),
              ),
              const _ReadOnlySettingTile(
                title: 'Processing default',
                value: 'Review',
                explanation: 'Review is the current safe default.',
                icon: Icons.rate_review_outlined,
              ),
            ],
          ),
          _ConfigurationSection(
            title: 'Data & Diagnostics',
            children: [
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Data Control'),
                subtitle: const Text('Clear activity or reset local data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoute.dataControl.path),
              ),
              for (final capability in AppCapability.values)
                _CapabilityTile(
                  capability: capability,
                  enabled: capabilities.isEnabled(capability),
                  explanation: capabilities.explanationFor(capability),
                ),
            ],
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
      leading: const Icon(Icons.info_outline),
      title: const Text('Build configuration'),
      subtitle: Text('$flavorName · configuration hub'),
    );
  }
}

class _ConfigurationSection extends StatelessWidget {
  const _ConfigurationSection({required this.title, required this.children});

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

class _GatedSettingTile extends StatelessWidget {
  const _GatedSettingTile({
    super.key,
    required this.title,
    required this.explanation,
    required this.icon,
  });

  final String title;
  final String explanation;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title unavailable. $explanation',
      child: ListTile(
        enabled: false,
        minVerticalPadding: 12,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(explanation),
        trailing: const Text('Unavailable'),
      ),
    );
  }
}

class _ReadOnlySettingTile extends StatelessWidget {
  const _ReadOnlySettingTile({
    required this.title,
    required this.value,
    required this.explanation,
    required this.icon,
  });

  final String title;
  final String value;
  final String explanation;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 12,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(explanation),
      trailing: Text(value),
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
      enabled: false,
      minVerticalPadding: 12,
      leading: Icon(enabled ? Icons.check_circle_outline : Icons.lock_outline),
      title: Text(_labelFor(capability)),
      subtitle: Text(explanation),
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
