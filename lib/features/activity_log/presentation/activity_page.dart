import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(activityLogProvider);

    return Scaffold(
      appBar: const _ActivityAppBar(),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const _ActivityMessage(
          text:
              'Activity could not be read from local storage. '
              'Nothing has been lost — try again later.',
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const _ActivityMessage(
              text:
                  'No activity yet. Local events such as data deletion and '
                  'retention clean-up will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(activityLogProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _ActivityTile(entry: entries[index]),
            ),
          );
        },
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
      title: Text(_labelFor(entry.code)),
      subtitle: Text(_detailFor(entry.detail)),
      trailing: Text(
        _formatTimestamp(entry.occurredAt.toLocal()),
        style: Theme.of(context).textTheme.bodySmall,
      ),
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
  ActivityEventCode.walletRecordCreated => 'Wallet record created',
  ActivityEventCode.logInfo => 'App event',
  ActivityEventCode.logWarning => 'App warning',
  ActivityEventCode.logError => 'App error',
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
  ActivityEventCode.logInfo => Icons.info_outline,
  ActivityEventCode.logWarning => Icons.warning_amber_outlined,
  ActivityEventCode.logError => Icons.error_outline,
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
