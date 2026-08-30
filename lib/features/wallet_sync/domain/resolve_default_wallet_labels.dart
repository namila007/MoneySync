import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';

final _log = Logger('wallet.labels');

/// Resolves and ensures the presence of default wallet labels (money_sync + optional test).
///
/// Adds the `money_sync` label (and `test`, under the E2E flag) to the
/// user's selected labels, creating either in Wallet if absent. A label that
/// cannot be resolved is dropped, not fatal — a missing label must never
/// block recording a real transaction.
Future<List<String>> resolveDefaultWalletLabels(
  WalletRepository repository,
  List<String> selectedLabelIds,
) async {
  final ids = {...selectedLabelIds};
  for (final name in [
    'money_sync',
    if (const bool.fromEnvironment('E2E_LABEL')) 'test',
  ]) {
    final id = await repository.ensureLabel(name);
    if (id == null) {
      _log.error('Could not resolve or create label: SafeErrorCode: $name');
      continue;
    }
    ids.add(id);
  }
  return ids.toList(growable: false);
}
