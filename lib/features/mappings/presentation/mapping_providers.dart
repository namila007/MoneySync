import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/mappings/data/drift_mapping_rule_store.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/use_cases/save_mapping_rule.dart';
import 'package:money_sync/features/wallet_connection/data/drift_wallet_catalog_cache.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

final log = Logger('mappings');

final mappingRuleStoreProvider = FutureProvider<MappingRuleStore>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftMappingRuleStore(database: db);
});

final mappingRuleListProvider = FutureProvider<List<MappingRule>>((ref) async {
  final store = await ref.watch(mappingRuleStoreProvider.future);
  try {
    final rules = await store.list();
    log.info('Loaded ${rules.length} mapping rule(s)');
    return rules;
  } catch (e, s) {
    log.error('Failed to load mapping rules', e, s);
    rethrow;
  }
});

final saveMappingRuleProvider = FutureProvider<SaveMappingRule>((ref) async {
  final store = await ref.watch(mappingRuleStoreProvider.future);
  return SaveMappingRule(store: store);
});

/// Wallet account/category cache for target selection. Null until the Wallet
/// is connected; the editor shows an explainer instead of a target picker.
final walletCatalogCacheProvider = FutureProvider<WalletCatalogCache?>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return DriftWalletCatalogCache(database: db);
});

/// Wallet catalog cache. One-shot read — invalidation is explicit after
/// connect/refresh in WalletConnectionController._logActivity and
/// the wallet connection page (Bug 2). Upgrade to StreamProvider when
/// Riverpod's StreamProvider.future resolves synchronously in tests.
final walletCatalogProvider = FutureProvider<WalletCatalog?>((ref) async {
  final cache = await ref.watch(walletCatalogCacheProvider.future);
  return cache?.read();
});
