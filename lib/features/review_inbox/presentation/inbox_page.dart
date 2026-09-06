import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/app/theme/app_colors.dart';
import 'package:money_sync/app/theme/app_typography.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_controller.dart';
import 'package:money_sync/features/sms_ingestion/application/delete_imported_message.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(inboxEventsProvider);
    final view = ref.watch(inboxViewProvider);
    final viewController = ref.read(inboxViewProvider.notifier);
    final filtersActive =
        view.senderFilter != null || view.dateRangeFilter != null;
    final flatLayout =
        view.layout == InboxLayout.flatNewestFirst || filtersActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alerts', style: AppTypography.display),
                const SizedBox(height: 4),
                Text(
                  '${eventsAsync.value?.length ?? 0} messages waiting',
                  style: AppTypography.body.copyWith(
                    color: AppColors.text.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
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

/// Search input + filter icon + calendar icon, matching the design artifact.
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.viewController});

  final InboxViewController viewController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(inboxViewProvider);
    final range = view.dateRangeFilter;
    final hasFilters = view.senderFilter != null || range != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search senders...',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
              onChanged: (value) => viewController.setSenderFilter(
                value.isEmpty ? null : value,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Filter',
            icon: const Icon(Icons.filter_list, size: 18),
            onPressed: () async {
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
          ),
          IconButton(
            tooltip: 'Date range',
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            onPressed: () async {
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
          ),
          if (hasFilters)
            IconButton(
              tooltip: 'Clear filters',
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              onPressed: viewController.clearFilters,
            ),
          IconButton(
            tooltip: view.layout == InboxLayout.groupedBySender
                ? 'Switch to flat list'
                : 'Switch to grouped by sender',
            icon: Icon(
              view.layout == InboxLayout.groupedBySender
                  ? Icons.view_agenda_outlined
                  : Icons.view_list_outlined,
              size: 18,
            ),
            onPressed: viewController.toggleLayout,
          ),
        ],
      ),
    );
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
        return _EventCard(event: events[index]);
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
        ..addAll([for (final event in shown) _EventCard(event: event)]);

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

/// Card-style event tile matching the design artifact: sender + amount row,
/// time, body text, status tag.
class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});

  final SmsEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderName = event.senderDisplay ?? event.senderKey;
    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      confirmDismiss: (_) async {
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
        return confirmed ?? false;
      },
      onDismissed: (_) => _delete(context, ref),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: () => context.push('/inbox/detail/${event.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(event.receivedAtEpochMs),
                  style: AppTypography.micro.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.encryptedBody ?? event.redactedBody ?? '(no body)',
                  style: AppTypography.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                StatusChip(status: event.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;
    final setting = await (db.select(
      db.appSettings,
    )..where((row) => row.singletonId.equals(1))).getSingle();
    final useCase = DeleteImportedMessage(database: db);
    await useCase(
      eventId: event.id,
      privacyEpoch: setting.privacyEpoch,
    );
    ref.invalidate(inboxEventsProvider);
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
    final label = switch (status) {
      SmsEventStatus.captured => 'Imported',
      SmsEventStatus.review => 'Pending Review',
      SmsEventStatus.interpreted => 'Interpreted',
      SmsEventStatus.ignored => 'Ignored',
      SmsEventStatus.purged => 'Purged',
    };
    // Design artifact: review = outline (border + text), others = filled
    if (status == SmsEventStatus.review) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent),
        ),
        child: Text(
          label,
          style: AppTypography.micro.copyWith(color: AppColors.accent),
        ),
      );
    }
    final (bg, fg) = switch (status) {
      SmsEventStatus.captured => (AppColors.neutral100, AppColors.neutral800),
      SmsEventStatus.interpreted => (
        AppColors.success.withValues(alpha: 0.12),
        AppColors.success,
      ),
      SmsEventStatus.ignored => (
        AppColors.neutral200,
        AppColors.neutral600,
      ),
      SmsEventStatus.purged => (
        AppColors.warning.withValues(alpha: 0.12),
        AppColors.warning,
      ),
      SmsEventStatus.review => (AppColors.accent100, AppColors.accent800),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg),
      child: Text(
        label,
        style: AppTypography.micro.copyWith(color: fg),
      ),
    );
  }
}
