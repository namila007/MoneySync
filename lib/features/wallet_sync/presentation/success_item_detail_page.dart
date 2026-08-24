import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// Read-only detail page for a succeeded mutation. Shows the stored payload
/// snapshot with no action button (terminal state, nothing to approve).
class SuccessItemDetailPage extends ConsumerWidget {
  const SuccessItemDetailPage({required this.mutationId, super.key});

  final String mutationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success detail')),
      body: FutureBuilder<WalletMutation?>(
        future: _loadMutation(ref),
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
          final labelIds = (payload['labelIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();

          final catalogAsync = ref.watch(walletCatalogProvider);
          final catalog = catalogAsync.asData?.value;

          final accountName = _resolveAccountName(catalog, accountId);
          final categoryName = _resolveCategoryName(catalog, categoryId);
          final labelNames = _resolveLabelNames(catalog, labelIds);

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
              _DetailRow(label: 'Account', value: accountName),
              _DetailRow(label: 'Category', value: categoryName),
              _DetailRow(label: 'Counterparty', value: counterParty ?? ''),
              _DetailRow(label: 'Note', value: _stripNoteMarker(rawNote)),
              if (labelNames.isNotEmpty)
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
                            for (final name in labelNames)
                              Chip(
                                label: Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _DetailRow(label: 'State', value: mutation.state.name),
              _DetailRow(
                label: 'Created via app',
                value: _formatTime(mutation.createdAtEpochMs),
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

  Future<WalletMutation?> _loadMutation(WidgetRef ref) async {
    final db = await ref.read(appDatabaseProvider.future);
    final rows = await (db.select(
      db.walletMutations,
    )..where((m) => m.id.equals(mutationId))).get();
    return rows.isEmpty ? null : rows.first;
  }

  static String _resolveAccountName(WalletCatalog? catalog, String? accountId) {
    if (accountId == null || catalog == null) return accountId ?? 'Not set';
    for (final a in catalog.accounts) {
      if (a.id == accountId) return a.name;
    }
    return accountId;
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

  /// Strips the `[sw:...]` reconciliation marker prefix from a note, showing
  /// only the user-visible portion. Returns empty string for null/blank input.
  static String _stripNoteMarker(String? note) {
    if (note == null || note.isEmpty) return '';
    final markerPattern = RegExp(r'^\[sw:[A-Z0-9]+\]\s*');
    return note.replaceFirst(markerPattern, '');
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
