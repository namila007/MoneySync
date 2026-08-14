import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/bootstrap/production_providers.dart';

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
