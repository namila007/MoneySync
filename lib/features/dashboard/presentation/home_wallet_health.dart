import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

/// Read-only projection of the outbox / record-link state for the home
/// dashboard (plan/04 §Home; M5.11). No domain logic — pure counts + the
/// latest created record, streamed live over tables that already exist.
final class HomeWalletHealth {
  const HomeWalletHealth({
    required this.reviewCount,
    required this.retryCount,
    required this.waitingCount,
    this.latestRecord,
  });

  final int reviewCount;
  final int retryCount;
  final int waitingCount;
  final LatestWalletRecord? latestRecord;

  static const empty = HomeWalletHealth(
    reviewCount: 0,
    retryCount: 0,
    waitingCount: 0,
  );
}

/// The most recent confirmed record link, for the "Latest Wallet transaction"
/// card (plan/04 §Home).
final class LatestWalletRecord {
  const LatestWalletRecord({
    required this.remoteId,
    required this.amountMinor,
    required this.currencyCode,
    required this.createdAtEpochMs,
  });

  final String remoteId;
  final int amountMinor;
  final String currencyCode;
  final int createdAtEpochMs;
}

final homeWalletHealthProvider = StreamProvider.autoDispose<HomeWalletHealth>((
  ref,
) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  final mutations = db.select(db.walletMutations);

  // Stream re-emits on any outbox / link write, keeping the counts live.
  await for (final rows in mutations.watch()) {
    final review = rows
        .where(
          (r) =>
              r.state == WalletMutationState.reconciling ||
              r.state == WalletMutationState.unknownDelivery ||
              r.state == WalletMutationState.unknownUpdate ||
              r.state == WalletMutationState.unknownDelete,
        )
        .length;
    final retry = rows
        .where((r) => r.state == WalletMutationState.retryScheduled)
        .length;
    final waiting = rows
        .where(
          (r) =>
              r.state == WalletMutationState.queued ||
              r.state == WalletMutationState.syncing,
        )
        .length;

    final latestLinks =
        await (db.select(db.walletRecordLinks)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAtEpochMs)])
              ..limit(1))
            .get();
    LatestWalletRecord? latest;
    if (latestLinks.isNotEmpty) {
      final link = latestLinks.first;
      // M5.14 gap 4: read amount + currency from the linked create mutation's
      // payload, not a hardcoded LKR 0.00. The link row has no amount columns;
      // the mutation payload is the source of truth.
      final linked =
          await (db.select(db.walletMutations)
                ..where((m) => m.candidateId.equals(link.candidateId ?? ''))
                ..limit(1))
              .get();
      latest = LatestWalletRecord(
        remoteId: link.remoteId ?? link.id,
        amountMinor: _amountMinorFrom(linked),
        currencyCode: _currencyFrom(linked),
        createdAtEpochMs: link.createdAtEpochMs,
      );
    }

    yield HomeWalletHealth(
      reviewCount: review,
      retryCount: retry,
      waitingCount: waiting,
      latestRecord: latest,
    );
  }
});

/// Parses `amountMinor` (int) out of the linked mutation payload. Amounts are
/// stored in the create snapshot payload (M5.6/M5.14 gap 4); a missing or
/// unparseable value degrades to 0 rather than crashing the dashboard.
int _amountMinorFrom(List<WalletMutation> mutations) {
  for (final mutation in mutations) {
    try {
      final decoded = jsonDecode(mutation.payload);
      if (decoded is Map<String, dynamic> && decoded['amountMinor'] is int) {
        return decoded['amountMinor'] as int;
      }
    } catch (_) {
      // fall through
    }
  }
  return 0;
}

/// Parses `currencyCode` out of the linked mutation payload; default LKR when
/// absent (M5 is same-currency LKR only).
String _currencyFrom(List<WalletMutation> mutations) {
  for (final mutation in mutations) {
    try {
      final decoded = jsonDecode(mutation.payload);
      if (decoded is Map<String, dynamic> &&
          decoded['currencyCode'] is String) {
        return decoded['currencyCode'] as String;
      }
    } catch (_) {
      // fall through
    }
  }
  return 'LKR';
}
