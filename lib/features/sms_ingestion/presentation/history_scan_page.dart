import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/features/sms_ingestion/presentation/history_import_controller.dart';

class HistoryImportPage extends ConsumerStatefulWidget {
  const HistoryImportPage({super.key});

  @override
  ConsumerState<HistoryImportPage> createState() => _HistoryImportPageState();
}

class _HistoryImportPageState extends ConsumerState<HistoryImportPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyImportProvider);
    final controller = ref.read(historyImportProvider.notifier);

    if (state.terminalResult != null) {
      return _ResultView(state: state, controller: controller);
    }

    final hasTracked = state.trackedSenders.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Import from messages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tracked senders',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context
                            .push('/settings/tracked-senders')
                            .then((_) => controller.reloadTrackedSenders()),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (!hasTracked)
                    Text(
                      'No senders tracked yet.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final sender in state.trackedSenders)
                          Chip(
                            label: Text(sender),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [3, 7, 14].map((days) {
                      final selected =
                          state.preset == days && state.customDays == null;
                      return ChoiceChip(
                        label: Text('$days days'),
                        selected: selected,
                        onSelected: (_) => controller.selectPreset(days),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Custom',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final d = int.tryParse(v);
                            if (d != null) controller.setCustomDays(d);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maximum',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: state.messageCap.toDouble(),
                          min: 10,
                          max: 500,
                          divisions: 49,
                          label: '${state.messageCap}',
                          onChanged: (v) => controller.setMessageCap(v.toInt()),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${state.messageCap}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (state.isScanning) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Stored: ${state.imported}'),
                  if (state.filtered > 0)
                    Text('Not recognised: ${state.filtered}'),
                  if (state.duplicates > 0)
                    Text('Already imported: ${state.duplicates}'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => controller.cancelImport(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Text(
                    'Only messages from tracked senders are read. '
                    'Your inbox is never changed.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (hasTracked)
                    FilledButton.icon(
                      onPressed: () => controller.startImport(),
                      icon: const Icon(Icons.download),
                      label: Text(
                        'Find messages (${state.windowDays}d, ${state.messageCap} max)',
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => context
                          .push('/settings/tracked-senders')
                          .then((_) => controller.reloadTrackedSenders()),
                      icon: const Icon(Icons.alternate_email),
                      label: const Text('Choose senders to track first'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultView extends StatefulWidget {
  const _ResultView({required this.state, required this.controller});

  final HistoryImportState state;
  final HistoryImportController controller;

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  bool _showSkipExplanation = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;
    final t = state.terminalResult;
    final icon = switch (t) {
      TerminalResult.completed => Icons.check_circle_outline,
      TerminalResult.cancelled => Icons.cancel_outlined,
      TerminalResult.capReached => Icons.warning_amber,
      TerminalResult.error => Icons.error_outline,
      TerminalResult.blocked => Icons.shield_outlined,
      TerminalResult.noTrackedSenders => Icons.alternate_email,
      null => Icons.info_outline,
    };
    final title = switch (t) {
      TerminalResult.completed => 'Import finished',
      TerminalResult.cancelled => 'Import cancelled',
      TerminalResult.capReached => 'Limit reached',
      TerminalResult.error => 'Import failed',
      TerminalResult.blocked => 'Import blocked',
      TerminalResult.noTrackedSenders => 'No tracked senders',
      null => 'Done',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: t == TerminalResult.completed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                t == TerminalResult.noTrackedSenders
                    ? 'Nothing was read. Choose at least one sender to track.'
                    : '${state.imported} stored · '
                          '${state.filtered} not recognised as transactions · '
                          '${state.duplicates} already imported',
                textAlign: TextAlign.center,
              ),
              if (t != TerminalResult.noTrackedSenders &&
                  state.filtered > 0) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(
                    () => _showSkipExplanation = !_showSkipExplanation,
                  ),
                  child: const Text('Why were some messages skipped?'),
                ),
                if (_showSkipExplanation)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'One-time passwords, promotions, and messages that do '
                      'not look like a bank transaction are never stored, so '
                      'they cannot appear in your inbox. If you expected a '
                      'message here, check that its sender is tracked and '
                      'that it contains an amount.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: 32),
              if (t == TerminalResult.noTrackedSenders)
                FilledButton(
                  onPressed: () {
                    controller.reset();
                    context.push('/settings/tracked-senders');
                  },
                  child: const Text('Choose senders'),
                )
              else
                FilledButton(
                  onPressed: () => controller.reset(),
                  child: const Text('Done'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
