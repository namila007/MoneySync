import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/core/capabilities/app_capabilities.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

/// The Settings root. The former Configuration hub was flattened into this
/// page (M4.15 WP5): SMS & tracking controls moved up, duplicated sections
/// were dropped, and the hub page and route no longer exist.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final capabilities = ref.watch(appCapabilitiesProvider);
    final smsStatusAsync = ref.watch(smsPermissionStatusProvider);
    final secureWindowAsync = ref.watch(_configurationStateProvider);
    final secureWindowEnabled =
        secureWindowAsync.value?.secureWindowEnabled ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Settings is a top-level route (no auto back arrow); it is only
        // reachable from inside the app, so the back arrow is always valid.
        leading: BackButton(onPressed: () => context.go('/')),
      ),
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
              SwitchListTile(
                secondary: const Icon(Icons.screenshot_monitor_outlined),
                title: const Text('Screenshot protection'),
                subtitle: const Text(
                  'Blocks screenshots and screen recording of the app.',
                ),
                value: secureWindowEnabled,
                onChanged: (enabled) => _toggleSecureWindow(ref, enabled),
              ),
            ],
          ),
          _ConfigurationSection(
            title: 'SMS & Tracking',
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
                    onTap: () => context.push('/settings/message-reading'),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History window'),
                subtitle: const Text('How far back to scan messages'),
                trailing: const Text('7 days'),
                onTap: () => context.push('/settings/history-import'),
              ),
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: const Text('Tracked senders'),
                subtitle: const Text('Senders included in imports'),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () => context.push('/settings/tracked-senders'),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Scan maximum'),
                subtitle: const Text('Messages scanned per import'),
                trailing: const Text('100'),
                onTap: () => context.push('/settings/history-import'),
              ),
              const _ReadOnlySettingTile(
                title: 'Incoming tracking',
                value: 'Not yet — M6',
                explanation: 'Automatic live tracking arrives with M6.',
                icon: Icons.campaign_outlined,
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

final _configurationStateProvider = FutureProvider<ConfigurationState>((ref) {
  return ref
      .watch(configurationRepositoryProvider.future)
      .then((repo) => repo.load());
});

Future<void> _toggleSecureWindow(WidgetRef ref, bool enabled) async {
  final repo = await ref.read(configurationRepositoryProvider.future);
  await repo.updateSecureWindowEnabled(enabled);
  ref.invalidate(_configurationStateProvider);
  try {
    await const NativeSecurityChannel().setSecureWindowProtection(
      enabled: enabled,
    );
  } catch (_) {
    // Non-fatal: the preference is persisted; the native call is best-effort
    // (e.g. unavailable before the engine fully wires the channel).
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
      subtitle: Text(flavorName),
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
