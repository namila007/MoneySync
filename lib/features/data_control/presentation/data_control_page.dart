import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/features/data_control/domain/data_clear_scope.dart';
import 'package:money_sync/features/data_control/presentation/data_control_controller.dart';
import 'package:money_sync/features/settings/domain/configuration.dart';
import 'package:money_sync/features/settings/presentation/configuration_providers.dart';

class DataControlPage extends ConsumerWidget {
  const DataControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataControlControllerProvider);
    final controller = ref.read(dataControlControllerProvider.notifier);
    final configAsync = ref.watch(configurationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          configAsync.when(
            data: (config) => config != null
                ? _RetentionSection(config: config)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          _ClearActivityCard(
            busy:
                state is DataControlBusy &&
                state.scope == DataClearScope.clearActivity,
            onClear: () => _confirmClearActivity(context, controller),
          ),
          const SizedBox(height: 16),
          _ResetLocalDataCard(
            busy:
                state is DataControlBusy &&
                state.scope == DataClearScope.resetAllLocalData,
            onReset: () => _confirmResetAll(context, controller),
          ),
          if (state is DataControlSuccess) ...[
            const SizedBox(height: 16),
            _ResultBanner(
              success: true,
              message: state.scope == DataClearScope.clearActivity
                  ? 'Activity cleared.'
                  : 'All local data reset. The app will restart.',
              onDismiss: () => controller.resetToIdle(),
            ),
          ],
          if (state is DataControlPartialFailure) ...[
            const SizedBox(height: 16),
            _PartialFailureBanner(
              failure: state,
              onRetry: () {
                controller.resetToIdle();
                controller.resetAllLocalData();
              },
              onDismiss: () => controller.resetToIdle(),
            ),
          ],
          if (state is DataControlFailure) ...[
            const SizedBox(height: 16),
            _ResultBanner(
              success: false,
              message: state.errorMessage,
              onDismiss: () => controller.resetToIdle(),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClearActivity(
    BuildContext context,
    DataControlController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear activity?'),
        content: const Text(
          'Removes local activity and decision traces from this device. '
          'Keeps settings, onboarding, mappings, security keys, and '
          'cached metadata. Inbox SMS and Wallet records are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.clearActivity();
            },
            child: const Text('Clear activity'),
          ),
        ],
      ),
    );
  }

  void _confirmResetAll(
    BuildContext context,
    DataControlController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: const Text('Reset all local data?'),
        content: const Text(
          'This deletes the database, security keys, wallet token, '
          'caches, mappings, logs, and all local copies. '
          'Inbox SMS and remote Wallet records are not changed. '
          'The app will restart after reset.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.resetAllLocalData();
            },
            child: const Text('Reset everything'),
          ),
        ],
      ),
    );
  }
}

class _ClearActivityCard extends StatelessWidget {
  const _ClearActivityCard({required this.busy, required this.onClear});

  final bool busy;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Clear activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const ListTile(
              subtitle: Text(
                'Removes local activity and traces. '
                'Keeps settings, keys, and cached data.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: busy ? null : onClear,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cleaning_services_outlined),
                label: Text(busy ? 'Clearing...' : 'Clear activity...'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ResetLocalDataCard extends StatelessWidget {
  const _ResetLocalDataCard({required this.busy, required this.onReset});

  final bool busy;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Reset MoneySync',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const ListTile(
              subtitle: Text(
                'Deletes app data, token, caches, mappings, '
                'and local copies. Does not delete inbox SMS or '
                'remote Wallet records.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonalIcon(
                onPressed: busy ? null : onReset,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_forever_outlined),
                label: Text(busy ? 'Resetting...' : 'Reset local data...'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.success,
    required this.message,
    required this.onDismiss,
  });

  final bool success;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: success
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}

class _PartialFailureBanner extends StatelessWidget {
  const _PartialFailureBanner({
    required this.failure,
    required this.onRetry,
    required this.onDismiss,
  });

  final DataControlPartialFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Partial reset — ${failure.succeeded} of '
                    '${failure.succeeded + failure.failed} steps completed',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            ...failure.details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text('• $d'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
                const SizedBox(width: 8),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RetentionSection extends ConsumerWidget {
  const _RetentionSection({required this.config});
  final ConfigurationState config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Local copy retention',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          title: const Text('Raw app copy'),
          subtitle: Text(
            config.retention.rawCopyDays > 0
                ? 'Keep for ${config.retention.rawCopyDays} days'
                : 'Purge after processing',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showRawCopyRetentionDialog(context, config, ref),
        ),
        ListTile(
          title: const Text('Activity history'),
          subtitle: Text('${config.retention.activityRetentionDays} days'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showActivityRetentionDialog(context, config, ref),
        ),
      ],
    );
  }
}

void _showRawCopyRetentionDialog(
  BuildContext context,
  ConfigurationState config,
  WidgetRef ref,
) {
  var selected = config.retention.rawCopyDays;
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Raw app copy retention'),
        content: RadioGroup<int>(
          groupValue: selected,
          onChanged: (v) {
            if (v == null) return;
            setState(() => selected = v);
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: Text('Purge after processing'),
                value: 0,
              ),
              RadioListTile<int>(title: Text('7 days'), value: 7),
              RadioListTile<int>(title: Text('14 days'), value: 14),
              RadioListTile<int>(title: Text('30 days'), value: 30),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref
                  .read(configurationRepositoryProvider)
                  .requireValue;
              await repo.updateRetention(
                RetentionPreferences(
                  rawCopyDays: selected,
                  activityRetentionDays: config.retention.activityRetentionDays,
                ),
              );
              ref.invalidate(configurationProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
}

void _showActivityRetentionDialog(
  BuildContext context,
  ConfigurationState config,
  WidgetRef ref,
) {
  var selected = config.retention.activityRetentionDays;
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Activity retention'),
        content: RadioGroup<int>(
          groupValue: selected,
          onChanged: (v) {
            if (v == null) return;
            setState(() => selected = v);
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(title: Text('90 days'), value: 90),
              RadioListTile<int>(title: Text('180 days'), value: 180),
              RadioListTile<int>(title: Text('365 days'), value: 365),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref
                  .read(configurationRepositoryProvider)
                  .requireValue;
              await repo.updateRetention(
                RetentionPreferences(
                  rawCopyDays: config.retention.rawCopyDays,
                  activityRetentionDays: selected,
                ),
              );
              ref.invalidate(configurationProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ),
  );
}
