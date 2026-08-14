import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/settings_app_bar_action.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_controller.dart';
import 'package:money_sync/features/sms_ingestion/application/delete_imported_message.dart';

/// The inbox list. All rows come from the [inboxEventsProvider] stream plus
/// pagination state in [InboxViewState]; the page holds no row cache — a
/// message imported while this screen is open appears without a refresh
/// (M4.14 WP1), and deletion reaches the DB so the stream re-emits without it.
class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(inboxEventsProvider);
    final view = ref.watch(inboxViewProvider);
    final viewController = ref.read(inboxViewProvider.notifier);
    final filtersActive =
        view.senderFilter != null || view.dateRangeFilter != null;
    // Grouped headers use global sender totals; those would lie under a
    // filter, so an active filter renders the flat list (M4.15 WP2).
    final flatLayout =
        view.layout == InboxLayout.flatNewestFirst || filtersActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          if (!filtersActive)
            IconButton(
              tooltip: view.layout == InboxLayout.groupedBySender
                  ? 'Switch to flat list'
                  : 'Switch to grouped by sender',
              icon: Icon(
                view.layout == InboxLayout.groupedBySender
                    ? Icons.view_agenda_outlined
                    : Icons.view_list_outlined,
              ),
              onPressed: viewController.toggleLayout,
            ),
          const SettingsAppBarAction(),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(viewController: viewController),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load inbox: $e')),
              data: (firstPage) {
                final flatMerged = _merge(firstPage, view.flatMore);
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(inboxEventsProvider);
                    await ref.read(inboxEventsProvider.future);
                  },
                  child: flatMerged.isEmpty
                      ? const _EmptyInbox()
                      : flatLayout
                      ? _FlatList(
                          firstPage: firstPage,
                          view: view,
                          viewController: viewController,
                        )
                      : _GroupedList(
                          firstPage: firstPage,
                          view: view,
                          viewController: viewController,
                        ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/inbox/import'),
        tooltip: 'Add a message',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// First-page rows win over deeper pages; a row that drifted out of the
  /// live first page but is already loaded deeper must not render twice.
  static List<SmsEvent> _merge(List<SmsEvent> firstPage, List<SmsEvent> more) {
    if (more.isEmpty) return firstPage;
    final seen = firstPage.map((e) => e.id).toSet();
    return [
      ...firstPage,
      for (final e in more)
        if (seen.add(e.id)) e,
    ];
  }
}

/// Sender + date-range filters (M4.15 WP2). The sender list comes from the
/// live per-sender summaries; the date range uses the Material picker.
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.viewController});

  final InboxViewController viewController;

  static const _allSenders = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(inboxViewProvider);
    final summaries =
        ref.watch(inboxSenderSummariesProvider).value ??
        const <SmsEventSenderSummary>[];
    final range = view.dateRangeFilter;
    final hasFilters = view.senderFilter != null || range != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DropdownButton<String>(
              value: view.senderFilter ?? _allSenders,
              underline: const SizedBox.shrink(),
              isDense: true,
              items: [
                const DropdownMenuItem(
                  value: _allSenders,
                  child: Text('All senders'),
                ),
                for (final s in summaries)
                  DropdownMenuItem(
                    value: s.senderKey,
                    child: Text(
                      s.senderDisplay ?? s.senderKey,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => viewController.setSenderFilter(
                value == _allSenders ? null : value,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange: range,
                  helpText: 'Filter messages by received date',
                );
                if (picked != null) {
                  viewController.setDateRangeFilter(picked);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(_dateLabel(range)),
                  ],
                ),
              ),
            ),
            if (hasFilters)
              IconButton(
                tooltip: 'Clear filters',
                icon: const Icon(Icons.filter_alt_off_outlined),
                onPressed: viewController.clearFilters,
              ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTimeRange? range) {
    if (range == null) return 'Any date';
    String day(DateTime d) => '${d.day}/${d.month}/${d.year}';
    return '${day(range.start)} – ${day(range.end)}';
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No transaction candidates are available yet.\n'
            'Import messages from Settings → SMS & Tracking.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _FlatList extends StatelessWidget {
  const _FlatList({
    required this.firstPage,
    required this.view,
    required this.viewController,
  });

  final List<SmsEvent> firstPage;
  final InboxViewState view;
  final InboxViewController viewController;

  @override
  Widget build(BuildContext context) {
    final events = InboxPage._merge(firstPage, view.flatMore);
    final mayHaveMore =
        view.flatHasMore != false && events.length >= kInboxPageSize;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length + (mayHaveMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= events.length) {
          return _LoadMoreSentinel(
            onVisible: () => viewController.loadFlatMore(cursor: events.last),
          );
        }
        return _EventTile(event: events[index]);
      },
    );
  }
}

class _GroupedList extends ConsumerWidget {
  const _GroupedList({
    required this.firstPage,
    required this.view,
    required this.viewController,
  });

  final List<SmsEvent> firstPage;
  final InboxViewState view;
  final InboxViewController viewController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries =
        ref.watch(inboxSenderSummariesProvider).value ??
        const <SmsEventSenderSummary>[];
    final summaryByKey = {for (final s in summaries) s.senderKey: s};

    final grouped = <String, List<SmsEvent>>{};
    for (final event in firstPage) {
      grouped.putIfAbsent(event.senderKey, () => []).add(event);
    }

    final senderKeys = <String>[
      for (final s in summaries) s.senderKey,
      for (final key in grouped.keys)
        if (!summaryByKey.containsKey(key)) key,
    ];

    final sections = <Widget>[];
    for (final key in senderKeys) {
      final summary = summaryByKey[key];
      final preview = grouped[key] ?? const <SmsEvent>[];
      final more = view.senderMore[key] ?? const <SmsEvent>[];
      final allLoaded = InboxPage._merge(preview, more);
      final total = summary?.total ?? allLoaded.length;
      final expanded = view.expandedSenders.contains(key);
      final shown = expanded
          ? allLoaded
          : allLoaded.take(view.perSenderLimit).toList();

      sections
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              summary?.senderDisplay ?? key,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        )
        ..addAll([for (final event in shown) _EventTile(event: event)]);

      if (total > shown.length &&
          (expanded ? view.senderHasMore[key] != false : true)) {
        sections.add(
          TextButton(
            onPressed: () {
              if (!expanded) viewController.toggleExpanded(key);
              if (allLoaded.isNotEmpty) {
                viewController.loadSenderMore(
                  senderKey: key,
                  cursor: allLoaded.last,
                );
              }
            },
            child: Text('Show all ($total)'),
          ),
        );
      }
    }

    return ListView(padding: const EdgeInsets.all(12), children: sections);
  }
}

/// Spinner shown at the tail of the flat list; building it triggers the next
/// page load. The controller's re-entry guard makes repeat calls no-ops.
class _LoadMoreSentinel extends ConsumerWidget {
  const _LoadMoreSentinel({required this.onVisible});

  final VoidCallback onVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onVisible());
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event});

  final SmsEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('sms-${event.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: () => context.push('/inbox/detail/${event.id}'),
          leading: const Icon(Icons.sms_outlined),
          title: Text(
            event.redactedBody ?? '(no preview)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${event.senderDisplay ?? event.senderKey} · '
            '${_formatTime(event.receivedAtEpochMs)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: StatusChip(status: event.status),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this imported message?'),
        content: const Text(
          'The app copy is removed. The SMS on your device is not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return false;
    final setting = await (db.select(
      db.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();
    final useCase = DeleteImportedMessage(database: db);
    final result = await useCase(
      eventId: event.id,
      privacyEpoch: setting.privacyEpoch,
    );
    return result is DeleteMessageDeleted;
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final SmsEventStatus status;

  @override
  Widget build(BuildContext context) {
    // Exhaustive switch: a new enum member is a compile error here, not a
    // blank chip (M4.14 §3.2).
    final label = switch (status) {
      SmsEventStatus.captured => 'Imported',
      SmsEventStatus.review => 'Review',
      SmsEventStatus.interpreted => 'Interpreted',
      SmsEventStatus.ignored => 'Ignored',
      SmsEventStatus.purged => 'Purged',
    };
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11),
      visualDensity: VisualDensity.compact,
    );
  }
}
