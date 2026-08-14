import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';

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
              return _MappingRuleTile(rule: rule);
            },
          );
        },
      ),
    );
  }
}

class _MappingRuleTile extends StatelessWidget {
  const _MappingRuleTile({required this.rule});

  final MappingRule rule;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (rule.senderMatcher.aliases.isNotEmpty) rule.senderMatcher.aliases.join(', '),
      if (rule.instrumentSuffixHash != null)
        '••${rule.instrumentSuffixHash!.length > 4 ? rule.instrumentSuffixHash!.substring(rule.instrumentSuffixHash!.length - 4) : rule.instrumentSuffixHash}',
      rule.syncMode.name,
    ];

    return Card(
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
