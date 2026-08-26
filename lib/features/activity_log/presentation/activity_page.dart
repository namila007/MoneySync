import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  ActivityEventCode? _filter;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(filteredActivityLogProvider(_filter));
    final log = Logger('activity');

    return Scaffold(
      appBar: const _ActivityAppBar(),
      body: Column(
        children: [
          _FilterBar(
            selected: _filter,
            onChanged: (code) => setState(() => _filter = code),
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                log.error('[activity] Provider error', error, stack);
                return const _ActivityMessage(
                  text:
                      'Activity could not be read from local storage. '
                      'Nothing has been lost — try again later.',
                );
              },
              data: (entries) {
                if (entries.isEmpty) {
                  return const _ActivityMessage(
                    text:
                        'No activity here yet. Local events such as data '
                        'deletion and retention clean-up will appear.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredActivityLogProvider(_filter));
                    await ref.read(filteredActivityLogProvider(_filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _ActivityTile(entry: entries[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chips by [ActivityEventCode] (M5.12). Null = all.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final ActivityEventCode? selected;
  final ValueChanged<ActivityEventCode?> onChanged;

  static const _options = <(ActivityEventCode?, String)>[
    (null, 'All'),
    (ActivityEventCode.walletRecordCreated, 'Created'),
    (ActivityEventCode.candidateNeedsReview, 'Review'),
    (ActivityEventCode.logError, 'Errors'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final (code, label) in _options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: selected == code,
                onSelected: (_) => onChanged(code),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_iconFor(entry.code)),
      title: Text(
        // Aggregated batch events (M4.15 WP3) carry their size in the tile.
        entry.count != null && entry.code == ActivityEventCode.messageImported
            ? '${entry.count} messages imported'
            : _labelFor(entry.code),
      ),
      subtitle: Text(entry.detailMessage ?? _detailFor(entry.detail)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(entry.occurredAt.toLocal()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          // Recovery only for rows that reference a REAL outbox mutation; a
          // fabricated id would target a non-existent row (M5.14 gap 5).
          if (entry.mutationId case final mutationId?)
            _RecoveryActions(mutationId: mutationId),
        ],
      ),
    );
  }
}

/// Looks up the current [WalletMutationState] for a mutation id.
/// Returns null if the mutation doesn't exist (e.g. pre-v10 log-derived rows).
final _mutationStateProvider = FutureProvider.autoDispose
    .family<WalletMutationState?, String>((ref, mutationId) async {
      final db = await ref.watch(appDatabaseProvider.future);
      final rows = await (db.select(
        db.walletMutations,
      )..where((m) => m.id.equals(mutationId))).get();
      return rows.isEmpty ? null : rows.first.state;
    });

/// "Retry now" / "Verify in Wallet" dispatched through the recovery-actions
/// port with the REAL outbox mutation id — the activity page never owns
/// mutation logic (M5.12/M5.14).
///
/// Buttons are gated on mutation state: Retry only for `retryScheduled`,
/// Verify only for `unknown*` states. Terminal states (succeeded,
/// permanentFailure, supersededBeforeSend) show no buttons.
class _RecoveryActions extends ConsumerWidget {
  const _RecoveryActions({required this.mutationId});

  final String mutationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(_mutationStateProvider(mutationId));
    final actionsAsync = ref.watch(activityRecoveryActionsProvider);

    return stateAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        if (state == null) return const SizedBox.shrink();

        final showRetry = state == WalletMutationState.retryScheduled;
        final showVerify = switch (state) {
          WalletMutationState.unknownDelivery ||
          WalletMutationState.unknownUpdate ||
          WalletMutationState.unknownDelete => true,
          _ => false,
        };

        if (!showRetry && !showVerify) return const SizedBox.shrink();

        return Wrap(
          spacing: 4,
          children: [
            if (showRetry)
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: actionsAsync.hasValue
                    ? () => actionsAsync.requireValue.retryNow(mutationId)
                    : null,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            if (showVerify)
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: actionsAsync.hasValue
                    ? () => actionsAsync.requireValue.verifyInWallet(mutationId)
                    : null,
                icon: const Icon(Icons.verified_user_outlined, size: 16),
                label: const Text('Verify'),
              ),
          ],
        );
      },
    );
  }
}

/// Two-digit padded local timestamp. Deliberately not locale-formatted so the
/// widget has no dependency on an initialised locale in tests.
String _formatTimestamp(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}';
}

String _labelFor(ActivityEventCode code) => switch (code) {
  ActivityEventCode.privacyEpochAdvanced => 'Local data cleared',
  ActivityEventCode.rawCopyPurged => 'Message copy removed',
  ActivityEventCode.activityRetentionApplied => 'Old activity removed',
  ActivityEventCode.candidateNeedsReview => 'Transaction needs review',
  ActivityEventCode.walletRecordQueued => 'Saved to Waiting',
  ActivityEventCode.walletRecordCreated => 'Wallet record created',
  ActivityEventCode.walletRecordFailed => 'Wallet record not created',
  ActivityEventCode.walletConnected => 'Wallet connected',
  ActivityEventCode.walletDisconnected => 'Wallet disconnected',
  ActivityEventCode.walletRefreshed => 'Wallet refreshed',
  ActivityEventCode.mappingRuleCreated => 'Mapping rule created',
  ActivityEventCode.logInfo => 'App event',
  ActivityEventCode.logWarning => 'App warning',
  ActivityEventCode.logError => 'App error',
  ActivityEventCode.messageImported => 'Message imported',
  ActivityEventCode.smsEventDeleted => 'Imported message deleted',
};

String _detailFor(ActivityStateTransition detail) => switch (detail) {
  ActivityStateTransition.rawCopyPurged =>
    'A temporary message copy was deleted.',
  ActivityStateTransition.privacyEpochAdvanced =>
    'Earlier local data was retired.',
  ActivityStateTransition.needsReview => 'Waiting for your review.',
  ActivityStateTransition.logEvent => 'Recorded on this device.',
};

IconData _iconFor(ActivityEventCode code) => switch (code) {
  ActivityEventCode.privacyEpochAdvanced => Icons.auto_delete_outlined,
  ActivityEventCode.rawCopyPurged => Icons.cleaning_services_outlined,
  ActivityEventCode.activityRetentionApplied => Icons.history_toggle_off,
  ActivityEventCode.candidateNeedsReview => Icons.rate_review_outlined,
  ActivityEventCode.walletRecordCreated =>
    Icons.account_balance_wallet_outlined,
  ActivityEventCode.walletRecordQueued => Icons.schedule_outlined,
  ActivityEventCode.walletRecordFailed => Icons.error_outline,
  ActivityEventCode.walletConnected => Icons.link,
  ActivityEventCode.walletDisconnected => Icons.link_off,
  ActivityEventCode.walletRefreshed => Icons.refresh,
  ActivityEventCode.mappingRuleCreated => Icons.rule_outlined,
  ActivityEventCode.logInfo => Icons.info_outline,
  ActivityEventCode.logWarning => Icons.warning_amber_outlined,
  ActivityEventCode.logError => Icons.error_outline,
  ActivityEventCode.messageImported => Icons.sms_outlined,
  ActivityEventCode.smsEventDeleted => Icons.delete_outline,
};

class _ActivityMessage extends StatelessWidget {
  const _ActivityMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ActivityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ActivityAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Activity'),
    actions: const [SettingsAppBarAction()],
  );
}
