import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/data/drift_activity_recovery_actions.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/mutation_state_label.dart';

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
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _retrySelected,
              child: Text(
                'Retry (${_selected.length})',
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          TextButton(
            onPressed: _retryAll,
            child: const Text(
              'Retry All',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: mutationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mutations) {
          if (mutations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 48,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'No failed transactions to retry.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: mutations.length,
            separatorBuilder: (_, _) => Container(
              height: 2,
              color: AppColors.divider(Theme.of(context).brightness),
            ),
            itemBuilder: (context, index) {
              final m = mutations[index];
              final selected = _selected.contains(m.id);
              final payload = _decodePayload(m.payload);
              final kind = (payload['kind'] as String?) ?? 'expense';
              final counterParty =
                  (payload['counterParty'] as String?) ?? '';
              final categoryId = payload['categoryId'] as String?;

              final catalog = ref.watch(walletCatalogProvider).value;
              final categoryName = _resolveCategoryName(catalog, categoryId);
              final caption = counterParty.isNotEmpty
                  ? '$counterParty \u2014 $categoryName'
                  : kind == 'income'
                  ? 'Income'
                  : 'Expense';

              return Dismissible(
                key: ValueKey(m.id),
                direction: DismissDirection.horizontal,
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                secondaryBackground: Container(
                  color: AppColors.accent100,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(Icons.edit_outlined, color: AppColors.accent),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete this failed mutation?'),
                      content: const Text(
                        'This mutation will be removed from the retry queue.',
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
                onDismissed: (_) => _deleteMutation(m.id),
                child: GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selected.remove(m.id);
                  } else {
                    _selected.add(m.id);
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  color: selected ? AppColors.accent100 : AppColors.surface,
                  child: Row(
                    children: [
                      // Checkbox
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.accent : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : AppColors.neutral400,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caption,
                              style: AppTypography.h5.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(m.updatedAtEpochMs),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            kind.toUpperCase(),
                            style: AppTypography.micro.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () => _retrySingle(m.id),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.accent100,
                              ),
                              child: const Icon(
                                Icons.refresh,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteMutation(String mutationId) async {
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;
    await (db.delete(db.walletMutations)
          ..where((m) => m.id.equals(mutationId)))
        .go();
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
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String _resolveCategoryName(
    WalletCatalog? catalog,
    String? categoryId,
  ) {
    if (categoryId == null || catalog == null) {
      return categoryId ?? 'Uncategorized';
    }
    for (final c in catalog.categories) {
      if (c.id == categoryId) return '${c.groupName} \u203a ${c.name}';
    }
    return categoryId;
  }

  static Map<String, Object?> _decodePayload(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, Object?>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}
