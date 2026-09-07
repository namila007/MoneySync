import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/features/dashboard/presentation/home_wallet_health.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(homeWalletHealthProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(homeWalletHealthProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(homeWalletHealthProvider);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
        children: [
        // H1 title
        Text('Dashboard', style: AppTypography.display),
        const SizedBox(height: 4),
        Text(
          'Welcome back — your finances are synced.',
          style: AppTypography.body.copyWith(
            color: AppColors.text.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Accent summary banner
        health.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (h) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.accent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYNCHRONIZATION SUMMARY',
                  style: AppTypography.micro.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${h.reviewCount} to review · ${h.succeededCount} synced',
                  style: AppTypography.amount.copyWith(color: AppColors.bg),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Processing Status section
        Text(
          'PROCESSING STATUS',
          style: AppTypography.h6.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: 10),
        health.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const SizedBox.shrink(),
          data: (h) => _ProcessingStatusGrid(health: h),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Latest Wallet Activity section
        Text(
          'LATEST WALLET ACTIVITY',
          style: AppTypography.h6.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: 10),
        health.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (h) => _LatestActivitySection(health: h),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Primary actions
        FilledButton.icon(
          onPressed: () => context.push('/settings/history-import'),
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Scan messages'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go('/inbox'),
          icon: const Icon(Icons.inbox_outlined, size: 18),
          label: const Text('Review inbox'),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Pro tip card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRO TIP',
                style: AppTypography.micro.copyWith(
                  color: AppColors.neutral600,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connect your SMS bank alerts to automatically sync transactions from any financial institution.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}

/// 4-column grid of count cards matching the design prototype's
/// "Processing Status" section.
class _ProcessingStatusGrid extends StatelessWidget {
  const _ProcessingStatusGrid({required this.health});

  final HomeWalletHealth health;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountTile(
            label: 'REVIEW',
            count: health.reviewCount,
            onTap: () => context.go('/inbox'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountTile(
            label: 'RETRY',
            count: health.retryCount,
            onTap: () => context.push('/settings/wallet/retry'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountTile(
            label: 'WAITING',
            count: health.waitingCount,
            onTap: () => context.push('/settings/wallet/waiting'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountTile(
            label: 'SUCCESS',
            count: health.succeededCount,
            onTap: () => context.push('/settings/wallet/succeeded'),
          ),
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.count, this.onTap});

  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $count',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: AppTypography.count),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Latest wallet activity cards matching the design prototype.
class _LatestActivitySection extends StatelessWidget {
  const _LatestActivitySection({required this.health});

  final HomeWalletHealth health;

  @override
  Widget build(BuildContext context) {
    final recentSuccesses = health.recentSuccesses;
    if (recentSuccesses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (final s in recentSuccesses) ...[
          _SuccessCard(
            kind: s.kind,
            counterParty: s.counterParty,
            amountMinor: s.amountMinor,
            currencyCode: s.currencyCode,
            createdAtEpochMs: s.createdAtEpochMs,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.kind,
    required this.counterParty,
    required this.amountMinor,
    required this.currencyCode,
    required this.createdAtEpochMs,
  });

  final String kind;
  final String counterParty;
  final int amountMinor;
  final String currencyCode;
  final int createdAtEpochMs;

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAtEpochMs);
    final timeStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    final titleParts = <String>[];
    if (kind.isNotEmpty) titleParts.add(_capitalize(kind));
    if (counterParty.isNotEmpty) titleParts.add(counterParty);
    final title = titleParts.join(' \u2014 ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h5.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$currencyCode ${_formatAmount(amountMinor)}',
            style: AppTypography.amount.copyWith(
              fontSize: 18,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatAmount(int minorUnits) {
    final abs = minorUnits.abs();
    final majorUnits = abs / 100;
    return majorUnits
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
