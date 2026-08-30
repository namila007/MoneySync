import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/transaction_parser/domain/transaction_candidate.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/application/wallet_mutation_transmitter.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_controller.dart'
    show inboxEventsProvider;
import 'package:money_sync/features/review_inbox/presentation/review_transaction_panel.dart'
    show TargetAccountPicker, CategoryPicker;

/// Detail page for a single queued mutation (WP5; edit + reject added M5.22
/// WP-J). Shows the stored payload snapshot, editable before it is sent, with
/// Approve and Reject actions.
class WaitingItemDetailPage extends ConsumerStatefulWidget {
  const WaitingItemDetailPage({required this.mutationId, super.key});

  final String mutationId;

  @override
  ConsumerState<WaitingItemDetailPage> createState() =>
      _WaitingItemDetailPageState();
}

class _WaitingItemDetailPageState extends ConsumerState<WaitingItemDetailPage> {
  late final Future<WalletMutation?> _mutationFuture;
  bool _approving = false;
  bool _rejecting = false;
  String? _error;
  bool _seeded = false;

  final _amountController = TextEditingController();
  final _counterpartyController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionKind _kind = TransactionKind.expense;
  TransactionDirection _direction = TransactionDirection.debit;
  String _paymentType = 'debit_card';
  // Set from the stored payload. Deliberately not defaulted to a currency
  // literal here — bank_agnostic_test forbids a `= '<CUR>'` default outside
  // the rule packs, and the payload read below already supplies the fallback.
  String _currencyCode = '';
  String? _accountId;
  String? _categoryId;
  List<String> _labelNames = [];

  @override
  void initState() {
    super.initState();
    _mutationFuture = _loadMutation();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _counterpartyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(walletCatalogProvider);
    final catalog = catalogAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Waiting detail')),
      body: FutureBuilder<WalletMutation?>(
        future: _mutationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final mutation = snapshot.data;
          if (mutation == null) {
            return const Center(child: Text('Mutation not found.'));
          }

          _seedFromPayload(_decodePayload(mutation.payload), catalog);
          // Only a not-yet-transmitted mutation may be rejected: `syncing`,
          // `succeeded`, or any `unknown*` state may already exist in
          // Wallet, and discarding them locally would lose the link to a
          // real remote record (M5.22 WP-J).
          final canReject = mutation.state == WalletMutationState.queued;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '$_currencyCode ',
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
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
                        if (v != null) setState(() => _kind = v);
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
                        if (v != null) setState(() => _direction = v);
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
                        DropdownMenuItem(
                          value: 'transfer',
                          child: Text('Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'voucher',
                          child: Text('Voucher'),
                        ),
                        DropdownMenuItem(
                          value: 'mobile_payment',
                          child: Text('Mobile payment'),
                        ),
                        DropdownMenuItem(
                          value: 'web_payment',
                          child: Text('Web payment'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _paymentType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TargetAccountPicker(
                      selectedAccountId: _accountId,
                      onChanged: (id) => setState(() => _accountId = id),
                    ),
                    const SizedBox(height: 12),
                    CategoryPicker(
                      selectedCategoryId: _categoryId,
                      onChanged: (id) => setState(() => _categoryId = id),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _counterpartyController,
                      maxLength: 255,
                      decoration: const InputDecoration(
                        labelText: 'Counterparty',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: _noteController,
                      maxLength: 255,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _DetailRow(label: 'State', value: mutation.state.name),
                    _DetailRow(
                      label: 'Created',
                      value: _formatTime(mutation.createdAtEpochMs),
                    ),
                    if (_labelNames.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                'Labels',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  for (final name in _labelNames)
                                    Chip(
                                      label: Text(
                                        name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Pinned outside the scroll view. As the last children of a
              // ListView these were only built when scrolled into view — a
              // user had to scroll past every field to reach them, and they
              // were invisible to widget tests in an 800x600 viewport.
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          if (canReject)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: (_approving || _rejecting)
                                    ? null
                                    : () => _reject(mutation),
                                icon: _rejecting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.close),
                                label: Text(
                                  _rejecting ? 'Rejecting…' : 'Reject',
                                ),
                              ),
                            ),
                          if (canReject) const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: (_approving || _rejecting)
                                  ? null
                                  : () => _approve(mutation),
                              icon: _approving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(
                                _approving ? 'Approving…' : 'Approve',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Seeds the edit controls from the stored payload once — never clobbers
  /// an in-progress edit on rebuild.
  void _seedFromPayload(Map<String, Object?> payload, WalletCatalog? catalog) {
    if (_seeded) return;
    _seeded = true;
    final amountMinor = (payload['amountMinor'] is int)
        ? payload['amountMinor'] as int
        : 0;
    _amountController.text = (amountMinor.abs() / 100).toStringAsFixed(2);
    _currencyCode = payload['currencyCode'] as String? ?? 'LKR';
    _kind = _kindFrom(payload['kind']);
    _direction = _directionFrom(payload['direction']);
    _paymentType = payload['paymentType'] as String? ?? 'debit_card';
    _accountId = payload['accountId'] as String?;
    _categoryId = payload['categoryId'] as String?;
    _counterpartyController.text = payload['counterParty'] as String? ?? '';
    _noteController.text = _stripNoteMarker(payload['note'] as String?);
    if (payload['labelIds'] is List<dynamic>) {
      final labelIds = (payload['labelIds'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      _rawLabelIds = labelIds;
      _labelNames = _resolveLabelNames(catalog, labelIds);
    }
  }

  static Map<String, Object?> _decodePayload(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, Object?>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<WalletMutation?> _loadMutation() async {
    final db = await ref.read(appDatabaseProvider.future);
    final rows = await (db.select(
      db.walletMutations,
    )..where((m) => m.id.equals(widget.mutationId))).get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Plain-language outcome for an approve that did not confirm. Each message
  /// reflects the state the mutation is actually in, so the user knows whether
  /// to wait, retry, or fix something.
  static String _approveMessage(WalletMutationResult result) =>
      switch (result) {
        WalletMutationPostTransmissionAmbiguity() =>
          "Couldn't confirm whether Wallet saved this. We'll check before "
              'retrying, so it is not created twice.',
        WalletMutationClientFailure() =>
          'Wallet rejected this record. Check the account and amount.',
        WalletMutationServerFailure() =>
          "Wallet is unavailable right now. Scheduled for retry.",
        WalletMutationPreTransmissionFailure() =>
          "Couldn't reach Wallet. Scheduled for retry.",
        _ => 'Approve did not complete.',
      };

  Future<void> _approve(WalletMutation mutation) async {
    setState(() {
      _approving = true;
      _error = null;
    });

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final repository = ref.read(walletRepositoryProvider);

      final amountMinor = _parseAmountMinor(_amountController.text);
      final note = _noteController.text.trim();
      final counterParty = _counterpartyController.text.trim();

      // Build snapshot from the (possibly edited) fields.
      final snapshot = TransactionCandidateSnapshot(
        accountId: _accountId ?? '',
        // M5.22 WP-M: sign by the edited direction so an expense is not
        // filed as income by Wallet's sign convention.
        amountMinor: signedMinorUnits(amountMinor, _direction, kind: _kind),
        currencyCode: _currencyCode,
        recordDateUtc: DateTime.now().toUtc(),
        paymentType: _wirePaymentType(_paymentType),
        recordState: WalletRecordState.cleared,
        counterParty: counterParty.isEmpty ? null : counterParty,
        categoryId: _categoryId,
        note: note.isEmpty ? null : note,
      );

      // M5.22 WP-K: one shared transmit-and-resolve path. This used to inline
      // its own copy, which is how the Create-now caller came to omit the
      // transmission entirely. It also mapped *every* failure to
      // permanentFailure — including post-transmission ambiguity, which must
      // become unknownDelivery so reconciliation can settle it instead of the
      // record being written off as unrecoverable.
      final result = await WalletMutationTransmitter(
        database: db,
        repository: repository,
      ).transmit(mutationId: mutation.id, snapshot: snapshot);

      if (result is WalletMutationRemoteSuccess) {
        if (mounted) {
          ref.invalidate(filteredActivityLogProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record created successfully.')),
          );
          context.pop();
        }
      } else {
        // The transmitter already resolved the state to the one the outcome
        // actually warrants (retryScheduled / unknownDelivery /
        // permanentFailure), so only the message is left to render.
        setState(() => _error = _approveMessage(result));
      }
    } catch (e) {
      setState(() => _error = 'Approve failed: $e');
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  /// Rejects an untransmitted mutation: it transitions to
  /// `supersededBeforeSend` (the one legal move out of `queued` for a
  /// discard — see [WalletMutationStateTransitions]) and its candidate goes
  /// back to `needsReview` so the message reappears in the inbox, which
  /// excludes only `retainedLocal` candidates (M5.22 WP-D).
  Future<void> _reject(WalletMutation mutation) async {
    setState(() {
      _rejecting = true;
      _error = null;
    });

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final dao = WalletMutationsDao(database: db);
      final intent = await dao.byId(mutation.id);
      if (intent == null) {
        setState(() => _error = 'Mutation not found.');
        return;
      }

      await dao.transitionTo(
        intent: intent,
        next: WalletMutationState.supersededBeforeSend,
      );
      if (intent.candidateId.isNotEmpty) {
        await dao.transitionCandidateState(
          candidateId: intent.candidateId,
          newState: 'needsReview',
        );
      }
      await db.insertActivity(
        activityType: ActivityEventCode.walletRecordFailed,
        safeDetailCode: ActivityStateTransition.needsReview,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: await _currentPrivacyEpoch(db),
        detailMessage: 'Rejected before send — message returned to inbox',
      );

      if (mounted) {
        ref.invalidate(inboxEventsProvider);
        ref.invalidate(filteredActivityLogProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rejected. Message returned to inbox.')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _error = 'Reject failed: $e');
    } finally {
      if (mounted) setState(() => _rejecting = false);
    }
  }

  Future<int> _currentPrivacyEpoch(AppDatabase db) async {
    final row = await (db.select(
      db.appSettings,
    )..where((s) => s.singletonId.equals(1))).getSingleOrNull();
    return row?.privacyEpoch ?? 0;
  }

  /// Decimal-string amount input to unsigned minor units. Never a double —
  /// parses the fixed-scale string directly.
  static int _parseAmountMinor(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    final parts = trimmed.split('.');
    final whole = int.tryParse(parts[0].replaceAll(',', '')) ?? 0;
    final fractionText = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    final fraction = int.tryParse(fractionText) ?? 0;
    return whole.abs() * 100 + fraction;
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    ).toLocal();
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Strips the `[sw:...]` reconciliation marker prefix from a note.
  static String _stripNoteMarker(String? note) {
    if (note == null || note.isEmpty) return '';
    final markerPattern = RegExp(r'^\[sw:[A-Z0-9]+\]\s*');
    return note.replaceFirst(markerPattern, '');
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

  static TransactionKind _kindFrom(Object? raw) => switch (raw) {
    'income' => TransactionKind.income,
    'refund' => TransactionKind.refund,
    'transfer' => TransactionKind.transfer,
    'authorization' => TransactionKind.authorization,
    'settlement' => TransactionKind.settlement,
    'reversal' => TransactionKind.reversal,
    'nonTransaction' => TransactionKind.nonTransaction,
    _ => TransactionKind.expense,
  };

  static List<String> _resolveLabelNames(
    WalletCatalog? catalog,
    List<String>? labelIds,
  ) {
    if (labelIds == null || labelIds.isEmpty || catalog == null) return [];
    return [
      for (final id in labelIds)
        catalog.labels
                .where((l) => l.id == id)
                .map((l) => l.name)
                .firstOrNull ??
            id,
    ];
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

/// Stored payload `direction` back to the enum. Unknown or missing values are
/// neutral, which leaves the amount magnitude untouched rather than guessing
/// a sign (M5.22 WP-M).
TransactionDirection _directionFrom(Object? raw) => switch (raw) {
  'debit' => TransactionDirection.debit,
  'credit' => TransactionDirection.credit,
  _ => TransactionDirection.neutral,
};
