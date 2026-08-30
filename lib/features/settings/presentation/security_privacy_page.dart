import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';

final configurationProvider = FutureProvider<ConfigurationState?>((ref) async {
  try {
    final repo = ref.watch(configurationRepositoryProvider).requireValue;
    return await repo.load();
  } catch (_) {
    return null;
  }
});

class SecurityPrivacyPage extends ConsumerWidget {
  const SecurityPrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configurationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Security & Privacy')),
      body: configAsync.when(
        data: (config) {
          if (config == null) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'App settings are not available yet. Complete setup first.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const _SecureStatusTile(),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AppLockSection(config: config),
              const Divider(),
              _RetentionSection(config: config),
              const Divider(),
              const _SecureStatusTile(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load settings')),
      ),
    );
  }
}

class _AppLockSection extends ConsumerWidget {
  const _AppLockSection({required this.config});
  final ConfigurationState config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('App lock'),
          subtitle: Text(
            config.appLock.enabled
                ? 'Lock after ${config.appLock.inactivityTimeoutSeconds}s'
                : 'Device authentication is off',
          ),
          value: config.appLock.enabled,
          onChanged: (value) async {
            if (value) {
              final auth = ref.read(freshAuthPortProvider).asData?.value;
              if (auth == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Device authentication is not available.'),
                  ),
                );
                return;
              }
              final outcome = await auth.authenticate(
                purpose: 'Enable app lock',
              );
              if (outcome != DeviceAuthOutcome.authenticated) {
                return;
              }
            } else {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Turn off app lock?'),
                  content: const Text(
                    'Database encryption and secure-window protection '
                    'will remain active even with app lock off.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Turn off'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
            }
            final repo = ref.read(configurationRepositoryProvider).requireValue;
            await repo.updateAppLock(
              AppLockPreferences(
                enabled: value,
                inactivityTimeoutSeconds:
                    config.appLock.inactivityTimeoutSeconds,
              ),
            );
            updateAppLockRequired(value);
            ref.invalidate(configurationProvider);
          },
        ),
        ListTile(
          title: const Text('Lock after'),
          trailing: DropdownButton<int>(
            value: config.appLock.inactivityTimeoutSeconds,
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 s')),
              DropdownMenuItem(value: 30, child: Text('30 s')),
              DropdownMenuItem(value: 60, child: Text('1 min')),
              DropdownMenuItem(value: 300, child: Text('5 min')),
            ],
            onChanged: (value) async {
              if (value == null) return;
              final repo = ref
                  .read(configurationRepositoryProvider)
                  .requireValue;
              await repo.updateAppLock(
                AppLockPreferences(
                  enabled: config.appLock.enabled,
                  inactivityTimeoutSeconds: value,
                ),
              );
              ref.invalidate(configurationProvider);
            },
          ),
        ),
      ],
    );
  }
}

class _RetentionSection extends ConsumerWidget {
  const _RetentionSection({required this.config});
  final ConfigurationState config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Local copy retention',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          title: const Text('Raw app copy'),
          subtitle: Text(
            config.retention.rawCopyDays > 0
                ? 'Keep for ${config.retention.rawCopyDays} days'
                : 'Purge after processing',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showRawCopyRetentionDialog(context, config, ref),
        ),
        ListTile(
          title: const Text('Activity history'),
          subtitle: Text('${config.retention.activityRetentionDays} days'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showActivityRetentionDialog(context, config, ref),
        ),
      ],
    );
  }
}

class _SecureStatusTile extends StatelessWidget {
  const _SecureStatusTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.visibility_off_outlined),
      title: const Text('Secure screen'),
      subtitle: const Text(
        'Prevents screenshots and recording on financial routes. '
        'Always enabled. Cannot be turned off.',
      ),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }
}

void _showRawCopyRetentionDialog(
  BuildContext context,
  ConfigurationState config,
  WidgetRef ref,
) {
  var selected = config.retention.rawCopyDays;
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Raw app copy retention'),
        content: RadioGroup<int>(
          groupValue: selected,
          onChanged: (v) {
            if (v == null) return;
            setState(() => selected = v);
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: Text('Purge after processing'),
                value: 0,
              ),
              RadioListTile<int>(title: Text('7 days'), value: 7),
              RadioListTile<int>(title: Text('14 days'), value: 14),
              RadioListTile<int>(title: Text('30 days'), value: 30),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref
                  .read(configurationRepositoryProvider)
                  .requireValue;
              await repo.updateRetention(
                RetentionPreferences(
                  rawCopyDays: selected,
                  activityRetentionDays: config.retention.activityRetentionDays,
                ),
              );
              ref.invalidate(configurationProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
}

void _showActivityRetentionDialog(
  BuildContext context,
  ConfigurationState config,
  WidgetRef ref,
) {
  var selected = config.retention.activityRetentionDays;
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Activity retention'),
        content: RadioGroup<int>(
          groupValue: selected,
          onChanged: (v) {
            if (v == null) return;
            setState(() => selected = v);
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(title: Text('90 days'), value: 90),
              RadioListTile<int>(title: Text('180 days'), value: 180),
              RadioListTile<int>(title: Text('365 days'), value: 365),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref
                  .read(configurationRepositoryProvider)
                  .requireValue;
              await repo.updateRetention(
                RetentionPreferences(
                  rawCopyDays: config.retention.rawCopyDays,
                  activityRetentionDays: selected,
                ),
              );
              ref.invalidate(configurationProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
}
