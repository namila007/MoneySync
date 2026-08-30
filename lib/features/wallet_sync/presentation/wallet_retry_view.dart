import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/data/drift_activity_recovery_actions.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/mutation_state_label.dart';

/// Mutations in retryScheduled state, for the retry view.
/// StreamProvider watching wallet_mutations directly, mirroring
/// homeWalletHealthProvider's pattern — refreshes live without manual
/// invalidation.
final retryMutationsProvider = StreamProvider.autoDispose<List<WalletMutation>>(
  (ref) async* {
    final db = await ref.watch(appDatabaseProvider.future);
    yield* (db.select(db.walletMutations)
          ..where(
            (m) => m.state.equals(
              storedMutationState(WalletMutationState.retryScheduled),
            ),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAtEpochMs)])
          ..limit(200))
        .watch();
  },
);

class RetryView extends ConsumerStatefulWidget {
  const RetryView({super.key});

  @override
  ConsumerState<RetryView> createState() => _RetryViewState();
}

class _RetryViewState extends ConsumerState<RetryView> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final mutationsAsync = ref.watch(retryMutationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retry Failed'),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _retrySelected,
              child: Text('Retry (${_selected.length})'),
            ),
          TextButton(onPressed: _retryAll, child: const Text('Retry All')),
        ],
      ),
      body: mutationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mutations) {
          if (mutations.isEmpty) {
            return const Center(
              child: Text('No failed transactions to retry.'),
            );
          }
          return ListView.builder(
            itemCount: mutations.length,
            itemBuilder: (context, index) {
              final m = mutations[index];
              final selected = _selected.contains(m.id);
              return CheckboxListTile(
                value: selected,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selected.add(m.id);
                  } else {
                    _selected.remove(m.id);
                  }
                }),
                title: Text(m.candidateId ?? 'Unknown'),
                subtitle: Text(
                  'State: ${m.state.name} · Updated: ${_formatTime(m.updatedAtEpochMs)}',
                ),
                secondary: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _retrySingle(m.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _retrySingle(String mutationId) async {
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;
    final actions = DriftActivityRecoveryActions(
      dao: WalletMutationsDao(database: db),
    );
    await actions.retryNow(mutationId);
  }

  Future<void> _retrySelected() async {
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;
    final actions = DriftActivityRecoveryActions(
      dao: WalletMutationsDao(database: db),
    );
    for (final id in _selected) {
      await actions.retryNow(id);
    }
    if (!mounted) return;
    setState(() => _selected.clear());
  }

  Future<void> _retryAll() async {
    final mutations = ref.read(retryMutationsProvider).value ?? [];
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;
    final actions = DriftActivityRecoveryActions(
      dao: WalletMutationsDao(database: db),
    );
    for (final m in mutations) {
      await actions.retryNow(m.id);
    }
    if (!mounted) return;
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    ).toLocal();
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
