import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/mutation_state_label.dart';

/// Mutations in succeeded state, for the success view.
final succeededMutationsProvider = FutureProvider<List<WalletMutation>>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return (db.select(db.walletMutations)
        ..where(
          (m) => m.state.equals(
            storedMutationState(WalletMutationState.succeeded),
          ),
        )
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAtEpochMs)])
        ..limit(200))
      .get();
});

final _log = Logger('WalletSuccessView');

class SuccessView extends ConsumerWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutationsAsync = ref.watch(succeededMutationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Succeeded')),
      body: mutationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mutations) {
          if (mutations.isEmpty) {
            return const Center(child: Text('No succeeded transactions.'));
          }
          return ListView.builder(
            itemCount: mutations.length,
            itemBuilder: (context, index) {
              final m = mutations[index];
              final payload = _decodePayload(m.payload);
              final amountMinor = (payload['amountMinor'] is int)
                  ? payload['amountMinor'] as int
                  : 0;
              final currencyCode =
                  (payload['currencyCode'] as String?) ?? 'LKR';
              final kind = (payload['kind'] as String?) ?? 'expense';

              return ListTile(
                title: Text(
                  '$currencyCode ${_formatAmount(amountMinor)} · $kind',
                ),
                subtitle: Text(
                  '${m.state.name} · ${_formatTime(m.updatedAtEpochMs)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/wallet/succeeded/${m.id}'),
              );
            },
          );
        },
      ),
    );
  }

  static Map<String, Object?> _decodePayload(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, Object?>) return decoded;
      return {};
    } catch (e) {
      _log.warning('Failed to decode mutation payload', e);
      return {};
    }
  }

  String _formatAmount(int minorUnits) {
    final abs = minorUnits.abs();
    final majorUnits = abs / 100;
    final formatted = majorUnits
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return minorUnits < 0 ? '-$formatted' : formatted;
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    ).toLocal();
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
