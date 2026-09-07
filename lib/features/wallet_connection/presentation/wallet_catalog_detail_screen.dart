import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

enum WalletCatalogDetailMode { accounts, categories, eligibleTargets }

class WalletCatalogDetailScreen extends ConsumerWidget {
  const WalletCatalogDetailScreen({required this.mode, super.key});

  final WalletCatalogDetailMode mode;

  String _title() => switch (mode) {
    WalletCatalogDetailMode.accounts => 'Accounts',
    WalletCatalogDetailMode.categories => 'Categories',
    WalletCatalogDetailMode.eligibleTargets => 'Eligible targets',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(walletCatalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load catalog.')),
        data: (catalog) {
          if (catalog == null) {
            return const Center(child: Text('No catalog data.'));
          }
          return switch (mode) {
            WalletCatalogDetailMode.accounts => _AccountList(
              accounts: catalog.accounts,
            ),
            WalletCatalogDetailMode.categories => _CategoryList(
              categories: catalog.categories,
            ),
            WalletCatalogDetailMode.eligibleTargets => _AccountList(
              accounts: catalog.accounts
                  .where(
                    (a) => a.eligibility == WalletAccountEligibility.eligible,
                  )
                  .toList(),
              emptyMessage: 'No eligible targets.',
            ),
          };
        },
      ),
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList({required this.accounts, this.emptyMessage});

  final List<WalletAccount> accounts;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ?? 'No accounts in catalog.',
          style: AppTypography.body.copyWith(color: AppColors.neutral500),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: const BoxDecoration(color: AppColors.surface),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  account.name,
                  style: AppTypography.h5.copyWith(fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 1),
                ),
                child: Text(
                  account.currencyCode,
                  style: AppTypography.micro.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories});

  final List<WalletCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories in catalog.'));
    }

    final grouped = <String, List<WalletCategory>>{};
    for (final c in categories) {
      grouped.putIfAbsent(c.groupId, () => []).add(c);
    }
    final groupIds = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        final customCats = groupCats.where((c) => c.customCategory).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.only(left: 24, right: 12),
            title: Text(
              groupName,
              style: AppTypography.h5.copyWith(
                fontSize: 15,
                color: AppColors.accent,
              ),
            ),
            iconColor: AppColors.accent,
            collapsedIconColor: AppColors.accent,
            children: [
              for (final cat in baseCats) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '\u2014',
                        style: AppTypography.body.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(cat.name, style: AppTypography.body),
                      ),
                    ],
                  ),
                ),
                for (final sub in customCats.where((c) => c.parentId == cat.id))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          '\u2014',
                          style: AppTypography.body.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(sub.name, style: AppTypography.body),
                        ),
                      ],
                    ),
                  ),
              ],
              for (final sub in customCats.where(
                (c) => !baseCats.any((b) => b.id == c.parentId),
              ))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '\u2014',
                        style: AppTypography.body.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(sub.name, style: AppTypography.body),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
