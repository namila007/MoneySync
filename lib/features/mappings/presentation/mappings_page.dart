import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';

final log = Logger('mappings.list');

class MappingsPage extends ConsumerWidget {
  const MappingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(mappingRuleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappings'),
        actions: const [SettingsAppBarAction()],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New mapping',
        onPressed: () => context.push('/mappings/new'),
        child: const Icon(Icons.add),
      ),
      body: rulesAsync.when(
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
    );
  }
}

class _MappingRuleTile extends ConsumerWidget {
  const _MappingRuleTile({required this.rule, required this.onDelete});

  final MappingRule rule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = <String>[
      if (rule.senderMatcher.aliases.isNotEmpty)
        rule.senderMatcher.aliases.join(', '),
      if (rule.instrumentSuffixHash != null)
        '••${rule.instrumentSuffixHash!.length > 4 ? rule.instrumentSuffixHash!.substring(rule.instrumentSuffixHash!.length - 4) : rule.instrumentSuffixHash}',
      rule.syncMode.name,
    ];

    return Dismissible(
      key: ValueKey(rule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete mapping rule?'),
            content: Text(
              'The rule "${rule.name}" will be permanently deleted.',
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
        return confirmed ?? false;
      },
      onDismissed: (_) async {
        try {
          final useCase = await ref.read(deleteMappingRuleProvider.future);
          await useCase(ruleId: rule.id);
          log.info('Deleted mapping rule ${rule.id}');
          onDelete();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mapping rule "${rule.name}" deleted.')),
            );
          }
        } catch (e, s) {
          log.error('Failed to delete mapping rule ${rule.id}', e, s);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not delete mapping rule.')),
            );
          }
        }
      },
      child: Card(
        child: ListTile(
          onTap: () => context.push('/mappings/${rule.id}/edit'),
          title: Text(rule.name),
          subtitle: Text(subtitleParts.join(' · ')),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!rule.enabled) const _DisabledChip(),
              IconButton(
                tooltip: 'Edit mapping',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/mappings/${rule.id}/edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisabledChip extends StatelessWidget {
  const _DisabledChip();

  @override
  Widget build(BuildContext context) => Chip(
    label: const Text('Disabled'),
    visualDensity: VisualDensity.compact,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
  );
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
