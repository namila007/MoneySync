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
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';
import 'package:money_sync/features/wallet_sync/presentation/mutation_state_label.dart';

final waitingMutationsProvider =
    StreamProvider.autoDispose<List<WalletMutation>>((ref) async* {
      final db = await ref.watch(appDatabaseProvider.future);
      yield* (db.select(db.walletMutations)
            ..where(
              (m) => m.state.isIn([
                storedMutationState(WalletMutationState.queued),
                storedMutationState(WalletMutationState.syncing),
              ]),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAtEpochMs)])
            ..limit(200))
          .watch();
    });

final _log = Logger('WalletWaitingView');

class WaitingView extends ConsumerStatefulWidget {
  const WaitingView({super.key});

  @override
  ConsumerState<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends ConsumerState<WaitingView> {
  final _selected = <String>{};
  bool _approvingAll = false;

  @override
  Widget build(BuildContext context) {
    final mutationsAsync = ref.watch(waitingMutationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _approvingAll ? null : _approveSelected,
              child: Text(
                'Approve (${_selected.length})',
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selected.clear()),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.neutral600),
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
                    Icons.hourglass_empty,
                    size: 48,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'No pending transactions.',
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
              final amountMinor = (payload['amountMinor'] is int)
                  ? payload['amountMinor'] as int
                  : 0;
              final currencyCode =
                  (payload['currencyCode'] as String?) ?? 'LKR';
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
                    context.push('/settings/wallet/waiting/${m.id}');
                    return false;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete this pending mutation?'),
                      content: const Text(
                        'This mutation will be removed from the queue.',
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
                  onTap: () =>
                      context.push('/settings/wallet/waiting/${m.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    color: selected ? AppColors.accent100 : AppColors.surface,
                    child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () => setState(() {
                          if (selected) {
                            _selected.remove(m.id);
                          } else {
                            _selected.add(m.id);
                          }
                        }),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.neutral400,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$currencyCode ${_formatAmount(amountMinor)}',
                              style: AppTypography.h5.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              caption,
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
                          Text(
                            _formatTime(m.createdAtEpochMs),
                            style: AppTypography.bodyXs.copyWith(
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.neutral400,
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

  Future<void> _approveSelected() async {
    setState(() => _approvingAll = true);

    final db = await ref.read(appDatabaseProvider.future);
    final repository = ref.read(walletRepositoryProvider);
    final dao = WalletMutationsDao(database: db);

    int succeeded = 0;
    int failed = 0;

    for (final id in _selected) {
      try {
        final intent = await dao.byId(id);
        if (intent == null) {
          failed++;
          continue;
        }

        final payload = intent.payload;
        final snapshot = TransactionCandidateSnapshot(
          accountId: (payload['accountId'] as String?) ?? '',
          amountMinor: signedMinorUnits(
            (payload['amountMinor'] is int) ? payload['amountMinor'] as int : 0,
            _directionFrom(payload['direction']),
            kind: _kindFrom(payload['kind']),
          ),
          currencyCode: (payload['currencyCode'] as String?) ?? 'LKR',
          recordDateUtc: DateTime.now().toUtc(),
          paymentType: _wirePaymentType(
            (payload['paymentType'] as String?) ?? 'debit_card',
          ),
          recordState: WalletRecordState.cleared,
          counterParty: payload['counterParty'] as String?,
          categoryId: payload['categoryId'] as String?,
          labelIds:
              (payload['labelIds'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
        );

        final result = await repository
            .create(snapshot)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => const WalletMutationPreTransmissionFailure(),
            );
        if (result is WalletMutationRemoteSuccess) {
          await dao.transitionTo(
            intent: intent,
            next: WalletMutationState.succeeded,
          );
          if (intent.candidateId.isNotEmpty) {
            await dao.transitionCandidateState(
              candidateId: intent.candidateId,
              newState: 'retainedLocal',
            );
          }
          succeeded++;
        } else {
          failed++;
        }
      } catch (e, st) {
        _log.warning('Batch approve failed for mutation $id', e, st);
        failed++;
      }
    }

    setState(() {
      _approvingAll = false;
      _selected.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approve: $succeeded succeeded, $failed failed.'),
        ),
      );
    }
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

  static WalletPaymentType _wirePaymentType(String value) => switch (value) {
    'cash' => WalletPaymentType.cash,
    'credit_card' => WalletPaymentType.creditCard,
    'transfer' => WalletPaymentType.transfer,
    'voucher' => WalletPaymentType.voucher,
    'mobile_payment' => WalletPaymentType.mobilePayment,
    'web_payment' => WalletPaymentType.webPayment,
    _ => WalletPaymentType.debitCard,
  };
}

TransactionDirection _directionFrom(Object? raw) => switch (raw) {
  'debit' => TransactionDirection.debit,
  'credit' => TransactionDirection.credit,
  _ => TransactionDirection.neutral,
};

TransactionKind? _kindFrom(Object? raw) => switch (raw) {
  'refund' => TransactionKind.refund,
  'income' => TransactionKind.income,
  'transfer' => TransactionKind.transfer,
  'expense' => TransactionKind.expense,
  _ => null,
};
