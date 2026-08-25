import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/domain/review_transaction_use_case.dart';
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
    this.fallbackDate,
  });

  final int smsEventId;
  final String encryptedPayload;
  final String senderNormalized;

  /// Optional parsed candidate summary for auto-fill (Bug 6). Seeded into
  /// fields on first build; never clobbers a user's in-progress edit.
  final CandidateSummaryView? initialSummary;

  /// Fallback date when the candidate summary has no transactionAtUtc.
  /// Typically the SMS event's receivedAtUtc.
  final DateTime? fallbackDate;

  @override
  ConsumerState<ReviewTransactionPanel> createState() =>
      _ReviewTransactionPanelState();
}

class _ReviewTransactionPanelState
    extends ConsumerState<ReviewTransactionPanel> {
  final _amountController = TextEditingController();
  final _counterpartyController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionKind _kind = TransactionKind.expense;
  TransactionDirection _direction = TransactionDirection.debit;
  DateTime? _dateUtc;
  String? _accountId;
  String? _categoryId;
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

    // Amount: seed formatted with commas if controller is empty
    if (_amountController.text.isEmpty && summary.amountMinor != 0) {
      _amountController.text = _formatAmountWithCommas(summary.amountMinor);
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

    // Date: prefer parsed transactionAtUtc, fall back to message received date
    _dateUtc = summary.transactionAtUtc ?? widget.fallbackDate;

    // Counterparty: seed from parsed merchant/payee (WP6), never clobber edit.
    if (_counterpartyController.text.isEmpty &&
        summary.counterParty != null &&
        summary.counterParty!.isNotEmpty) {
      _counterpartyController.text = summary.counterParty!;
    }

    // Push seeded values to the controller (without re-evaluating gates yet)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pushUpdate(evaluate: false);
    });
  }

  static String _formatAmountWithCommas(int minorUnits) {
    final abs = minorUnits.abs();
    final majorUnits = abs / 100; // minor → major for display
    final formatted = majorUnits
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return minorUnits < 0 ? '-$formatted' : formatted;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _counterpartyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pushUpdate({bool evaluate = true}) {
    // Strip commas — field displays major units (e.g., "4,699.00"), the
    // controller stores minor units (469900). Convert back.
    final raw = _amountController.text.replaceAll(',', '').trim();
    final amount = ((double.tryParse(raw) ?? 0) * 100).round();
    ref
        .read(reviewTransactionControllerProvider(widget.smsEventId).notifier)
        .update(
          amountMinor: amount,
          kind: _kind,
          direction: _direction,
          dateUtc: _dateUtc,
          accountId: _accountId,
          categoryId: _categoryId,
          paymentType: _paymentType,
          counterParty: _counterpartyController.text.trim(),
          note: _noteController.text.trim(),
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

    // WP0: react to submission result — pop on success, surface error inline.
    ref.listen<ReviewTransactionViewState>(
      reviewTransactionControllerProvider(widget.smsEventId),
      (prev, next) {
        if (prev?.result == next.result) return;
        final result = next.result;
        if (result is ReviewSubmitted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Record created')));
          context.pop();
        }
      },
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
                labelText: 'Amount (LKR)',
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
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _dateUtc == null
                    ? 'Select date & time'
                    : '${_dateUtc!.year}-${_dateUtc!.month.toString().padLeft(2, '0')}-${_dateUtc!.day.toString().padLeft(2, '0')} '
                          '${_dateUtc!.hour.toString().padLeft(2, '0')}:${_dateUtc!.minute.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 12),
            TargetAccountPicker(
              selectedAccountId: _accountId,
              onChanged: (id) {
                _accountId = id;
                _pushUpdate();
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Category',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            CategoryPicker(
              selectedCategoryId: _categoryId,
              onChanged: (id) {
                _categoryId = id;
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
                labelText: 'Counterparty',
                helperText: 'Merchant or payee name',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _pushUpdate(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Note',
                helperText: 'Add a note (optional)',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _pushUpdate(),
            ),
            const SizedBox(height: 12),
            _LabelPicker(
              selectedLabelIds: state.labelIds,
              onChanged: (ids) {
                ref
                    .read(
                      reviewTransactionControllerProvider(
                        widget.smsEventId,
                      ).notifier,
                    )
                    .update(labelIds: ids);
              },
            ),
            if (state.result case ReviewBlocked(:final reason))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  reason,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.result case ReviewDuplicate())
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'A record for this message already exists.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
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
                    label: Text(
                      state.submitting ? 'Creating…' : 'Create record',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
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
                                deferred: true,
                              ),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Save for later'),
                  ),
                ),
              ],
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
    if (picked == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dateUtc != null
          ? TimeOfDay.fromDateTime(_dateUtc!)
          : TimeOfDay.now(),
    );
    if (!mounted || pickedTime == null) return;

    _dateUtc = DateTime.utc(
      picked.year,
      picked.month,
      picked.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    _pushUpdate();
  }
}

/// Wallet target picker: all LKR accounts are selectable. Archived accounts
/// show a warning note — the pre-send gate will block writing to them.
class TargetAccountPicker extends ConsumerWidget {
  const TargetAccountPicker({
    required this.selectedAccountId,
    required this.onChanged,
    super.key,
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
        final selectedAccount = lkrAccounts
            .where((a) => a.id == selectedAccountId)
            .firstOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
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
                    child: Text(
                      account.isBankSynced
                          ? '${account.name} (bank-synced)'
                          : account.isArchived
                          ? '${account.name} (archived)'
                          : account.name,
                    ),
                  ),
              ],
              onChanged: (id) {
                if (id == null) return;
                onChanged(id);
              },
            ),
            if (selectedAccount?.isArchived == true) ...[
              const SizedBox(height: 4),
              Text(
                'This account is archived and may not be writable. '
                'The pre-send gate will block writing to it.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Group → Category picker (WP2). Shows "Group › Category" or "Uncategorized".
/// Opens a bottom sheet with the same grouped hierarchy as the wallet-connection
/// detail screen.
class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({
    required this.selectedCategoryId,
    required this.onChanged,
    super.key,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(walletCatalogProvider);
    return catalogAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Category catalog unavailable.'),
      data: (catalog) {
        if (catalog == null || catalog.categories.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Connect your Wallet to choose a category.'),
            ),
          );
        }

        // A group selection reads as "All <Group>" rather than
        // "Food & Drinks › Food & Drinks" (M5.22 WP-G).
        final selectedName = selectedCategoryId != null
            ? catalog.categories
                  .where((c) => c.id == selectedCategoryId)
                  .map(
                    (c) => c.isGroupGeneral
                        ? 'All ${c.groupName}'
                        : '${c.groupName} › ${c.name}',
                  )
                  .firstOrNull
            : null;

        return OutlinedButton.icon(
          onPressed: () => _showPicker(context, catalog.categories),
          icon: const Icon(Icons.category_outlined),
          label: Text(selectedName ?? 'Uncategorized'),
        );
      },
    );
  }

  void _showPicker(BuildContext context, List<WalletCategory> categories) {
    // Group by groupId.
    final grouped = <String, List<WalletCategory>>{};
    for (final c in categories) {
      grouped.putIfAbsent(c.groupId, () => []).add(c);
    }
    final groupIds = grouped.keys.toList()..sort();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onChanged(null);
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: groupIds.length,
                itemBuilder: (context, index) {
                  final groupId = groupIds[index];
                  final groupCats = grouped[groupId]!;
                  final groupName = groupCats.first.groupName;
                  final baseCats =
                      groupCats
                          .where((c) => !c.customCategory && c.parentId == null)
                          .toList()
                        ..sort((a, b) => a.name.compareTo(b.name));
                  // The category standing in for the whole group, if the
                  // registry defines one for this group.
                  final groupGeneral = groupCats
                      .where((c) => c.isGroupGeneral)
                      .firstOrNull;

                  return ExpansionTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(groupName),
                    children: [
                      // M5.22 WP-G. This used to pass `groupId` straight
                      // through, on the assumption that "Wallet API maps this
                      // to the default category for the group". It does not:
                      // categoryId must be a real category id, so the label
                      // lookup never matched and the button silently fell back
                      // to "Uncategorized". Every group instead owns a general
                      // base category (`<groupId>__general`) — that is the id
                      // to send.
                      if (groupGeneral != null)
                        ListTile(
                          leading: const Icon(Icons.folder_open_outlined),
                          title: Text('All $groupName'),
                          subtitle: const Text('Whole group'),
                          selected: groupGeneral.id == selectedCategoryId,
                          onTap: () {
                            onChanged(groupGeneral.id);
                            Navigator.pop(context);
                          },
                        ),
                      for (final cat in baseCats)
                        ListTile(
                          leading: const Icon(Icons.label_outlined),
                          title: Text(cat.name),
                          selected: cat.id == selectedCategoryId,
                          onTap: () {
                            onChanged(cat.id);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label multi-select picker using FilterChips. Pre-seeds with the cached
/// "money_sync" label selected by default. The user can toggle labels on/off.
class _LabelPicker extends ConsumerWidget {
  const _LabelPicker({required this.selectedLabelIds, required this.onChanged});

  final List<String> selectedLabelIds;
  final ValueChanged<List<String>> onChanged;

  static const _defaultLabelName = 'money_sync';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(walletCatalogProvider);
    return catalogAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (catalog) {
        final labels = catalog?.labels ?? const <WalletLabel>[];

        // M5.22 WP-L: select `money_sync` by default. Until this milestone the
        // catalog never fetched labels at all, so this never ran and every
        // created record came back from Wallet with `labels: []`.
        final defaultLabel = labels
            .where((l) => l.name == _defaultLabelName)
            .firstOrNull;
        // Re-seeds whenever the selection is empty, which is intended: the
        // default must be on every created record, so clearing all labels
        // brings it back rather than silently shipping an unlabelled record.
        if (defaultLabel != null && selectedLabelIds.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) onChanged([defaultLabel.id]);
          });
        }

        final selected = labels
            .where((l) => selectedLabelIds.contains(l.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Labels',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            // Only the chosen labels are shown as chips. A flat list of every
            // label does not scale — a real Wallet carries dozens.
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final label in selected)
                  InputChip(
                    label: Text(label.name),
                    onDeleted: () {
                      final next = List<String>.from(selectedLabelIds)
                        ..remove(label.id);
                      onChanged(next);
                    },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add label'),
                  onPressed: labels.isEmpty
                      ? null
                      : () => _showLabelSheet(context, labels),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLabelSheet(BuildContext context, List<WalletLabel> labels) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _LabelSearchSheet(
        labels: labels,
        selectedLabelIds: selectedLabelIds,
        onChanged: onChanged,
      ),
    );
  }
}

/// Searchable multi-select over the whole label catalog (M5.22 WP-L).
class _LabelSearchSheet extends StatefulWidget {
  const _LabelSearchSheet({
    required this.labels,
    required this.selectedLabelIds,
    required this.onChanged,
  });

  final List<WalletLabel> labels;
  final List<String> selectedLabelIds;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_LabelSearchSheet> createState() => _LabelSearchSheetState();
}

class _LabelSearchSheetState extends State<_LabelSearchSheet> {
  late final List<String> _selected = List<String>.from(
    widget.selectedLabelIds,
  );
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches =
        widget.labels
            .where(
              (l) => l.name.toLowerCase().contains(_query.trim().toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search labels',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? const Center(child: Text('No labels match.'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final label = matches[index];
                      final checked = _selected.contains(label.id);
                      return CheckboxListTile(
                        title: Text(label.name),
                        value: checked,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selected.add(label.id);
                            } else {
                              _selected.remove(label.id);
                            }
                          });
                          widget.onChanged(List<String>.from(_selected));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
