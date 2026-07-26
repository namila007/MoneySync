import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/onboarding/domain/onboarding_state.dart';
import 'package:money_sync/features/onboarding/presentation/onboarding_controller.dart';
import 'package:money_sync/features/wallet_connection/application/wallet_connection_actions.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_controller.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_page.dart';

class _CompletedOnboardingNotifier extends OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState(
    currentStep: OnboardingStep.disclosure,
    disclosureRevision: 1,
    isComplete: true,
  );
}

void main() {
  testWidgets(
    'available invalid-token failure supports cleared-token re-entry',
    (tester) async {
      final actions = _FailThenSucceedWalletActions();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletConnectionActionsProvider.overrideWithValue(actions),
          ],
          child: const MaterialApp(home: WalletConnectionPage()),
        ),
      );

      await tester.enterText(find.byType(TextField), 'initial-token');
      await tester.tap(find.text('Save & connect'));
      await tester.pumpAndSettle();

      expect(actions.replacingValues, equals(<bool>[false]));
      expect(find.text('Enter a valid Wallet token.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'fresh-token');
      await tester.tap(find.text('Save & connect'));
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(WalletConnectionPage));
      expect(
        ProviderScope.containerOf(
          pageContext,
        ).read(walletConnectionControllerProvider),
        isA<WalletConnected>(),
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.text('fresh-token'), findsNothing);
      expect(actions.replacingValues, equals(<bool>[false, false]));
    },
  );

  test(
    'production controller stays blocked and every problem code has fixed text',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container
            .read(walletConnectionControllerProvider.notifier)
            .submit(WalletToken.parse('synthetic-token')),
        WalletTokenSubmitResult.blocked,
      );
      for (final code in WalletConnectionProblemCode.values) {
        expect(
          const WalletConnectionFailure(
            WalletConnectionProblemCode.invalidToken,
          ).userMessage,
          isNotEmpty,
        );
        expect(
          WalletConnectionFailure(code).userMessage,
          isNot(contains('synthetic-token')),
        );
      }
    },
  );

  testWidgets(
    'production default is prerequisite unavailable and token is never shown',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.playManual()),
          ],
          child: const MaterialApp(home: WalletConnectionPage()),
        ),
      );

      expect(find.text('Not available yet'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets(
    'provider fake exposes hardened entry, recoverable validation, and cleared token',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletConnectionControllerProvider.overrideWith(
              _FakeWalletController.new,
            ),
          ],
          child: const MaterialApp(home: WalletConnectionPage()),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.enableIMEPersonalizedLearning, isFalse);
      expect(field.autofillHints, isEmpty);

      await tester.enterText(find.byType(TextField), ' invalid');
      await tester.tap(find.text('Save & connect'));
      await tester.pump();
      expect(find.text('Enter a valid Wallet token.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'synthetic-token');
      await tester.tap(find.text('Save & connect'));
      await tester.pumpAndSettle();

      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('synthetic-token'), findsNothing);
    },
  );

  testWidgets('clears a handed-off valid token before remote work completes', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletConnectionControllerProvider.overrideWith(
            _FakeWalletController.new,
          ),
        ],
        child: const MaterialApp(home: WalletConnectionPage()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'synthetic-token');
    await tester.tap(find.text('Save & connect'));

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'MoneySync router reaches nested Wallet settings and returns to Settings',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.playManual()),
            onboardingStateProvider.overrideWith(
              () => _CompletedOnboardingNotifier(),
            ),
          ],
          child: const MoneySyncApp(),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('open-settings')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('open-wallet-connection')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('open-wallet-connection')));
      await tester.pumpAndSettle();

      expect(find.text('Wallet connection'), findsAtLeast(1));
      expect(find.byType(NavigationDestination), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    },
  );
}

class _FailThenSucceedWalletActions implements WalletConnectionActions {
  final replacingValues = <bool>[];
  var _attempts = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<WalletConnectionActionResult> connect(
    WalletToken token, {
    required bool replacing,
    required int lifecycleEpoch,
  }) async {
    replacingValues.add(replacing);
    _attempts += 1;
    if (_attempts == 1) {
      return const WalletConnectionActionFailure(
        WalletReadFailure.invalidToken(),
      );
    }

    return WalletConnectionCatalogReady(
      WalletCatalog(
        accounts: const <WalletAccount>[],
        categories: const <WalletCategory>[],
      ),
      DateTime.utc(2026, 7, 25),
    );
  }

  @override
  Future<void> disconnect({required int lifecycleEpoch}) async {}

  @override
  Future<WalletConnectionActionResult> refresh({
    required int lifecycleEpoch,
  }) async => const WalletConnectionActionFailure(WalletReadFailure.service());
}

class _FakeWalletController extends WalletConnectionController {
  @override
  WalletConnectionViewState build() => const WalletDisconnected();

  @override
  bool get canSubmitToken => true;

  @override
  Future<WalletTokenSubmitResult> submit(WalletToken token) async {
    state = const WalletConnectionLoading();
    await Future<void>.delayed(Duration.zero);
    state = WalletConnected(
      catalog: WalletCatalog(
        accounts: const <WalletAccount>[],
        categories: const <WalletCategory>[],
      ),
      refreshedAt: DateTime.utc(2026, 7, 25),
      isStale: false,
    );
    return WalletTokenSubmitResult.accepted;
  }
}
