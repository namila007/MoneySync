import 'package:logging/logging.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_api_data_source.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_create_payload.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_mutations_dao.dart';
import 'package:money_sync/features/wallet_sync/data/wallet_repository.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/retry_scheduler.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

final _log = Logger('wallet.transmit');

/// Transmits one Wallet mutation and resolves its stored state from the real
/// API outcome.
///
/// **M5.22 WP-K.** This exists because `succeeded` was being written without a
/// transmission. `ReviewTransactionController.submit()` wrote
/// `WalletMutationState.succeeded` directly on the "Create now" path and never
/// touched `WalletRepository`, so the record was reported as created, the
/// Success tile incremented, and nothing ever reached the Wallet API. Only the
/// approve paths transmitted — and they each carried their own copy of the
/// transmit-and-resolve logic, which is how the third caller came to omit it.
///
/// One implementation, three callers: Create-now, single approve, and batch
/// approve.
///
/// The state walk follows the machine in [WalletMutationStateTransitions]:
/// `queued -> syncing -> {succeeded | retryScheduled | unknownDelivery |
/// permanentFailure}`. `succeeded` is written **only** against a confirmed
/// remote record id.
final class WalletMutationTransmitter {
  WalletMutationTransmitter({
    required AppDatabase database,
    required this._repository,
    RetryScheduler? retryScheduler,
  }) : _database = database,
       _dao = WalletMutationsDao(database: database),
       _retryScheduler = retryScheduler ?? RetryScheduler();

  final AppDatabase _database;
  final WalletMutationsDao _dao;
  final WalletRepository _repository;
  final RetryScheduler _retryScheduler;

  /// Sends [snapshot] for mutation [mutationId] and records the outcome.
  ///
  /// Returns the raw [WalletMutationResult] so the caller can render an honest
  /// message. The mutation's stored state is resolved before this returns.
  Future<WalletMutationResult> transmit({
    required String mutationId,
    required TransactionCandidateSnapshot snapshot,
  }) async {
    var intent = await _dao.byId(mutationId);
    if (intent == null) {
      _log.error('Transmit skipped: mutation not found');
      return const WalletMutationPreTransmissionFailure();
    }

    if (intent.state == WalletMutationState.queued) {
      intent = await _dao.transitionTo(
        intent: intent,
        next: WalletMutationState.syncing,
      );
    }

    _log.info('state_transition: syncing');
    final result = await _repository.create(snapshot);
    await _resolve(intent: intent, result: result, snapshot: snapshot);
    return result;
  }

  /// How long to wait before re-checking an unconfirmed create. Wallet is
  /// eventually consistent, so an immediate second lookup would usually fail
  /// for the same reason the read-back did.
  static const _consistencyWindow = Duration(seconds: 3);

  Future<void> _resolve({
    required WalletMutationIntent intent,
    required WalletMutationResult result,
    required TransactionCandidateSnapshot snapshot,
  }) async {
    switch (result) {
      case WalletMutationRemoteSuccess(:final remoteRecordId):
        // M5.22 WP-N: a 200 is not proof the record is queryable in Wallet.
        // Read it back before writing the terminal state — `succeeded` is the
        // app's claim that the money is recorded, and it must be earned.
        final verified = await _repository.getRecord(remoteRecordId);
        if (verified == null) {
          // Reconcile immediately rather than waiting for the next app start
          // (owner decision, 2026-08-25). plan/05 calls for polling "through a
          // bounded consistency window" — one delayed re-check, not a loop, so
          // a flapping network cannot spin here.
          await Future<void>.delayed(_consistencyWindow);
          final settled = await _reconcileNow(
            intent: intent,
            snapshot: snapshot,
          );
          if (settled) return;

          // Still unproven either way. NOT a retry: plan/05:167 holds an
          // unconfirmed create as unknownDelivery with automatic retries
          // stopped, because the record may well exist and resending would
          // duplicate it. Startup reconciliation picks it up later.
          await _dao.transitionTo(
            intent: intent,
            next: WalletMutationState.unknownDelivery,
          );
          _log.error(
            'state_transition: unknownDelivery | '
            'SafeErrorCode: CREATE_UNVERIFIED',
          );
          await _recordFailure('Create could not be confirmed in Wallet');
          return;
        }
        _log.info('Read-back confirmed the created record');
        await _dao.transitionTo(
          intent: intent,
          next: WalletMutationState.succeeded,
        );
        // The candidate leaves needsReview only once the record is genuinely
        // in Wallet (M5.18 finding 3).
        if (intent.candidateId.isNotEmpty) {
          await _dao.transitionCandidateState(
            candidateId: intent.candidateId,
            newState: 'retainedLocal',
          );
        }
        _log.info('state_transition: succeeded');
        await _recordActivity(
          ActivityEventCode.walletRecordCreated,
          'Record created in Wallet',
        );

      // The request may or may not have been applied remotely. Reconciliation
      // must resolve it before any retry — a blind resend here would risk a
      // duplicate record.
      case WalletMutationPostTransmissionAmbiguity():
        await _dao.transitionTo(
          intent: intent,
          next: WalletMutationState.unknownDelivery,
        );
        _log.error('state_transition: unknownDelivery');
        await _recordFailure('Wallet did not confirm the create');

      // Never left the device, so resending is safe.
      case WalletMutationPreTransmissionFailure():
      case WalletMutationServerFailure():
        await _scheduleRetry(intent);

      // A 4xx will not become a 2xx by repeating it.
      case WalletMutationClientFailure():
        await _dao.transitionTo(
          intent: intent,
          next: WalletMutationState.permanentFailure,
        );
        _log.error('state_transition: permanentFailure');
        await _recordFailure('Wallet rejected the record');

      // Not reachable through WalletRepository, which has no disabled path.
      case WalletMutationDisabled():
      case WalletMutationReconciledOwnership():
        _log.info('state_transition: queued');
    }
  }

  /// One immediate marker lookup for a create whose read-back came back
  /// empty. Returns true when the mutation was conclusively settled.
  ///
  /// Mirrors the startup reconciliation rules exactly (M5.22 WP-E): exactly
  /// one match settles it, zero matches prove the create never landed so a
  /// retry is safe, and anything else — a failed lookup, an ambiguous
  /// multi-match, or a missing marker — is NOT proof and must not retry.
  Future<bool> _reconcileNow({
    required WalletMutationIntent intent,
    required TransactionCandidateSnapshot snapshot,
  }) async {
    final marker = RegExp(
      r'\[sw:([0-9A-Z]+)\]',
    ).firstMatch(snapshot.note ?? '')?.group(1);
    if (marker == null) {
      _log.error('Immediate reconcile skipped | SafeErrorCode: MARKER_MISSING');
      return false;
    }

    try {
      final matches = await _repository.findRecordForReconciliation(
        WalletReconciliationQuery(
          marker: marker,
          accountId: snapshot.accountId,
          amountMinor: snapshot.amountMinor,
        ),
      );

      if (matches.length == 1) {
        await _dao.transitionTo(
          intent: intent,
          next: WalletMutationState.succeeded,
        );
        if (intent.candidateId.isNotEmpty) {
          await _dao.transitionCandidateState(
            candidateId: intent.candidateId,
            newState: 'retainedLocal',
          );
        }
        _log.info(
          'Immediate reconcile confirmed the record | '
          'state_transition: succeeded',
        );
        return true;
      }

      if (matches.isEmpty) {
        // Proven absent, so resending is safe.
        await _scheduleRetry(intent);
        await _recordFailure('Create did not reach Wallet — retry scheduled');
        return true;
      }

      _log.error(
        'Immediate reconcile ambiguous: ${matches.length} matches | '
        'SafeErrorCode: MARKER_AMBIGUOUS',
      );
      return false;
    } on Exception catch (e, st) {
      // A failed lookup is not evidence of absence.
      _log.error('Immediate reconcile lookup failed', e, st);
      return false;
    }
  }

  /// M5.22 WP-N: every create that does not end in a confirmed record leaves
  /// an audit trail the user can see, not just a log line.
  ///
  /// Best-effort: the mutation state is the source of truth, so a failure to
  /// write the audit row must never mask the outcome that was already
  /// recorded. It is logged rather than thrown.
  Future<void> _recordFailure(String safeDetail) =>
      _recordActivity(ActivityEventCode.walletRecordFailed, safeDetail);

  Future<void> _recordActivity(
    ActivityEventCode code,
    String safeDetail,
  ) async {
    try {
      await _database.insertActivity(
        activityType: code,
        safeDetailCode: ActivityStateTransition.logEvent,
        occurredAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        privacyEpoch: await _currentPrivacyEpoch(),
        detailMessage: safeDetail,
      );
    } on Exception catch (e, st) {
      _log.error('Could not write the failure activity event', e, st);
    }
  }

  Future<int> _currentPrivacyEpoch() async {
    final row = await (_database.select(
      _database.appSettings,
    )..where((s) => s.singletonId.equals(1))).getSingleOrNull();
    return row?.privacyEpoch ?? 0;
  }

  Future<void> _scheduleRetry(WalletMutationIntent intent) async {
    final attempt = await _attemptCount(intent.id) + 1;
    final delay = _retryScheduler.nextDelay(attempt);
    await _dao.scheduleRetry(
      intent: intent,
      attemptCount: attempt,
      nextAttemptAtEpochMs: DateTime.now().add(delay).millisecondsSinceEpoch,
    );
    _log.info('state_transition: retryScheduled | retry attempt $attempt');
    await _recordFailure('Create failed — retry attempt $attempt scheduled');
  }

  Future<int> _attemptCount(String mutationId) async {
    final rows = await (_database.select(
      _database.walletMutations,
    )..where((m) => m.id.equals(mutationId))).get();
    return rows.isEmpty ? 0 : (rows.first.attemptCount ?? 0);
  }
}
