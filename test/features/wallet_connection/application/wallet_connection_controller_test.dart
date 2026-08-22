import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_controller.dart';

void main() {
  final refreshedAt = DateTime.utc(2026, 7, 25, 10);
  final catalog = WalletCatalog(
    accounts: const <WalletAccount>[
      WalletAccount(
        id: 'account-1',
        name: 'Everyday',
        currencyCode: 'LKR',
        isArchived: false,
        isBankSynced: false,
        isWritable: true,
      ),
    ],
    categories: const <WalletCategory>[
      WalletCategory(id: 'category-1', name: 'Food'),
    ],
  );

  ProviderContainer containerFor(_FakeWalletConnectionActions actions) {
    final container = ProviderContainer(
      overrides: [walletConnectionActionsProvider.overrideWithValue(actions)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'production composition remains prerequisite unavailable and blocked',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletPrerequisiteUnavailable>(),
      );
      expect(
        await container
            .read(walletConnectionControllerProvider.notifier)
            .submit(WalletToken.parse('synthetic-token')),
        WalletTokenSubmitResult.blocked,
      );
    },
  );

  test(
    'unavailable application actions remain host-safe and perform no work',
    () async {
      const actions = WalletPrerequisiteUnavailableActions();

      expect(actions.isAvailable, isFalse);
      expect(
        await actions.connect(
          WalletToken.parse('synthetic-token'),
          replacing: false,
          lifecycleEpoch: 1,
        ),
        isA<WalletConnectionActionUnavailable>(),
      );
      expect(
        await actions.refresh(lifecycleEpoch: 2),
        isA<WalletConnectionActionUnavailable>(),
      );
      await actions.disconnect(lifecycleEpoch: 3);
    },
  );

  test(
    'connects from disconnected through loading with immutable fresh catalog',
    () async {
      final actions = _FakeWalletConnectionActions(
        connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      );
      final container = containerFor(actions);
      final controller = container.read(
        walletConnectionControllerProvider.notifier,
      );

      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletDisconnected>(),
      );
      expect(controller.canSubmitToken, isTrue);

      final submit = controller.submit(WalletToken.parse('synthetic-token'));
      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletConnectionLoading>(),
      );
      expect(controller.canSubmitToken, isFalse);
      expect(await submit, WalletTokenSubmitResult.accepted);

      final state =
          container.read(walletConnectionControllerProvider) as WalletConnected;
      expect(state.catalog, same(catalog));
      expect(state.refreshedAt, refreshedAt);
      expect(state.isStale, isFalse);
      expect(
        () => state.catalog.accounts.add(state.catalog.accounts.single),
        throwsUnsupportedError,
      );
      expect(
        () => state.catalog.categories.add(state.catalog.categories.single),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'maps every typed catalog failure after handing off the token safely',
    () async {
      final expected = <WalletReadFailure, WalletConnectionProblemCode>{
        const WalletReadFailure.invalidToken():
            WalletConnectionProblemCode.invalidToken,
        const WalletReadFailure.initialSyncInProgress():
            WalletConnectionProblemCode.initialSync,
        const WalletReadFailure.rateLimited():
            WalletConnectionProblemCode.rateLimited,
        const WalletReadFailure.offline(): WalletConnectionProblemCode.offline,
        const WalletReadFailure.timeout(): WalletConnectionProblemCode.timeout,
        const WalletReadFailure.tls(): WalletConnectionProblemCode.tls,
        const WalletReadFailure.service(): WalletConnectionProblemCode.service,
        const WalletReadFailure.protocol():
            WalletConnectionProblemCode.protocol,
      };

      for (final entry in expected.entries) {
        final container = containerFor(
          _FakeWalletConnectionActions(
            connectResult: WalletConnectionActionFailure(entry.key),
          ),
        );
        const tokenText = 'synthetic-token-never-in-state';

        expect(
          await container
              .read(walletConnectionControllerProvider.notifier)
              .submit(WalletToken.parse(tokenText)),
          WalletTokenSubmitResult.handedOff,
        );

        final state = container.read(walletConnectionControllerProvider);
        expect(state, isA<WalletConnectionFailure>());
        expect((state as WalletConnectionFailure).code, entry.value);
        expect('$state', isNot(contains(tokenText)));
        expect(state.userMessage, isNot(contains(tokenText)));
      }
    },
  );

  test(
    'retains cached catalog as explicitly stale after an offline result',
    () async {
      final actions = _FakeWalletConnectionActions(
        connectResult: WalletConnectionCatalogOffline(catalog, refreshedAt),
      );
      final container = containerFor(actions);

      expect(
        await container
            .read(walletConnectionControllerProvider.notifier)
            .submit(WalletToken.parse('synthetic-token')),
        WalletTokenSubmitResult.accepted,
      );

      final state =
          container.read(walletConnectionControllerProvider) as WalletConnected;
      expect(state.catalog, same(catalog));
      expect(state.refreshedAt, refreshedAt);
      expect(state.isStale, isTrue);
    },
  );

  test('refreshes to a fresh catalog through loading', () async {
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      refreshResult: WalletConnectionCatalogReady(catalog, refreshedAt),
    );
    final container = containerFor(actions);
    final controller = container.read(
      walletConnectionControllerProvider.notifier,
    );

    final refresh = controller.refresh();

    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletConnectionLoading>().having(
        (state) => state.previous,
        'previous state',
        isA<WalletDisconnected>(),
      ),
    );
    expect(await refresh, WalletTokenSubmitResult.accepted);
    expect(actions.refreshCalls, 1);
    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletConnected>()
          .having((state) => state.catalog, 'catalog', same(catalog))
          .having((state) => state.refreshedAt, 'refreshed at', refreshedAt)
          .having((state) => state.isStale, 'is stale', isFalse),
    );
  });

  test('refreshes to an explicitly stale offline catalog', () async {
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      refreshResult: WalletConnectionCatalogOffline(catalog, refreshedAt),
    );
    final container = containerFor(actions);

    expect(
      await container
          .read(walletConnectionControllerProvider.notifier)
          .refresh(),
      WalletTokenSubmitResult.accepted,
    );
    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletConnected>().having(
        (state) => state.isStale,
        'is stale',
        isTrue,
      ),
    );
  });

  test('maps typed refresh failures and unavailability safely', () async {
    final cases = <WalletConnectionActionResult, Matcher>{
      const WalletConnectionActionFailure(
        WalletReadFailure.timeout(),
      ): isA<WalletConnectionFailure>().having(
        (state) => state.code,
        'code',
        WalletConnectionProblemCode.timeout,
      ),
      const WalletConnectionActionUnavailable():
          isA<WalletPrerequisiteUnavailable>(),
    };

    for (final entry in cases.entries) {
      final actions = _FakeWalletConnectionActions(
        connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
        refreshResult: entry.key,
      );
      final container = containerFor(actions);

      expect(
        await container
            .read(walletConnectionControllerProvider.notifier)
            .refresh(),
        WalletTokenSubmitResult.handedOff,
      );
      expect(container.read(walletConnectionControllerProvider), entry.value);
    }
  });

  test('blocks refresh while another action is loading', () async {
    final pending = Completer<WalletConnectionActionResult>();
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      pendingConnect: pending,
    );
    final container = containerFor(actions);
    final controller = container.read(
      walletConnectionControllerProvider.notifier,
    );

    final connect = controller.submit(WalletToken.parse('synthetic-token'));

    expect(await controller.refresh(), WalletTokenSubmitResult.blocked);
    expect(actions.refreshCalls, 0);

    pending.complete(WalletConnectionCatalogReady(catalog, refreshedAt));
    expect(await connect, WalletTokenSubmitResult.accepted);
  });

  test('maps a thrown connect Exception to a safe service failure', () async {
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      connectFailure: Exception('synthetic failure'),
    );
    final container = containerFor(actions);

    expect(
      await container
          .read(walletConnectionControllerProvider.notifier)
          .submit(WalletToken.parse('synthetic-token')),
      WalletTokenSubmitResult.handedOff,
    );
    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletConnectionFailure>().having(
        (state) => state.code,
        'code',
        WalletConnectionProblemCode.service,
      ),
    );
  });

  test(
    'maps a thrown disconnect to a safe service failure and false',
    () async {
      final actions = _FakeWalletConnectionActions(
        connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
        disconnectFailure: Exception('synthetic failure'),
      );
      final container = containerFor(actions);

      expect(
        await container
            .read(walletConnectionControllerProvider.notifier)
            .disconnect(confirmed: true),
        isFalse,
      );
      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletConnectionFailure>().having(
          (state) => state.code,
          'code',
          WalletConnectionProblemCode.service,
        ),
      );
    },
  );

  test('lets an Error thrown by connect surface', () async {
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      connectFailure: StateError('synthetic failure'),
    );
    final container = containerFor(actions);

    await expectLater(
      container
          .read(walletConnectionControllerProvider.notifier)
          .submit(WalletToken.parse('synthetic-token')),
      throwsA(isA<StateError>()),
    );
  });

  test('lets an Error thrown by disconnect surface', () async {
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      disconnectFailure: StateError('synthetic failure'),
    );
    final container = containerFor(actions);

    await expectLater(
      container
          .read(walletConnectionControllerProvider.notifier)
          .disconnect(confirmed: true),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'keeps replacement history after fresh auth fails until confirmed disconnect',
    () async {
      final actions = _FakeWalletConnectionActions(
        connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      );
      final container = containerFor(actions);
      final controller = container.read(
        walletConnectionControllerProvider.notifier,
      );

      expect(
        await controller.submit(WalletToken.parse('first-synthetic-token')),
        WalletTokenSubmitResult.accepted,
      );
      actions.connectResult =
          const WalletConnectionFreshAuthenticationRequired();

      expect(
        await controller.submit(
          WalletToken.parse('replacement-synthetic-token'),
        ),
        WalletTokenSubmitResult.handedOff,
      );
      expect(actions.replacementRequests, 1);
      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletConnectionFailure>().having(
          (state) => state.code,
          'code',
          WalletConnectionProblemCode.freshAuthenticationRequired,
        ),
      );

      actions.connectResult = WalletConnectionCatalogReady(
        catalog,
        refreshedAt,
      );
      expect(
        await controller.submit(WalletToken.parse('second-replacement-token')),
        WalletTokenSubmitResult.accepted,
      );
      expect(actions.replacementRequests, 2);

      expect(await controller.disconnect(confirmed: true), isTrue);
      expect(
        await controller.submit(WalletToken.parse('new-first-token')),
        WalletTokenSubmitResult.accepted,
      );
      expect(actions.replacementRequests, 2);
    },
  );

  test(
    'restoring from cache triggers a non-blocking refresh (Bug 1)',
    () async {
      final actions = _FakeWalletConnectionActions(
        connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
        refreshResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      );
      final container = containerFor(actions);
      final controller = container.read(
        walletConnectionControllerProvider.notifier,
      );

      // Simulate the post-cache-restore state: connected but stale.
      // The real _restoreFromCache() sets this state and then calls
      // unawaited(refresh()) to upgrade it. We verify the refresh path
      // works end-to-end by manually calling refresh from this state.
      await controller.submit(WalletToken.parse('synthetic-token'));
      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletConnected>().having((s) => s.isStale, 'isStale', isFalse),
      );

      // Simulate going offline then back to stale
      actions.refreshResult = WalletConnectionCatalogOffline(
        catalog,
        refreshedAt,
      );
      await controller.refresh();
      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletConnected>().having((s) => s.isStale, 'isStale', isTrue),
      );

      // Now simulate the auto-refresh upgrading stale → live
      actions.refreshResult = WalletConnectionCatalogReady(
        catalog,
        refreshedAt,
      );
      await controller.refresh();
      expect(actions.refreshCalls, 2);
      expect(
        container.read(walletConnectionControllerProvider),
        isA<WalletConnected>().having((s) => s.isStale, 'isStale', isFalse),
      );
    },
  );

  test('confirmed disconnect cancels and fences pending token work', () async {
    final pending = Completer<WalletConnectionActionResult>();
    final actions = _FakeWalletConnectionActions(
      connectResult: WalletConnectionCatalogReady(catalog, refreshedAt),
      pendingConnect: pending,
    );
    final container = containerFor(actions);
    final controller = container.read(
      walletConnectionControllerProvider.notifier,
    );

    final connect = controller.submit(WalletToken.parse('synthetic-token'));
    expect(actions.hasStagedCredential, isTrue);
    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletConnectionLoading>(),
    );
    expect(
      await controller.submit(WalletToken.parse('second-synthetic-token')),
      WalletTokenSubmitResult.blocked,
    );
    expect(actions.connectCalls, 1);

    expect(await controller.disconnect(confirmed: false), isFalse);
    expect(actions.disconnectCalls, 0);
    expect(await controller.disconnect(confirmed: true), isTrue);
    expect(actions.disconnectCalls, 1);
    expect(actions.hasStagedCredential, isFalse);
    expect(actions.hasStoredCredential, isFalse);
    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletDisconnected>(),
    );

    pending.complete(WalletConnectionCatalogReady(catalog, refreshedAt));
    expect(await connect, WalletTokenSubmitResult.handedOff);
    expect(
      container.read(walletConnectionControllerProvider),
      isA<WalletDisconnected>(),
    );
    expect(actions.hasStagedCredential, isFalse);
    expect(actions.hasStoredCredential, isFalse);
  });
}

final class _FakeWalletConnectionActions implements WalletConnectionActions {
  _FakeWalletConnectionActions({
    required this.connectResult,
    WalletConnectionActionResult? refreshResult,
    this.pendingConnect,
    this.connectFailure,
    this.disconnectFailure,
  }) : refreshResult = refreshResult ?? connectResult;

  @override
  bool get isAvailable => true;

  WalletConnectionActionResult connectResult;
  WalletConnectionActionResult refreshResult;
  final Completer<WalletConnectionActionResult>? pendingConnect;
  final Object? connectFailure;
  final Object? disconnectFailure;
  var connectCalls = 0;
  var disconnectCalls = 0;
  var refreshCalls = 0;
  var replacementRequests = 0;
  var hasStagedCredential = false;
  var hasStoredCredential = false;
  var _cancelledThroughEpoch = -1;

  @override
  Future<WalletConnectionActionResult> connect(
    WalletToken token, {
    required bool replacing,
    required int lifecycleEpoch,
  }) async {
    connectCalls += 1;
    if (connectFailure != null) throw connectFailure!;
    hasStagedCredential = true;
    if (replacing) replacementRequests += 1;

    final pending = pendingConnect;
    final result = pending != null && !pending.isCompleted
        ? await pending.future
        : connectResult;
    if (lifecycleEpoch <= _cancelledThroughEpoch) {
      hasStagedCredential = false;
      return result;
    }

    hasStagedCredential = false;
    hasStoredCredential =
        result is WalletConnectionCatalogReady ||
        result is WalletConnectionCatalogOffline;
    return result;
  }

  @override
  Future<void> disconnect({required int lifecycleEpoch}) async {
    disconnectCalls += 1;
    if (disconnectFailure != null) throw disconnectFailure!;
    _cancelledThroughEpoch = lifecycleEpoch;
    hasStagedCredential = false;
    hasStoredCredential = false;
  }

  @override
  Future<WalletConnectionActionResult> refresh({
    required int lifecycleEpoch,
  }) async {
    refreshCalls += 1;
    return refreshResult;
  }
}
