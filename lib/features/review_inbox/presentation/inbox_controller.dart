import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';

enum InboxLayout { groupedBySender, flatNewestFirst }

const kInboxPageSize = 25; // flat list page (and the streamed first page)
const kInboxSenderPreview = 5; // grouped: rows before "Show all"
const kInboxSenderPageSize = 25; // grouped: rows added per "Show all" tap

final class InboxViewState {
  const InboxViewState({
    this.layout = InboxLayout.groupedBySender,
    this.expandedSenders = const {},
    this.perSenderLimit = kInboxSenderPreview,
    this.flatMore = const [],
    this.flatHasMore,
    this.flatLoadingMore = false,
    this.senderMore = const {},
    this.senderHasMore = const {},
    this.senderLoadingMore = const {},
    this.senderFilter,
    this.dateRangeFilter,
  });

  final InboxLayout layout;
  final Set<String> expandedSenders;
  final int perSenderLimit;

  /// Rows beyond the streamed first page (flat layout), newest-first.
  final List<SmsEvent> flatMore;

  /// null = unknown (first page may still have a next page); false = done.
  final bool? flatHasMore;
  final bool flatLoadingMore;

  /// Per-sender rows beyond the first page (grouped layout).
  final Map<String, List<SmsEvent>> senderMore;
  final Map<String, bool> senderHasMore;
  final Map<String, bool> senderLoadingMore;

  /// Active filters (M4.15 WP2). Null = no filter.
  final String? senderFilter;
  final DateTimeRange? dateRangeFilter;

  InboxViewState copyWith({
    InboxLayout? layout,
    Set<String>? expandedSenders,
    int? perSenderLimit,
    List<SmsEvent>? flatMore,
    bool? flatHasMore,
    bool? flatLoadingMore,
    Map<String, List<SmsEvent>>? senderMore,
    Map<String, bool>? senderHasMore,
    Map<String, bool>? senderLoadingMore,
    String? senderFilter,
    DateTimeRange? dateRangeFilter,
  }) {
    return InboxViewState(
      layout: layout ?? this.layout,
      expandedSenders: expandedSenders ?? this.expandedSenders,
      perSenderLimit: perSenderLimit ?? this.perSenderLimit,
      flatMore: flatMore ?? this.flatMore,
      flatHasMore: flatHasMore ?? this.flatHasMore,
      flatLoadingMore: flatLoadingMore ?? this.flatLoadingMore,
      senderMore: senderMore ?? this.senderMore,
      senderHasMore: senderHasMore ?? this.senderHasMore,
      senderLoadingMore: senderLoadingMore ?? this.senderLoadingMore,
      senderFilter: senderFilter ?? this.senderFilter,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
    );
  }
}

/// Day bounds of the picker range converted to UTC epoch ms. The picker
/// returns local midnights; stored epochs are UTC-based, so compare in UTC.
int? _rangeFromUtcMs(DateTimeRange? range) => range == null
    ? null
    : DateTime.utc(
        range.start.year,
        range.start.month,
        range.start.day,
      ).millisecondsSinceEpoch;

int? _rangeUntilUtcMs(DateTimeRange? range) => range == null
    ? null
    : DateTime.utc(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
        999,
      ).millisecondsSinceEpoch;

class InboxViewController extends Notifier<InboxViewState> {
  @override
  InboxViewState build() => const InboxViewState();

  void toggleLayout() {
    state = state.copyWith(
      layout: state.layout == InboxLayout.groupedBySender
          ? InboxLayout.flatNewestFirst
          : InboxLayout.groupedBySender,
    );
  }

  void toggleExpanded(String sender) {
    final expanded = Set<String>.from(state.expandedSenders);
    if (expanded.contains(sender)) {
      expanded.remove(sender);
    } else {
      expanded.add(sender);
    }
    state = state.copyWith(expandedSenders: expanded);
  }

  /// Applies a sender filter; any active filter change drops pagination
  /// state so the list starts fresh from the filtered first page.
  void setSenderFilter(String? senderKey) {
    _setFilters(
      senderFilter: senderKey,
      dateRangeFilter: state.dateRangeFilter,
    );
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _setFilters(senderFilter: state.senderFilter, dateRangeFilter: range);
  }

  void clearFilters() => _setFilters(senderFilter: null, dateRangeFilter: null);

  void _setFilters({
    required String? senderFilter,
    required DateTimeRange? dateRangeFilter,
  }) {
    state = InboxViewState(
      layout: state.layout,
      senderFilter: senderFilter,
      dateRangeFilter: dateRangeFilter,
    );
  }

  /// Loads the next flat page strictly below [cursor]. No-op while a load is
  /// in flight or when the previous page came back short — without that guard
  /// a fast scroll fires this repeatedly and duplicates rows.
  Future<void> loadFlatMore({required SmsEvent cursor}) async {
    if (state.flatLoadingMore || state.flatHasMore == false) return;
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;

    state = state.copyWith(flatLoadingMore: true);
    try {
      final page = await db.smsEventsPage(
        limit: kInboxPageSize,
        senderKey: state.senderFilter,
        fromReceivedAtEpochMs: _rangeFromUtcMs(state.dateRangeFilter),
        untilReceivedAtEpochMs: _rangeUntilUtcMs(state.dateRangeFilter),
        beforeReceivedAtEpochMs: cursor.receivedAtEpochMs,
        beforeId: cursor.id,
      );
      state = state.copyWith(
        flatLoadingMore: false,
        flatHasMore: page.length == kInboxPageSize,
        flatMore: _dedupeAppend(state.flatMore, page),
      );
    } catch (_) {
      state = state.copyWith(flatLoadingMore: false);
    }
  }

  /// Loads the next page for one sender (grouped layout), same cursor
  /// semantics and re-entry guard as [loadFlatMore].
  Future<void> loadSenderMore({
    required String senderKey,
    required SmsEvent cursor,
  }) async {
    if (state.senderLoadingMore[senderKey] == true ||
        state.senderHasMore[senderKey] == false) {
      return;
    }
    final db = ref.read(appDatabaseProvider).asData?.value;
    if (db == null) return;

    state = state.copyWith(
      senderLoadingMore: {...state.senderLoadingMore, senderKey: true},
    );
    try {
      final page = await db.smsEventsPage(
        limit: kInboxSenderPageSize,
        senderKey: senderKey,
        fromReceivedAtEpochMs: _rangeFromUtcMs(state.dateRangeFilter),
        untilReceivedAtEpochMs: _rangeUntilUtcMs(state.dateRangeFilter),
        beforeReceivedAtEpochMs: cursor.receivedAtEpochMs,
        beforeId: cursor.id,
      );
      state = state.copyWith(
        senderLoadingMore: {...state.senderLoadingMore, senderKey: false},
        senderHasMore: {
          ...state.senderHasMore,
          senderKey: page.length == kInboxSenderPageSize,
        },
        senderMore: {
          ...state.senderMore,
          senderKey: _dedupeAppend(
            state.senderMore[senderKey] ?? const [],
            page,
          ),
        },
      );
    } catch (_) {
      state = state.copyWith(
        senderLoadingMore: {...state.senderLoadingMore, senderKey: false},
      );
    }
  }

  static List<SmsEvent> _dedupeAppend(
    List<SmsEvent> existing,
    List<SmsEvent> page,
  ) {
    final seen = existing.map((e) => e.id).toSet();
    return [
      ...existing,
      for (final e in page)
        if (seen.add(e.id)) e,
    ];
  }
}

final inboxViewProvider = NotifierProvider<InboxViewController, InboxViewState>(
  InboxViewController.new,
);

/// Live first page: Drift's `watch()` emits on every write to `sms_events`,
/// so a message imported while the inbox is open appears without any manual
/// refresh and without cross-feature invalidation wiring (M4.14 WP1).
/// Filters from [inboxViewProvider] bound the window and the sender
/// (M4.15 WP2); changing them re-subscribes to a filtered stream.
/// autoDispose: the subscription must not outlive the page.
final inboxEventsProvider = StreamProvider.autoDispose<List<SmsEvent>>((
  ref,
) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  final view = ref.watch(inboxViewProvider);
  yield* db.watchSmsEventsPage(
    limit: kInboxPageSize,
    senderKey: view.senderFilter,
    fromReceivedAtEpochMs: _rangeFromUtcMs(view.dateRangeFilter),
    untilReceivedAtEpochMs: _rangeUntilUtcMs(view.dateRangeFilter),
  );
});

/// True per-sender totals for the grouped layout — `Show all (N)` must not
/// lie about N (M4.14 WP2).
final inboxSenderSummariesProvider =
    StreamProvider.autoDispose<List<SmsEventSenderSummary>>((ref) async* {
      final db = await ref.watch(appDatabaseProvider.future);
      yield* db.watchSmsEventSenderSummaries();
    });
