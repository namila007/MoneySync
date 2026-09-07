import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/errors/domain_failure.dart';
import 'package:money_sync/core/logging/log_levels.dart';

final _log = Logger('wallet.discard.ui');

/// Wraps a wallet-sync list row in swipe-left-to-delete. The delete runs
/// inside `confirmDismiss` (via [DiscardWalletMutation]) so the row only
/// animates away after the write commits; an in-flight record is refused with
/// a snackbar and the row springs back. [onDiscarded] lets the parent hide
/// the row locally until the backing stream catches up.
class DiscardableMutationTile extends ConsumerWidget {
  const DiscardableMutationTile({
    super.key,
    required this.mutationId,
    required this.onDiscarded,
    required this.child,
  });

  final String mutationId;
  final VoidCallback onDiscarded;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('discard-$mutationId'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) => _confirmAndDiscard(context, ref),
      onDismissed: (_) => onDiscarded(),
      child: child,
    );
  }

  Future<bool> _confirmAndDiscard(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this record?'),
        content: const Text(
          'It is removed from this list. Your Wallet transactions are not '
          'changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      final discard = await ref.read(discardWalletMutationProvider.future);
      await discard(mutationId: mutationId);
      return true;
    } on WalletMutationInFlightFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.safeMessage)));
      }
      return false;
    } on Object catch (e, st) {
      _log.error('Discard failed for $mutationId', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the record.')),
        );
      }
      return false;
    }
  }
}
