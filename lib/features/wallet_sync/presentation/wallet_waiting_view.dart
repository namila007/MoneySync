import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';
import 'package:money_sync/features/wallet_sync/presentation/mutation_state_label.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_success_view.dart'
    show succeededMutationsProvider;

/// Mutations in queued/syncing state, for the waiting view.
/// WP5: FutureProvider with explicit invalidation in the submit handler.
/// The home dashboard's Waiting tile uses the reactive homeWalletHealthProvider
/// (StreamProvider watching wallet_mutations) for immediate count updates.
final waitingMutationsProvider = FutureProvider<List<WalletMutation>>((
  ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return (db.select(db.walletMutations)
        ..where(
          (m) => m.state.isIn([
            storedMutationState(WalletMutationState.queued),
            storedMutationState(WalletMutationState.syncing),
          ]),
        )
        ..orderBy([(t) => OrderingTerm.desc(t.createdAtEpochMs)])
        ..limit(200))
      .get();
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
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: _approvingAll ? null : _approveSelected,
              child: Text('Approve (${_selected.length})'),
            ),
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selected.clear()),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: mutationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mutations) {
          if (mutations.isEmpty) {
            return const Center(child: Text('No pending transactions.'));
          }
          return ListView.builder(
            itemCount: mutations.length,
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

              return ListTile(
                leading: Checkbox(
                  value: selected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(m.id);
                    } else {
                      _selected.remove(m.id);
                    }
                  }),
                ),
                title: Text(
                  '$currencyCode ${_formatAmount(amountMinor)} · $kind',
                ),
                subtitle: Text(
                  '${m.state.name} · ${_formatTime(m.createdAtEpochMs)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      context.push('/settings/wallet/waiting/${m.id}'),
                ),
                onTap: () => context.push('/settings/wallet/waiting/${m.id}'),
              );
            },
          );
        },
      ),
    );
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
          // M5.22 WP-M: sign by the stored direction so an expense is not
          // filed as income by Wallet's sign convention.
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
          // Move the candidate out of needsReview (M5.18 finding 3).
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

    ref.invalidate(waitingMutationsProvider);
    // M5.22 WP-C: any approve that succeeded moved a mutation into
    // `succeeded`, so the Success list is stale as well.
    if (succeeded > 0) ref.invalidate(succeededMutationsProvider);

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

/// Stored payload `direction` back to the enum. Unknown or missing values are
/// neutral, which leaves the amount magnitude untouched rather than guessing
/// a sign (M5.22 WP-M).
TransactionDirection _directionFrom(Object? raw) => switch (raw) {
  'debit' => TransactionDirection.debit,
  'credit' => TransactionDirection.credit,
  _ => TransactionDirection.neutral,
};

/// Stored payload `kind` back to the enum, so the refund sign rule applies on
/// the approve path too (M5.22, plan/05:108).
TransactionKind? _kindFrom(Object? raw) => switch (raw) {
  'refund' => TransactionKind.refund,
  'income' => TransactionKind.income,
  'transfer' => TransactionKind.transfer,
  'expense' => TransactionKind.expense,
  _ => null,
};
