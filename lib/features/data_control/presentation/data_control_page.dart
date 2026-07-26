import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataControlPage extends ConsumerWidget {
  const DataControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Clear activity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const ListTile(
                    subtitle: Text(
                      'Removes local activity and traces. '
                      'Keeps settings, keys, and cached data.',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmClearActivity(context),
                      icon: const Icon(Icons.cleaning_services_outlined),
                      label: const Text('Clear activity...'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Reset MoneySync',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const ListTile(
                    subtitle: Text(
                      'Deletes app data, token, caches, mappings, '
                      'and local copies. Does not delete inbox SMS or '
                      'remote Wallet records.',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FilledButton.tonalIcon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Reset local data...'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearActivity(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear activity?'),
        content: const Text(
          'Removes local activity and decision traces from this device. '
          'Keeps settings, onboarding, mappings, security keys, and '
          'cached metadata. Inbox SMS and Wallet records are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear activity'),
          ),
        ],
      ),
    );
  }
}
