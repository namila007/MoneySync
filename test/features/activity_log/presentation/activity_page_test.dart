import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/activity_log/domain/activity_event.dart';
import 'package:money_sync/features/activity_log/domain/activity_log_repository.dart';
import 'package:money_sync/features/activity_log/domain/activity_recovery_actions.dart';
import 'package:money_sync/features/activity_log/presentation/activity_log_controller.dart';
import 'package:money_sync/features/activity_log/presentation/activity_page.dart';
import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

ActivityLogEntry _entry({
  required int id,
  required ActivityEventCode code,
  required ActivityStateTransition detail,
  required int epochMs,
  int? count,
  String? mutationId,
}) {
  return ActivityLogEntry(
    id: id,
    code: code,
    detail: detail,
    occurredAt: DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true),
    privacyEpoch: 0,
    count: count,
    mutationId: mutationId,
  );
}

Widget _app(List<ActivityLogEntry> entries) {
  return ProviderScope(
    overrides: [
      activityLogRepositoryProvider.overrideWith(
        (ref) async => _FakeRepo(entries),
      ),
    ],
    child: const MaterialApp(home: ActivityPage()),
  );
}

void main() {
  group('ActivityPage', () {
    testWidgets('shows an empty state when there is no activity', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const []));
      await tester.pumpAndSettle();

      expect(find.textContaining('No activity here yet'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders one tile per entry with readable labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app([
          _entry(
            id: 2,
            code: ActivityEventCode.privacyEpochAdvanced,
            detail: ActivityStateTransition.privacyEpochAdvanced,
            epochMs: 2000,
          ),
          _entry(
            id: 1,
            code: ActivityEventCode.rawCopyPurged,
            detail: ActivityStateTransition.rawCopyPurged,
            epochMs: 1000,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Local data cleared'), findsOneWidget);
      expect(find.text('Message copy removed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders every event code without a missing-case failure', (
      tester,
    ) async {
      var id = 0;
      await tester.pumpWidget(
        _app([
          for (final code in ActivityEventCode.values)
            _entry(
              id: id++,
              code: code,
              detail: ActivityStateTransition.logEvent,
              epochMs: 1000 * id,
            ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'aggregated import event tile shows the batch count (M4.15 WP3)',
      (tester) async {
        await tester.pumpWidget(
          _app([
            _entry(
              id: 1,
              code: ActivityEventCode.messageImported,
              detail: ActivityStateTransition.logEvent,
              epochMs: 1000,
              count: 20,
            ),
            _entry(
              id: 2,
              code: ActivityEventCode.messageImported,
              detail: ActivityStateTransition.logEvent,
              epochMs: 2000,
            ),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.text('20 messages imported'), findsOneWidget);
        expect(find.text('Message imported'), findsOneWidget);
      },
    );

    testWidgets('surfaces a safe message when the read fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityLogRepositoryProvider.overrideWith(
              (ref) async => _FailingRepo(),
            ),
          ],
          child: const MaterialApp(home: ActivityPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('could not be read'), findsOneWidget);
    });

    testWidgets('filters by event code chip (M5.12)', (tester) async {
      await tester.pumpWidget(
        _app([
          _entry(
            id: 3,
            code: ActivityEventCode.walletRecordCreated,
            detail: ActivityStateTransition.logEvent,
            epochMs: 3000,
          ),
          _entry(
            id: 2,
            code: ActivityEventCode.candidateNeedsReview,
            detail: ActivityStateTransition.needsReview,
            epochMs: 2000,
          ),
          _entry(
            id: 1,
            code: ActivityEventCode.logError,
            detail: ActivityStateTransition.logEvent,
            epochMs: 1000,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(3));
      await tester.tap(find.text('Created'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Wallet record created'), findsOneWidget);
    });

    testWidgets(
      'retry button shown for retryScheduled mutation, verify for unknown '
      '(M5.12/M5.14 gap 5)',
      (tester) async {
        final actions = _SpyRecoveryActions();
        final db = AppDatabase.inMemoryForTesting();

        // Insert a retry_scheduled mutation — should show Retry only.
        await db
            .into(db.walletMutations)
            .insert(
              WalletMutationsCompanion.insert(
                id: 'mutation-retry-1',
                operationKind: WalletMutationOperation.create,
                payload: '{}',
                state: WalletMutationState.retryScheduled,
                lineageKey: 'lineage-1',
                fingerprint: 'fp-1',
                createdAtEpochMs: 1000,
                updatedAtEpochMs: 1000,
              ),
            );

        // Insert an unknown_delivery mutation — should show Verify only.
        await db
            .into(db.walletMutations)
            .insert(
              WalletMutationsCompanion.insert(
                id: 'mutation-unknown-1',
                operationKind: WalletMutationOperation.create,
                payload: '{}',
                state: WalletMutationState.unknownDelivery,
                lineageKey: 'lineage-2',
                fingerprint: 'fp-2',
                createdAtEpochMs: 2000,
                updatedAtEpochMs: 2000,
              ),
            );

        // Insert a succeeded mutation — should show neither.
        await db
            .into(db.walletMutations)
            .insert(
              WalletMutationsCompanion.insert(
                id: 'mutation-succeeded-1',
                operationKind: WalletMutationOperation.create,
                payload: '{}',
                state: WalletMutationState.succeeded,
                lineageKey: 'lineage-3',
                fingerprint: 'fp-3',
                createdAtEpochMs: 3000,
                updatedAtEpochMs: 3000,
              ),
            );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              activityLogRepositoryProvider.overrideWith(
                (ref) async => _FakeRepo([
                  _entry(
                    id: 7,
                    code: ActivityEventCode.walletRecordCreated,
                    detail: ActivityStateTransition.logEvent,
                    epochMs: 1000,
                    mutationId: 'mutation-retry-1',
                  ),
                  _entry(
                    id: 8,
                    code: ActivityEventCode.walletRecordCreated,
                    detail: ActivityStateTransition.logEvent,
                    epochMs: 2000,
                    mutationId: 'mutation-unknown-1',
                  ),
                  _entry(
                    id: 9,
                    code: ActivityEventCode.walletRecordCreated,
                    detail: ActivityStateTransition.logEvent,
                    epochMs: 3000,
                    mutationId: 'mutation-succeeded-1',
                  ),
                ]),
              ),
              activityRecoveryActionsProvider.overrideWith(
                (ref) async => actions,
              ),
              appDatabaseProvider.overrideWith((ref) async {
                ref.onDispose(db.close);
                return db;
              }),
            ],
            child: const MaterialApp(home: ActivityPage()),
          ),
        );
        await tester.pumpAndSettle();

        // retryScheduled row → Retry visible, Verify hidden.
        expect(find.text('Retry'), findsOneWidget);
        // unknownDelivery row → Verify visible, Retry hidden.
        expect(find.text('Verify'), findsOneWidget);
        // succeeded row → no buttons.
        // (We already verified exactly 1 Retry and 1 Verify above.)

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(actions.retries, ['mutation-retry-1']);

        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();
        expect(actions.verifies, ['mutation-unknown-1']);
      },
    );

    testWidgets('non-wallet events show no recovery actions', (tester) async {
      await tester.pumpWidget(
        _app([
          _entry(
            id: 5,
            code: ActivityEventCode.messageImported,
            detail: ActivityStateTransition.logEvent,
            epochMs: 1000,
          ),
          // A wallet event WITHOUT a mutation id (pre-v10 / log-derived) must
          // also hide recovery — dispatching a fabricated id would target a
          // non-existent row (M5.14 gap 5).
          _entry(
            id: 6,
            code: ActivityEventCode.walletRecordCreated,
            detail: ActivityStateTransition.logEvent,
            epochMs: 2000,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsNothing);
      expect(find.text('Verify'), findsNothing);
    });
  });
}

final class _FakeRepo implements ActivityLogRepository {
  const _FakeRepo(this.entries);

  final List<ActivityLogEntry> entries;

  @override
  Future<List<ActivityLogEntry>> recent({
    int limit = 200,
    ActivityEventCode? code,
  }) async {
    final filtered = code == null
        ? entries
        : entries.where((e) => e.code == code).toList();
    return filtered.take(limit).toList();
  }
}

final class _FailingRepo implements ActivityLogRepository {
  @override
  Future<List<ActivityLogEntry>> recent({
    int limit = 200,
    ActivityEventCode? code,
  }) async => throw StateError('database unavailable');
}

final class _SpyRecoveryActions implements ActivityRecoveryActions {
  final List<String> retries = [];
  final List<String> verifies = [];

  @override
  Future<void> retryNow(String mutationId) async => retries.add(mutationId);

  @override
  Future<void> verifyInWallet(String mutationId) async =>
      verifies.add(mutationId);
}
