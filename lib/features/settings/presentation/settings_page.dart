import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final configStateAsync = ref.watch(_configurationStateProvider);
    final screenshotProtected =
        configStateAsync.value?.secureWindowEnabled ?? true;
    final autoImportEnabled =
        configStateAsync.value?.autoImportEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // System Environment
          _SystemEnvironmentCard(flavor: config.flavor),
          const SizedBox(height: AppSpacing.s6),

          // SECURITY & PRIVACY
          Text('SECURITY & PRIVACY', style: AppTypography.h6),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'App lock',
                subtitle: 'Secure with biometrics/PIN',
                onTap: () => context.push(AppRoute.securityPrivacy.path),
              ),
              _SettingsTile(
                icon: Icons.smartphone_outlined,
                title: 'Screenshot protection',
                subtitle: 'Prevent screenshots of sensitive data',
                trailing: Switch(
                  value: screenshotProtected,
                  onChanged: (value) => _toggleScreenshot(ref, value),
                  activeThumbColor: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),

          // SMS & TRACKING
          Text('SMS & TRACKING', style: AppTypography.h6),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.chat_bubble_outline,
                title: 'Message reading',
                subtitle: 'Configure SMS permissions',
                onTap: () => context.push('/settings/permissions'),
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'History Import',
                subtitle: 'Import range settings',
                onTap: () => context.push('/settings/history-import'),
              ),
              _SettingsTile(
                icon: Icons.people_outline,
                title: 'Tracked senders',
                subtitle: 'Manage bank IDs',
                onTap: () => context.push('/settings/tracked-senders'),
              ),
              if (config.flavor == AppFlavor.privateFull)
                _SettingsTile(
                  icon: Icons.campaign_outlined,
                  title: 'Auto-import',
                  subtitle: autoImportEnabled ? 'On' : 'Off',
                  onTap: () => context.push('/settings/auto-import'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),

          // WALLET
          Text('WALLET', style: AppTypography.h6),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet connection',
                subtitle: 'Connect to your Wallet API',
                onTap: () => context.push(AppRoute.walletConnection.path),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),

          // DATA & DIAGNOSTICS
          Text('DATA & DIAGNOSTICS', style: AppTypography.h6),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.cleaning_services_outlined,
                title: 'Data control',
                subtitle: 'Export or delete local cache',
                onTap: () => context.push(AppRoute.dataControl.path),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),

          // Divider
          Container(
            height: 2,
            color: AppColors.divider(Theme.of(context).brightness),
          ),
          const SizedBox(height: AppSpacing.s6),

          // Version info
          Center(
            child: Text(
              'version 2.4.1 (stable) \u00b7 engine v1.8',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleScreenshot(WidgetRef ref, bool enabled) async {
    final repo = await ref.read(configurationRepositoryProvider.future);
    await repo.updateSecureWindowEnabled(enabled);
    ref.invalidate(_configurationStateProvider);
  }
}

final _configurationStateProvider = FutureProvider<ConfigurationState>((ref) {
  return ref
      .watch(configurationRepositoryProvider.future)
      .then((repo) => repo.load());
});

class _SystemEnvironmentCard extends StatelessWidget {
  const _SystemEnvironmentCard({required this.flavor});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    final flavorName = switch (flavor) {
      AppFlavor.privateFull => 'privateFull',
      AppFlavor.playManual => 'playManual',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM ENVIRONMENT',
                style: AppTypography.micro.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Build: $flavorName',
                style: AppTypography.h5,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.divider(Theme.of(context).brightness),
                width: 2,
              ),
            ),
            child: Text(
              flavorName,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider(Theme.of(context).brightness),
                indent: 52,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.neutral700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.neutral400,
              ),
          ],
        ),
      ),
    );
  }
}
