import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/core/security/device_authenticator.dart';
import 'package:money_sync/core/security/native_security_channel.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/presentation/configuration_providers.dart';

class SecurityPrivacyPage extends ConsumerWidget {
  const SecurityPrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(configurationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('App Security')),
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
              _ScreenshotProtectionSection(config: config),
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
              try {
                final auth = await ref.read(freshAuthPortProvider.future);
                final outcome = await auth.authenticate(
                  purpose: 'Enable app lock',
                );
                if (outcome != DeviceAuthOutcome.authenticated) {
                  return;
                }
              } on Object {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Device authentication is not available.'),
                    ),
                  );
                }
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
            final repo = await ref.read(configurationRepositoryProvider.future);
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
              final repo = await ref.read(
                configurationRepositoryProvider.future,
              );
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

class _ScreenshotProtectionSection extends ConsumerWidget {
  const _ScreenshotProtectionSection({required this.config});
  final ConfigurationState config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      secondary: const Icon(Icons.screenshot_monitor_outlined),
      title: const Text('Screenshot protection'),
      subtitle: const Text(
        'Blocks screenshots and screen recording of the app.',
      ),
      value: config.secureWindowEnabled,
      onChanged: (enabled) => _toggleSecureWindow(ref, enabled),
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

Future<void> _toggleSecureWindow(WidgetRef ref, bool enabled) async {
  final repo = await ref.read(configurationRepositoryProvider.future);
  await repo.updateSecureWindowEnabled(enabled);
  ref.invalidate(configurationProvider);
  try {
    await const NativeSecurityChannel().setSecureWindowProtection(
      enabled: enabled,
    );
  } catch (e, s) {
    Logger('security').error('setSecureWindowProtection failed', e, s);
  }
}
