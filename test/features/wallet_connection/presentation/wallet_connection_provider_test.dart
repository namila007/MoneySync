import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_controller.dart';

void main() {
  group('walletConnectionActionsProvider', () {
    test(
      'resolves to WalletPrerequisiteUnavailable when DB is null (fresh ProviderScope)',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final actions = container.read(walletConnectionActionsProvider);

        expect(actions.isAvailable, isFalse);
        expect(actions, isA<WalletPrerequisiteUnavailableActions>());
      },
    );

    test('isAvailable returns false for prerequisite unavailable actions', () {
      const actions = WalletPrerequisiteUnavailableActions();

      expect(actions.isAvailable, isFalse);
    });

    test(
      'WalletPrerequisiteUnavailableActions.connect returns ActionUnavailable',
      () async {
        const actions = WalletPrerequisiteUnavailableActions();

        final result = await actions.connect(
          WalletToken.parse('synthetic-token'),
          replacing: false,
          lifecycleEpoch: 1,
        );

        expect(result, isA<WalletConnectionActionUnavailable>());
      },
    );

    test(
      'WalletPrerequisiteUnavailableActions.refresh returns ActionUnavailable',
      () async {
        const actions = WalletPrerequisiteUnavailableActions();

        final result = await actions.refresh(lifecycleEpoch: 1);

        expect(result, isA<WalletConnectionActionUnavailable>());
      },
    );

    test(
      'WalletPrerequisiteUnavailableActions.disconnect does not throw',
      () async {
        const actions = WalletPrerequisiteUnavailableActions();

        await actions.disconnect(lifecycleEpoch: 1);
      },
    );

    test(
      'production controller is blocked when prerequisites are unavailable',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          container.read(walletConnectionControllerProvider),
          isA<WalletPrerequisiteUnavailable>(),
        );
      },
    );
  });
}
