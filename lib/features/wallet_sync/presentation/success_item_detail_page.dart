import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_spacing.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

class SuccessItemDetailPage extends ConsumerWidget {
  const SuccessItemDetailPage({required this.mutationId, super.key});

  final String mutationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success Detail'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
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
          final note = payload['note'] as String?;
          final labelIds = (payload['labelIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();

          final catalogAsync = ref.watch(walletCatalogProvider);
          final catalog = catalogAsync.asData?.value;

          final accountName = _resolveAccountName(catalog, accountId);
          final categoryName = _resolveCategoryName(catalog, categoryId);
          final labelNames = _resolveLabelNames(catalog, labelIds);
          final amountText = '$currencyCode ${_formatAmount(amountMinor)}';
          final title = (counterParty != null && counterParty.isNotEmpty)
              ? counterParty
              : categoryName;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              // Summary card
              _SuccessSummary(
                amountText: amountText,
                title: title,
                categoryName: categoryName,
                accountName: accountName,
                dateText: _formatDateOnly(mutation.createdAtEpochMs),
              ),
              const SizedBox(height: AppSpacing.s6),

              // Detail rows
              _DetailRow(label: 'Amount', value: amountText),
              _DetailRow(label: 'Kind', value: _capitalizeKind(kind)),
              _DetailRow(label: 'Direction', value: _capitalizeKind(direction)),
              _DetailRow(label: 'Payment', value: _formatPaymentType(paymentType)),
              _DetailRow(label: 'Account', value: accountName),
              _DetailRow(label: 'Category', value: categoryName),
              _DetailRow(label: 'Counterparty', value: counterParty ?? ''),
              if (note != null && note.isNotEmpty)
                _DetailRow(label: 'Note', value: note),

              // Labels
              if (labelNames.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Labels',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final name in labelNames)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.divider(Theme.of(context).brightness),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          name,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              // Divider
              const SizedBox(height: AppSpacing.s6),
              Container(
                height: 2,
                color: AppColors.divider(Theme.of(context).brightness),
              ),
              const SizedBox(height: AppSpacing.s6),

              // State + Created
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'State',
                    style: AppTypography.body.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: const BoxDecoration(color: AppColors.accent100),
                    child: Text(
                      'Succeeded',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created',
                    style: AppTypography.body.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    _formatTime(mutation.createdAtEpochMs),
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

  String _formatDateOnly(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    ).toLocal();
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _capitalizeKind(String kind) {
    if (kind.isEmpty) return kind;
    return kind[0].toUpperCase() + kind.substring(1);
  }

  String _formatPaymentType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.neutral600),
          ),
          Text(
            value.isEmpty ? '\u2014' : value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SuccessSummary extends StatelessWidget {
  const _SuccessSummary({
    required this.amountText,
    required this.title,
    required this.categoryName,
    required this.accountName,
    required this.dateText,
  });

  final String amountText;
  final String title;
  final String categoryName;
  final String accountName;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final showCategoryLine = title != categoryName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Added to Wallet" label
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Added to Wallet',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),

          // Amount
          Text(amountText, style: AppTypography.amount),

          // Title
          const SizedBox(height: 2),
          Text(
            showCategoryLine ? '$title \u203a $categoryName' : title,
            style: AppTypography.body,
          ),

          // Account + date
          const SizedBox(height: 4),
          Text(
            'Added to $accountName on $dateText',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
