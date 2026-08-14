import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/features/sms_ingestion/data/sms_history_pigeon.g.dart';
import 'package:money_sync/features/sms_tracking/presentation/tracked_senders_controller.dart';

class TrackedSendersPage extends ConsumerStatefulWidget {
  const TrackedSendersPage({super.key, this.loadDeviceSenders});

  /// Device-sender source, injectable for widget tests (the pigeon channel
  /// never completes in the test harness).
  final Future<List<String>> Function()? loadDeviceSenders;

  @override
  ConsumerState<TrackedSendersPage> createState() => _TrackedSendersPageState();
}

class _TrackedSendersPageState extends ConsumerState<TrackedSendersPage> {
  List<String> _deviceSenders = const [];
  bool _loadingSenders = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDeviceSenders());
  }

  Future<void> _loadDeviceSenders() async {
    setState(() => _loadingSenders = true);
    try {
      final loader =
          widget.loadDeviceSenders ??
          () async => (await SmsHistoryHostApi().distinctSenders())
              .whereType<String>()
              .toList();
      final senders = await loader();
      if (mounted) {
        setState(() {
          _deviceSenders = senders;
          _loadingSenders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSenders = false);
    }
  }

  Future<void> _saveAndPop() async {
    final notifier = ref.read(trackedSendersControllerProvider.notifier);
    await notifier.save();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackedAsync = ref.watch(trackedSendersControllerProvider);
    final tracked = trackedAsync.value ?? const <String>[];

    final candidates = <String>[
      ..._deviceSenders,
      ...tracked.where((a) => !_deviceSenders.contains(a)),
    ];
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? candidates
        : candidates.where((s) => s.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracked senders'),
        actions: [
          Center(
            child: Text(
              '${tracked.length} selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: 'Save (${tracked.length} selected)',
            icon: const Icon(Icons.check),
            onPressed: _saveAndPop,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Only messages from senders you choose are ever read. '
            'Nothing else is loaded from your SMS inbox.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search sender name\u2026',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          if (_loadingSenders)
            const LinearProgressIndicator()
          else if (candidates.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No senders tracked yet. Pick at least one to import messages.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else if (filtered.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No senders match \u201c$_query\u201d.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final sender in filtered)
                    CheckboxListTile(
                      value: tracked.contains(sender),
                      onChanged: (_) => ref
                          .read(trackedSendersControllerProvider.notifier)
                          .toggle(sender),
                      title: Text(sender),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
