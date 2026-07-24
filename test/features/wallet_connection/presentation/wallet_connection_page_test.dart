import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_controller.dart';
import 'package:money_sync/features/wallet_connection/presentation/wallet_connection_page.dart';

void main() {
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

      expect(
        find.text('Wallet connection is not available yet'),
        findsOneWidget,
      );
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
      await tester.tap(find.text('Save token'));
      await tester.pump();
      expect(find.text('Enter a valid Wallet token.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'synthetic-token');
      await tester.tap(find.text('Save token'));
      await tester.pumpAndSettle();

      expect(find.text('Wallet connection is ready'), findsOneWidget);
      expect(find.text('synthetic-token'), findsNothing);
    },
  );

  testWidgets(
    'MoneySync router reaches nested Wallet settings and returns to Settings',
    (tester) async {
      await tester.pumpWidget(MoneySyncApp(config: AppConfig.playManual()));
      await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-wallet-connection')));
      await tester.pumpAndSettle();

      expect(find.text('Wallet connection'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    },
  );
}

class _FakeWalletController extends WalletConnectionController {
  @override
  WalletConnectionViewState build() => const WalletDisconnected();

  @override
  Future<WalletTokenSubmitResult> submit(WalletToken token) async {
    state = const WalletConnectionLoading();
    await Future<void>.delayed(Duration.zero);
    state = const WalletConnected();
    return WalletTokenSubmitResult.accepted;
  }
}
