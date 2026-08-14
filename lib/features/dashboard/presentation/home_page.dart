import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [const SettingsAppBarAction()],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Your local review workspace is ready.')),
        data: (counts) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local messages',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${counts.imported} imported · ${counts.candidates} candidates',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            health.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
              data: (h) => _WalletHealthCards(health: h),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/settings/history-import'),
              icon: const Icon(Icons.sms_outlined),
              label: const Text('Scan messages'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.go('/inbox'),
              icon: const Icon(Icons.inbox_outlined),
              label: const Text('Review inbox'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "3 Review / 1 Retry / 2 Waiting" counters plus the latest created
/// record card (plan/04 §Home; M5.11). Pure read-only projection.
class _WalletHealthCards extends StatelessWidget {
  const _WalletHealthCards({required this.health});

  final HomeWalletHealth health;

  @override
  Widget build(BuildContext context) {
    final hasAny =
        health.reviewCount > 0 ||
        health.retryCount > 0 ||
        health.waitingCount > 0 ||
        health.latestRecord != null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CountTile(
                label: 'Review',
                count: health.reviewCount,
                icon: Icons.rate_review_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CountTile(
                label: 'Retry',
                count: health.retryCount,
                icon: Icons.refresh,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CountTile(
                label: 'Waiting',
                count: health.waitingCount,
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        if (health.latestRecord case final record?) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text('Latest Wallet transaction'),
              subtitle: Text(
                '${record.currencyCode} ${_formatAmount(record.amountMinor)} '
                '· ${_formatTime(record.createdAtEpochMs)}',
              ),
              trailing: const Text('Created'),
            ),
          ),
        ] else if (hasAny)
          const SizedBox.shrink()
        else
          Card(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No Wallet activity yet. Review a message to create your first record.',
              ),
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
    return '$sign$whole.$fraction';
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text('$count', style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
