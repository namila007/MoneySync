import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/dashboard/presentation/home_wallet_health.dart';

final homeSummaryProvider = FutureProvider<({int imported, int candidates})>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final events = await db.select(db.smsEvents).get();
  final candidates = await db.select(db.transactionCandidates).get();
  return (imported: events.length, candidates: candidates.length);
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final health = ref.watch(homeWalletHealthProvider);

    return ListView(
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
        summary.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (counts) => Container(
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
                  '${counts.candidates} to review · ${counts.imported} synced',
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
          style: AppTypography.h6.copyWith(
            color: AppColors.text,
          ),
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
          style: AppTypography.h6.copyWith(
            color: AppColors.text,
          ),
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
  const _CountTile({
    required this.label,
    required this.count,
    this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: AppColors.surface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: AppTypography.count,
            ),
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
    );
  }
}

/// Latest wallet activity cards matching the design prototype.
class _LatestActivitySection extends StatelessWidget {
  const _LatestActivitySection({required this.health});

  final HomeWalletHealth health;

  @override
  Widget build(BuildContext context) {
    final latest = health.latestRecord;
    if (latest == null) {
      return const SizedBox.shrink();
    }

    final dt = DateTime.fromMillisecondsSinceEpoch(latest.createdAtEpochMs);
    final timeStr =
        '${_dayLabel(dt)}, ${_hour(dt)}:${_min(dt)}';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet transaction',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: AppTypography.bodyXs.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${latest.currencyCode} ${_formatAmount(latest.amountMinor)}',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(int minorUnits) {
    final sign = minorUnits < 0 ? '-' : '';
    final abs = minorUnits.abs();
    final whole = abs ~/ 100;
    final fraction = (abs % 100).toString().padLeft(2, '0');
    return '$sign${_thousands(whole)}.$fraction';
  }

  String _thousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _hour(DateTime dt) =>
      dt.hour.toString().padLeft(2, '0');

  String _min(DateTime dt) =>
      dt.minute.toString().padLeft(2, '0');
}
