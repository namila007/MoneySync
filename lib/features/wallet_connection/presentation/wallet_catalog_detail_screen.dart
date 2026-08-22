import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

/// Read-only detail screens for the wallet connection metadata rows
/// (Accounts / Categories / Eligible targets). Bug 3.
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
      appBar: AppBar(title: Text(_title())),
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
        child: Text(emptyMessage ?? 'No accounts in catalog.'),
      );
    }
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return ListTile(
          leading: Icon(
            account.isBankSynced
                ? Icons.sync
                : account.isArchived
                    ? Icons.archive_outlined
                    : Icons.account_balance_wallet_outlined,
          ),
          title: Text(account.name),
          subtitle: Text(account.currencyCode),
          trailing: _EligibilityBadge(eligibility: account.eligibility),
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
    // Flat alphabetical list — the v1.3.0 API has no parent field.
    final sorted = List<WalletCategory>.of(categories)
      ..sort((a, b) => a.name.compareTo(b.name));
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final category = sorted[index];
        return ListTile(
          leading: const Icon(Icons.label_outlined),
          title: Text(category.name),
        );
      },
    );
  }
}

class _EligibilityBadge extends StatelessWidget {
  const _EligibilityBadge({required this.eligibility});

  final WalletAccountEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (eligibility) {
      WalletAccountEligibility.eligible => ('Eligible', Colors.green),
      WalletAccountEligibility.archived => ('Archived', Colors.grey),
      WalletAccountEligibility.bankSynced => ('Bank-synced', Colors.blue),
      WalletAccountEligibility.unwritable => ('Not writable', Colors.orange),
      WalletAccountEligibility.missingRequiredFields => ('Incomplete', Colors.orange),
      WalletAccountEligibility.foreignCurrencyReviewOnly => ('Review only', Colors.orange),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
