import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

final _log = Logger('mappings.list');

class MappingsPage extends ConsumerWidget {
  const MappingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(mappingRuleListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'New mapping',
        onPressed: () => context.push('/mappings/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mappings', style: AppTypography.display),
                const SizedBox(height: 4),
                Text(
                  'Auto-categorization rules',
                  style: AppTypography.body.copyWith(
                    color: AppColors.text.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: rulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _MessageCard(
                'Could not load mapping rules.',
                child: Text('$error'),
              ),
              data: (rules) {
                if (rules.isEmpty) {
                  return const _MessageCard(
                    'No mapping rules yet. Tap + to create one.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return _MappingRuleTile(
                      rule: rule,
                      onDelete: () => ref.invalidate(mappingRuleListProvider),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MappingRuleTile extends ConsumerWidget {
  const _MappingRuleTile({required this.rule, required this.onDelete});

  final MappingRule rule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(walletCatalogProvider).value;
    final accountName = _resolveAccountName(catalog, rule.walletAccountId);
    final senderLabel = rule.senderMatcher.aliases.isNotEmpty
        ? rule.senderMatcher.aliases.first
        : rule.name;
    final syncLabel = switch (rule.syncMode) {
      MappingSyncMode.automatic => 'Automatic',
      MappingSyncMode.review => 'Review',
      MappingSyncMode.manual => 'Manual',
      MappingSyncMode.inherit => 'Inherit',
    };

    return Dismissible(
      key: ValueKey(rule.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: AppColors.accent100,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(Icons.edit_outlined, color: AppColors.accent),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          context.push('/mappings/${rule.id}/edit');
          return false;
        }
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete mapping rule?'),
            content: Text(
              'The rule "$senderLabel \u2192 $accountName" will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true) return false;
        try {
          final useCase = await ref.read(deleteMappingRuleProvider.future);
          await useCase(ruleId: rule.id);
          _log.info('Deleted mapping rule ${rule.id}');
          onDelete();
          return true;
        } catch (e, s) {
          _log.error('Failed to delete mapping rule ${rule.id}', e, s);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not delete mapping rule.')),
            );
          }
          return false;
        }
      },
      onDismissed: (_) {},
      child: Card(
        child: ListTile(
          onTap: () =>
              _showDetailSheet(context, rule, senderLabel, accountName),
          title: Text(
            '$senderLabel \u2192 $accountName',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(syncLabel),
          trailing: !rule.enabled ? const _DisabledChip() : null,
        ),
      ),
    );
  }

  void _showDetailSheet(
    BuildContext context,
    MappingRule rule,
    String senderLabel,
    String accountName,
  ) {
    final syncLabel = switch (rule.syncMode) {
      MappingSyncMode.automatic => 'Automatic',
      MappingSyncMode.review => 'Review',
      MappingSyncMode.manual => 'Manual',
      MappingSyncMode.inherit => 'Inherit',
    };
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$senderLabel \u2192 $accountName', style: AppTypography.h5),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Senders',
              value: rule.senderMatcher.aliases.join(', '),
            ),
            _DetailRow(label: 'Account', value: accountName),
            _DetailRow(label: 'Payment type', value: rule.paymentType),
            _DetailRow(label: 'Processing', value: syncLabel),
            _DetailRow(
              label: 'Status',
              value: rule.enabled ? 'Enabled' : 'Disabled',
            ),
            if (rule.merchantMatcher != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Merchant matcher',
                value: rule.merchantMatcher is ExactMerchantMatcher
                    ? 'Exact: ${(rule.merchantMatcher as ExactMerchantMatcher).merchant}'
                    : 'Contains: ${(rule.merchantMatcher as ContainsMerchantMatcher).fragment}',
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/mappings/${rule.id}/edit');
                },
                child: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _resolveAccountName(WalletCatalog? catalog, String accountId) {
    if (catalog == null) return accountId;
    for (final a in catalog.accounts) {
      if (a.id == accountId) return a.name;
    }
    return accountId;
  }
}

class _DisabledChip extends StatelessWidget {
  const _DisabledChip();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: const BoxDecoration(color: AppColors.neutral100),
    child: Text('Disabled', style: AppTypography.micro),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard(this.message, {this.child});

  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              if (child != null) ...[const SizedBox(height: 8), child!],
            ],
          ),
        ),
      ),
    ),
  );
}
