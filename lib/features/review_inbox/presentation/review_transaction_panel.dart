import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
import 'package:money_sync/features/review_inbox/domain/wallet_create_eligibility_policy.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_detail_page.dart'
    show CandidateSummaryView;
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// Review-and-create surface for one message (plan/04 §Review transaction
/// screen; M5.10). Editable fields + the ordered M5.8 gate-outcome list + a
/// Create button wired to the atomic M5.9 use case with a UI double-submit
/// guard. FX/transfer sub-flows are out of scope for M5.
class ReviewTransactionPanel extends ConsumerStatefulWidget {
  const ReviewTransactionPanel({
    super.key,
    required this.smsEventId,
    required this.encryptedPayload,
    required this.senderNormalized,
    this.initialSummary,
  });

  final int smsEventId;
  final String encryptedPayload;
  final String senderNormalized;

  /// Optional parsed candidate summary for auto-fill (Bug 6). Seeded into
  /// fields on first build; never clobbers a user's in-progress edit.
  final CandidateSummaryView? initialSummary;

  @override
  ConsumerState<ReviewTransactionPanel> createState() =>
      _ReviewTransactionPanelState();
}

class _ReviewTransactionPanelState
    extends ConsumerState<ReviewTransactionPanel> {
  final _amountController = TextEditingController();
  final _counterpartyController = TextEditingController();
  TransactionKind _kind = TransactionKind.expense;
  TransactionDirection _direction = TransactionDirection.debit;
  DateTime? _dateUtc;
  String? _accountId;
  String _paymentType = 'debit_card';
  var _summarySeeded = false;

  @override
  void initState() {
    super.initState();
    _seedFromSummary();
  }

  /// Seed editable fields from the candidate summary on first build (Bug 6).
  /// Only fills fields that are still at their default/empty values — never
  /// clobbers a user's in-progress edit on rebuild.
  void _seedFromSummary() {
    final summary = widget.initialSummary;
    if (summary == null || _summarySeeded) return;
    _summarySeeded = true;

    // Amount: seed if controller is empty
    if (_amountController.text.isEmpty && summary.amountMinor != 0) {
      _amountController.text = summary.amountMinor.toString();
    }

    // Kind: map string to enum
    _kind = switch (summary.kind) {
      'income' => TransactionKind.income,
      'transfer' => TransactionKind.transfer,
      'refund' => TransactionKind.refund,
      _ => TransactionKind.expense,
    };

    // Direction: map string to enum
    _direction = switch (summary.direction) {
      'credit' => TransactionDirection.credit,
      'neutral' => TransactionDirection.neutral,
      _ => TransactionDirection.debit,
    };
  }

  @override
  void dispose() {
    _amountController.dispose();
    _counterpartyController.dispose();
    super.dispose();
  }

  void _pushUpdate({bool evaluate = true}) {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    ref
        .read(reviewTransactionControllerProvider(widget.smsEventId).notifier)
        .update(
          amountMinor: amount,
          kind: _kind,
          direction: _direction,
          dateUtc: _dateUtc,
          accountId: _accountId,
          paymentType: _paymentType,
          counterParty: _counterpartyController.text.trim(),
        );
    if (evaluate) {
      ref
          .read(reviewTransactionControllerProvider(widget.smsEventId).notifier)
          .evaluate(
            encryptedPayload: widget.encryptedPayload,
            senderNormalized: widget.senderNormalized,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      reviewTransactionControllerProvider(widget.smsEventId),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review transaction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (minor units)',
                helperText: 'Same-currency LKR only in M5',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _pushUpdate(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TransactionKind>(
              initialValue: _kind,
              decoration: const InputDecoration(
                labelText: 'Kind',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final kind in TransactionKind.values)
                  DropdownMenuItem(value: kind, child: Text(kind.name)),
              ],
              onChanged: (v) {
                if (v != null) {
                  _kind = v;
                  _pushUpdate();
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TransactionDirection>(
              initialValue: _direction,
              decoration: const InputDecoration(
                labelText: 'Direction',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final direction in TransactionDirection.values)
                  DropdownMenuItem(
                    value: direction,
                    child: Text(direction.name),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  _direction = v;
                  _pushUpdate();
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _dateUtc == null
                    ? 'Select date'
                    : '${_dateUtc!.year}-${_dateUtc!.month}-${_dateUtc!.day}',
              ),
            ),
            const SizedBox(height: 12),
            _TargetAccountPicker(
              selectedAccountId: _accountId,
              onChanged: (id) {
                _accountId = id;
                _pushUpdate();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _paymentType,
              decoration: const InputDecoration(
                labelText: 'Payment type',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(
                  value: 'debit_card',
                  child: Text('Debit card'),
                ),
                DropdownMenuItem(
                  value: 'credit_card',
                  child: Text('Credit card'),
                ),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _paymentType = v;
                  _pushUpdate();
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _counterpartyController,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Note',
                helperText: 'Note about this transaction',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _pushUpdate(),
            ),
            const SizedBox(height: 8),
            if (state.evaluation case final evaluation?) ...[
              const SizedBox(height: 8),
              _GateList(evaluation: evaluation),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Tap Create to evaluate the pre-send gates.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (state.result case ReviewBlocked(:final reason))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  reason,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.submitting
                    ? null
                    : () => ref
                          .read(
                            reviewTransactionControllerProvider(
                              widget.smsEventId,
                            ).notifier,
                          )
                          .submit(
                            encryptedPayload: widget.encryptedPayload,
                            senderNormalized: widget.senderNormalized,
                            revision: 1,
                          ),
                icon: state.submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(state.submitting ? 'Creating…' : 'Create record'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateUtc ?? now,
      firstDate: now.subtract(const Duration(days: 3650)),
      lastDate: now.add(const Duration(hours: 24)),
    );
    if (picked != null) {
      _dateUtc = DateTime.utc(picked.year, picked.month, picked.day);
      _pushUpdate();
    }
  }
}

/// Ordered pre-send gate outcome list (M5.8): the user sees exactly which
/// gate blocks, not just a pass/fail.
class _GateList extends StatelessWidget {
  const _GateList({required this.evaluation});

  final GateEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Privacy epoch',
      'Consent',
      'Wallet connection',
      'Account eligibility',
      'Mapping resolution',
      'Amount/date/currency',
      'Duplicate/tombstone',
      'Capability',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Pre-send gates',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            for (var i = 0; i < evaluation.outcomes.length; i++)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(
                  evaluation.outcomes[i] is GatePass
                      ? Icons.check_circle_outline
                      : Icons.block,
                  color: evaluation.outcomes[i] is GatePass
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
                title: Text(labels[i]),
                subtitle: evaluation.outcomes[i] is GateBlock
                    ? Text(
                        (evaluation.outcomes[i] as GateBlock).reason,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// Wallet target picker: bank-synced/archived accounts stay visible but
/// disabled (plan/04 mapping editor rule, reused here).
class _TargetAccountPicker extends ConsumerWidget {
  const _TargetAccountPicker({
    required this.selectedAccountId,
    required this.onChanged,
  });

  final String? selectedAccountId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(walletCatalogProvider);
    return catalogAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Wallet catalog unavailable.'),
      data: (catalog) {
        if (catalog == null || catalog.accounts.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Connect your Wallet to choose a target account.'),
            ),
          );
        }
        final lkrAccounts = catalog.accounts
            .where((a) => a.currencyCode.toUpperCase() == 'LKR')
            .toList();
        return DropdownButtonFormField<String>(
          initialValue: selectedAccountId,
          decoration: const InputDecoration(
            labelText: 'Wallet account',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: [
            for (final account in lkrAccounts)
              DropdownMenuItem(
                value: account.id,
                enabled:
                    account.eligibility == WalletAccountEligibility.eligible,
                child: Text(
                  account.isBankSynced
                      ? '${account.name} (bank-synced)'
                      : account.name,
                ),
              ),
          ],
          onChanged: (id) {
            if (id == null) return;
            final account = lkrAccounts.firstWhere((a) => a.id == id);
            if (account.eligibility != WalletAccountEligibility.eligible)
              return;
            onChanged(id);
          },
        );
      },
    );
  }
}
