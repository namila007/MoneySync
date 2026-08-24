import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/wallet_sync/presentation/wallet_waiting_view.dart'
    show waitingMutationsProvider;

/// Detail page for a single queued mutation (WP5). Shows the stored payload
/// snapshot and an Approve button that calls WalletRepository.create().
class WaitingItemDetailPage extends ConsumerStatefulWidget {
  const WaitingItemDetailPage({required this.mutationId, super.key});

  final String mutationId;

  @override
  ConsumerState<WaitingItemDetailPage> createState() =>
      _WaitingItemDetailPageState();
}

class _WaitingItemDetailPageState extends ConsumerState<WaitingItemDetailPage> {
  bool _approving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting detail')),
      body: FutureBuilder<WalletMutation?>(
        future: _loadMutation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final mutation = snapshot.data;
          if (mutation == null) {
            return const Center(child: Text('Mutation not found.'));
          }

          final payload = _decodePayload(mutation.payload);
          final amountMinor = (payload['amountMinor'] is int)
              ? payload['amountMinor'] as int
              : 0;
          final currencyCode = payload['currencyCode'] as String? ?? 'LKR';
          final kind = payload['kind'] as String? ?? 'expense';
          final direction = payload['direction'] as String? ?? 'debit';
          final paymentType = payload['paymentType'] as String? ?? 'debit_card';
          final accountId = payload['accountId'] as String?;
          final categoryId = payload['categoryId'] as String?;
          final counterParty = payload['counterParty'] as String?;
          final rawNote = payload['note'] as String?;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailRow(
                label: 'Amount',
                value: '$currencyCode ${_formatAmount(amountMinor)}',
              ),
              _DetailRow(label: 'Kind', value: kind),
              _DetailRow(label: 'Direction', value: direction),
              _DetailRow(label: 'Payment type', value: paymentType),
              _DetailRow(label: 'Account', value: accountId ?? 'Not set'),
              _DetailRow(
                label: 'Category',
                value: categoryId ?? 'Uncategorized',
              ),
              _DetailRow(label: 'Counterparty', value: counterParty ?? ''),
              _DetailRow(label: 'Note', value: _stripNoteMarker(rawNote)),
              _DetailRow(label: 'State', value: mutation.state.name),
              _DetailRow(
                label: 'Created',
                value: _formatTime(mutation.createdAtEpochMs),
              ),
              const SizedBox(height: 24),
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _approving ? null : () => _approve(mutation),
                  icon: _approving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_approving ? 'Approving…' : 'Approve'),
                ),
              ),
            ],
          );
        },
      ),
    );
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

  Future<void> _approve(WalletMutation mutation) async {
    setState(() {
      _approving = true;
      _error = null;
    });

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final repository = ref.read(walletRepositoryProvider);

      // Build snapshot from stored payload.
      final payload = _decodePayload(mutation.payload);
      final snapshot = TransactionCandidateSnapshot(
        accountId: (payload['accountId'] as String?) ?? '',
        amountMinor: (payload['amountMinor'] is int)
            ? payload['amountMinor'] as int
            : 0,
        currencyCode: (payload['currencyCode'] as String?) ?? 'LKR',
        recordDateUtc: DateTime.now().toUtc(),
        paymentType: _wirePaymentType(
          (payload['paymentType'] as String?) ?? 'debit_card',
        ),
        recordState: WalletRecordState.cleared,
        counterParty: payload['counterParty'] as String?,
        categoryId: payload['categoryId'] as String?,
      );

      final result = await repository.create(snapshot);

      if (result is WalletMutationRemoteSuccess) {
        // Transition to succeeded.
        final dao = WalletMutationsDao(database: db);
        final intent = await dao.byId(mutation.id);
        if (intent != null) {
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
        }

        if (mounted) {
          ref.invalidate(waitingMutationsProvider);
          ref.invalidate(filteredActivityLogProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record created successfully.')),
          );
          context.pop();
        }
      } else {
        // Transition to permanentFailure so the user can distinguish
        // recoverable from unrecoverable failures.
        final dao = WalletMutationsDao(database: db);
        final intent = await dao.byId(mutation.id);
        if (intent != null) {
          await dao.transitionTo(
            intent: intent,
            next: WalletMutationState.permanentFailure,
          );
        }
        ref.invalidate(waitingMutationsProvider);
        setState(() => _error = 'Approve failed. Moved to permanent failure.');
      }
    } catch (e) {
      // Also transition to permanentFailure on exception.
      try {
        final db2 = await ref.read(appDatabaseProvider.future);
        final dao = WalletMutationsDao(database: db2);
        final intent = await dao.byId(mutation.id);
        if (intent != null) {
          await dao.transitionTo(
            intent: intent,
            next: WalletMutationState.permanentFailure,
          );
        }
        ref.invalidate(waitingMutationsProvider);
      } catch (_) {}
      setState(() => _error = 'Approve failed: $e');
    } finally {
      if (mounted) setState(() => _approving = false);
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
