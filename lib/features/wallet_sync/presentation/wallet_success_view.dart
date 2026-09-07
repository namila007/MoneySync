import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/presentation/mutation_state_label.dart';

final succeededMutationsProvider =
    StreamProvider.autoDispose<List<WalletMutation>>((ref) async* {
      final db = await ref.watch(appDatabaseProvider.future);
      yield* (db.select(db.walletMutations)
            ..where(
              (m) => m.state.equals(
                storedMutationState(WalletMutationState.succeeded),
              ),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAtEpochMs)])
            ..limit(200))
          .watch();
    });

final _log = Logger('WalletSuccessView');

class SuccessView extends ConsumerWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutationsAsync = ref.watch(succeededMutationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Succeeded'),
        leading: BackButton(onPressed: () => context.pop()),
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
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'No succeeded transactions.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              // Subtitle
              Text(
                'Mutations successfully posted to your wallet.',
                style: AppTypography.body.copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: AppSpacing.s4),

              // Mutation cards
              for (final m in mutations) ...[
                _SuccessCard(mutation: m),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SuccessCard extends ConsumerWidget {
  const _SuccessCard({required this.mutation});

  final WalletMutation mutation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = _decodePayload(mutation.payload);
    final amountMinor = (payload['amountMinor'] is int)
        ? payload['amountMinor'] as int
        : 0;
    final currencyCode = (payload['currencyCode'] as String?) ?? 'LKR';
    final kind = (payload['kind'] as String?) ?? 'expense';
    final counterParty = (payload['counterParty'] as String?) ?? '';
    final categoryId = payload['categoryId'] as String?;

    final catalog = ref.watch(walletCatalogProvider).value;
    final categoryName = _resolveCategoryName(catalog, categoryId);
    final title = counterParty.isNotEmpty
        ? '$counterParty \u2014 $categoryName'
        : kind == 'income'
        ? 'Income'
        : 'Expense';

    final db = ref.read(appDatabaseProvider).asData?.value;

    return Dismissible(
      key: ValueKey(mutation.id),
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
            title: const Text('Delete succeeded mutation?'),
            content: const Text(
              'This record will be removed from the succeeded list.',
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
      onDismissed: (_) => _deleteMutation(db, mutation.id),
      child: GestureDetector(
        onTap: () => context.push('/settings/wallet/succeeded/${mutation.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.h5.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(mutation.updatedAtEpochMs),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$currencyCode ${_formatAmount(amountMinor)}',
                style: AppTypography.amount.copyWith(
                  fontSize: 18,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMutation(AppDatabase? db, String mutationId) async {
    if (db == null) return;
    await (db.delete(
      db.walletMutations,
    )..where((m) => m.id.equals(mutationId))).go();
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
    return majorUnits
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    ).toLocal();
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
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
}
