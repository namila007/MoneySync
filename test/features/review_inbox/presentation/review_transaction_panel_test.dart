import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_controller.dart';
import 'package:money_sync/features/review_inbox/presentation/review_transaction_panel.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

void main() {
  final writableCatalog = WalletCatalog(
    accounts: const [
      WalletAccount(
        id: 'account-1',
        name: 'Savings',
        currencyCode: 'LKR',
        isArchived: false,
        isBankSynced: false,
        isWritable: true,
      ),
      WalletAccount(
        id: 'bank-1',
        name: 'Bank Synced',
        currencyCode: 'LKR',
        isArchived: false,
        isBankSynced: true,
        isWritable: true,
      ),
    ],
    categories: const [],
  );

  ProviderScope wrap(Widget child) {
    return ProviderScope(
      overrides: [
        walletCatalogProvider.overrideWith((ref) async => writableCatalog),
        mappingRuleListProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  testWidgets('renders editable review fields and a Create button', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ReviewTransactionPanel(
          smsEventId: 1,
          encryptedPayload: '{}',
          senderNormalized: 'BANK ALPHA',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review transaction'), findsOneWidget);
    expect(find.text('Amount (minor units)'), findsOneWidget);
    expect(find.text('Kind'), findsOneWidget);
    expect(find.text('Direction'), findsOneWidget);
    expect(find.text('Wallet account'), findsOneWidget);
    expect(find.text('Payment type'), findsOneWidget);
    expect(find.text('Counterparty'), findsOneWidget);
    expect(find.text('Create record'), findsOneWidget);
  });

  testWidgets('Create evaluates the gate chain and shows the gate list', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ReviewTransactionPanel(
          smsEventId: 1,
          encryptedPayload: '{}',
          senderNormalized: 'BANK ALPHA',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Default amount is 0 -> amount validation gate blocks.
    await tester.ensureVisible(find.text('Create record'));
    await tester.tap(find.text('Create record'));
    await tester.pumpAndSettle();

    expect(find.text('Pre-send gates'), findsOneWidget);
    expect(find.text('Amount/date/currency'), findsOneWidget);
  });

  testWidgets('bank-synced target is shown but disabled', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ReviewTransactionPanel(
          smsEventId: 1,
          encryptedPayload: '{}',
          senderNormalized: 'BANK ALPHA',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Wallet account'));
    await tester.tap(find.text('Wallet account'));
    await tester.pumpAndSettle();

    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Bank Synced (bank-synced)'), findsOneWidget);
  });

  testWidgets('submitting state disables the Create button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletCatalogProvider.overrideWith((ref) async => writableCatalog),
          mappingRuleListProvider.overrideWith((ref) async => []),
          // reviewTransactionControllerProvider overridden to a busy state.
          reviewTransactionControllerProvider.overrideWith2(
            _BusyReviewController.new,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReviewTransactionPanel(
                smsEventId: 1,
                encryptedPayload: '{}',
                senderNormalized: 'BANK ALPHA',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('Creating…'));
    final button = tester.widget<FilledButton>(
      find.ancestor(of: find.text('Creating…'), matching: find.byType(FilledButton)),
    );
    expect(button.onPressed, isNull);
  });
}

final class _BusyReviewController extends ReviewTransactionController {
  _BusyReviewController(super.smsEventId);

  @override
  ReviewTransactionViewState build() =>
      const ReviewTransactionViewState(submitting: true);
}
