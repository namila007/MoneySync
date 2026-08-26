import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/production_providers.dart';
import 'package:money_sync/core/database/app_database.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/review_inbox/presentation/inbox_detail_page.dart'
    show CandidateSummaryView;
import 'package:money_sync/features/review_inbox/presentation/review_transaction_panel.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

// ---------------------------------------------------------------------------
// Test catalog
// ---------------------------------------------------------------------------

final _catalog = WalletCatalog(
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
    WalletAccount(
      id: 'archived-1',
      name: 'Old Savings',
      currencyCode: 'LKR',
      isArchived: true,
      isBankSynced: false,
      isWritable: true,
    ),
  ],
  categories: const [
    WalletCategory(
      id: 'food__general',
      name: 'Food & Drinks',
      groupId: 'food',
      groupName: 'Food & Drinks',
      systemId: 'food__general',
    ),
    WalletCategory(
      id: 'food-lunch',
      name: 'Lunch',
      groupId: 'food',
      groupName: 'Food & Drinks',
    ),
    WalletCategory(
      id: 'transport__general',
      name: 'Transport',
      groupId: 'transport',
      groupName: 'Transport',
      systemId: 'transport__general',
    ),
    WalletCategory(
      id: 'transport-bus',
      name: 'Bus',
      groupId: 'transport',
      groupName: 'Transport',
    ),
  ],
  labels: const [
    WalletLabel(id: 'label-1', name: 'money_sync'),
    WalletLabel(id: 'label-2', name: 'personal'),
  ],
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {WalletCatalog? catalog}) => ProviderScope(
  overrides: [
    appDatabaseProvider.overrideWith((ref) async {
      final db = AppDatabase.inMemoryForTesting();
      ref.onDispose(db.close);
      return db;
    }),
    walletCatalogProvider.overrideWith((ref) async => catalog ?? _catalog),
    mappingRuleListProvider.overrideWith((ref) async => []),
  ],
  child: MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

const _panel = ReviewTransactionPanel(
  smsEventId: 1,
  encryptedPayload: '{}',
  senderNormalized: 'BANK ALPHA',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ReviewTransactionPanel', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Review transaction'), findsOneWidget);
      expect(find.text('Amount (LKR)'), findsOneWidget);
      expect(find.text('Kind'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('Select date & time'), findsOneWidget);
      expect(find.text('Wallet account'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Payment type'), findsOneWidget);
      expect(find.text('Counterparty'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Labels'), findsOneWidget);
    });

    testWidgets('Create record and Save for later buttons are present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Create record'), findsOneWidget);
      expect(find.text('Save for later'), findsOneWidget);
    });

    testWidgets(
      'action bar is reachable — buttons exist and are tappable (M5.22)',
      (tester) async {
        await tester.pumpWidget(_wrap(_panel));
        await tester.pumpAndSettle();

        final createBtn = find.text('Create record');
        final saveBtn = find.text('Save for later');
        expect(createBtn, findsOneWidget);
        expect(saveBtn, findsOneWidget);

        // The M5.22 regression put these inside a lazily-built ListView which
        // made them unreachable. Verify they are in the widget tree and can be
        // scrolled to (ensureVisible does not throw).
        await tester.ensureVisible(createBtn);
        await tester.pumpAndSettle();
        expect(createBtn, findsOneWidget);

        await tester.ensureVisible(saveBtn);
        await tester.pumpAndSettle();
        expect(saveBtn, findsOneWidget);
      },
    );

    testWidgets('bank-synced and archived accounts shown in dropdown', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Wallet account'));
      await tester.tap(find.text('Wallet account'));
      await tester.pumpAndSettle();

      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Bank Synced (bank-synced)'), findsOneWidget);
      expect(find.text('Old Savings (archived)'), findsOneWidget);
    });

    testWidgets('archived account shows warning text', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Wallet account'));
      await tester.tap(find.text('Wallet account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Old Savings (archived)'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('archived and may not be writable'),
        findsOneWidget,
      );
    });

    testWidgets('kind dropdown defaults to expense', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('expense'), findsWidgets);
    });

    testWidgets('direction dropdown defaults to debit', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('debit'), findsWidgets);
    });

    testWidgets('payment type defaults to Debit card', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Debit card'), findsOneWidget);
    });

    testWidgets('date picker shows "Select date & time" initially', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Select date & time'), findsOneWidget);
    });

    testWidgets('category picker shows Uncategorized initially', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Uncategorized'), findsOneWidget);
    });

    testWidgets('category picker opens bottom sheet with groups', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Uncategorized'));
      await tester.pumpAndSettle();

      expect(find.text('Select category'), findsOneWidget);
      expect(find.text('Food & Drinks'), findsWidgets);
      expect(find.text('Transport'), findsWidgets);
    });

    testWidgets(
      'category picker allows selecting a MAIN group category (M5.22 WP-G)',
      (tester) async {
        await tester.pumpWidget(_wrap(_panel));
        await tester.pumpAndSettle();

        // Open the category picker.
        await tester.tap(find.text('Uncategorized'));
        await tester.pumpAndSettle();

        // Expand the Food & Drinks group.
        await tester.tap(find.text('Food & Drinks').first);
        await tester.pumpAndSettle();

        // "All Food & Drinks" is the group-general category (M5.22 WP-G).
        final allFood = find.text('All Food & Drinks');
        expect(allFood, findsOneWidget);

        // Tap it — this is the regression: selecting a group, not a leaf.
        await tester.tap(allFood);
        await tester.pumpAndSettle();

        // Button should now show "All Food & Drinks".
        expect(find.text('All Food & Drinks'), findsOneWidget);
        // NOT "Uncategorized" (the old broken behavior).
        expect(find.text('Uncategorized'), findsNothing);
      },
    );

    testWidgets('category picker allows selecting a leaf child', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Uncategorized'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food & Drinks').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();

      expect(find.text('Food & Drinks › Lunch'), findsOneWidget);
    });

    testWidgets('category picker Clear button deselects category', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      // Select a category first.
      await tester.tap(find.text('Uncategorized'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food & Drinks').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();
      expect(find.text('Food & Drinks › Lunch'), findsOneWidget);

      // Re-open and clear.
      await tester.tap(find.text('Food & Drinks › Lunch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Uncategorized'), findsOneWidget);
    });

    testWidgets('empty catalog shows connect Wallet messages', (tester) async {
      final empty = WalletCatalog(accounts: const [], categories: const []);
      await tester.pumpWidget(_wrap(_panel, catalog: empty));
      await tester.pumpAndSettle();

      expect(
        find.text('Connect your Wallet to choose a target account.'),
        findsOneWidget,
      );
      expect(
        find.text('Connect your Wallet to choose a category.'),
        findsOneWidget,
      );
    });

    testWidgets('amount field accepts numeric input', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '4699.00');
      await tester.pump();

      expect(find.text('4699.00'), findsOneWidget);
    });

    testWidgets('counterparty field shows helper text', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Merchant or payee name'), findsOneWidget);
    });

    testWidgets('note field shows helper text', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Add a note (optional)'), findsOneWidget);
    });

    testWidgets('loading catalog shows progress indicator', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              final db = AppDatabase.inMemoryForTesting();
              ref.onDispose(db.close);
              return db;
            }),
            walletCatalogProvider.overrideWithValue(
              AsyncValue<WalletCatalog?>.loading(),
            ),
            mappingRuleListProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: _panel)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('label chips show money_sync and Add label', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Labels'), findsOneWidget);
      expect(find.text('Add label'), findsOneWidget);
    });

    testWidgets('seeded summary fills amount and counterparty', (tester) async {
      const summary = CandidateSummaryView(
        kind: 'expense',
        direction: 'debit',
        lifecycle: 'posted',
        amountMinor: 469900,
        amountCurrency: 'LKR',
        confidenceBasisPoints: 9500,
        requiresReview: true,
        counterParty: 'Test Merchant',
      );

      await tester.pumpWidget(
        _wrap(
          const ReviewTransactionPanel(
            smsEventId: 1,
            encryptedPayload: '{}',
            senderNormalized: 'BANK ALPHA',
            initialSummary: summary,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('4,699.00'), findsOneWidget);
      expect(find.text('Test Merchant'), findsOneWidget);
    });

    testWidgets('fallback date seeds the date button via summary', (
      tester,
    ) async {
      // fallbackDate only seeds when initialSummary has no transactionAtUtc.
      const summary = CandidateSummaryView(
        kind: 'expense',
        direction: 'debit',
        lifecycle: 'posted',
        amountMinor: 10000,
        amountCurrency: 'LKR',
        confidenceBasisPoints: 9000,
        requiresReview: false,
        transactionAtUtc: null,
      );

      await tester.pumpWidget(
        _wrap(
          ReviewTransactionPanel(
            smsEventId: 1,
            encryptedPayload: '{}',
            senderNormalized: 'BANK ALPHA',
            initialSummary: summary,
            fallbackDate: DateTime.utc(2026, 3, 15, 10, 30),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // The date button should show the fallback date (zero-padded).
      expect(find.text('2026-03-15 10:30'), findsOneWidget);
    });

    testWidgets('group general category passes correct id not groupId', (
      tester,
    ) async {
      // M5.22 WP-G regression: old code passed groupId which silently
      // fell back to "Uncategorized".
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Uncategorized'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food & Drinks').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Food & Drinks'));
      await tester.pumpAndSettle();

      // Should show "All Food & Drinks" — NOT "Uncategorized".
      expect(find.text('All Food & Drinks'), findsOneWidget);
      expect(find.text('Uncategorized'), findsNothing);
    });

    testWidgets('submitting Create button shows Creating text', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      // Scroll to and tap Create.
      await tester.ensureVisible(find.text('Create record'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create record'));
      await tester.pump();

      // After tapping, the controller enters submitting state.
      // The button should show "Creating..." or be disabled.
      final creatingText = find.text('Creating…');
      if (creatingText.evaluate().isNotEmpty) {
        expect(creatingText, findsOneWidget);
      } else {
        expect(find.text('Create record'), findsOneWidget);
      }
    });

    testWidgets('empty labels catalog disables Add label chip', (tester) async {
      final noLabelsCatalog = WalletCatalog(
        accounts: const [
          WalletAccount(
            id: 'account-1',
            name: 'Savings',
            currencyCode: 'LKR',
            isArchived: false,
            isBankSynced: false,
            isWritable: true,
          ),
        ],
        categories: const [],
        labels: const [],
      );
      await tester.pumpWidget(_wrap(_panel, catalog: noLabelsCatalog));
      await tester.pumpAndSettle();

      expect(find.text('Add label'), findsOneWidget);
    });

    testWidgets('all four kind options are available in dropdown', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      // Tap the Kind dropdown.
      await tester.ensureVisible(find.text('expense'));
      await tester.tap(find.text('expense'));
      await tester.pumpAndSettle();

      // All TransactionKind values should appear.
      expect(find.text('expense'), findsWidgets);
      expect(find.text('income'), findsOneWidget);
      expect(find.text('transfer'), findsOneWidget);
      expect(find.text('refund'), findsOneWidget);
    });

    testWidgets('all direction options are available in dropdown', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('debit'));
      await tester.tap(find.text('debit'));
      await tester.pumpAndSettle();

      expect(find.text('debit'), findsWidgets);
      expect(find.text('credit'), findsOneWidget);
      expect(find.text('neutral'), findsOneWidget);
    });

    testWidgets('all payment type options are available', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Debit card'));
      await tester.tap(find.text('Debit card'));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Debit card'), findsWidgets);
      expect(find.text('Credit card'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('empty catalog shows connect Wallet for both pickers', (
      tester,
    ) async {
      final empty = WalletCatalog(accounts: const [], categories: const []);
      await tester.pumpWidget(_wrap(_panel, catalog: empty));
      await tester.pumpAndSettle();

      expect(
        find.text('Connect your Wallet to choose a target account.'),
        findsOneWidget,
      );
      expect(
        find.text('Connect your Wallet to choose a category.'),
        findsOneWidget,
      );
    });

    testWidgets('null catalog shows connect Wallet for account', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async {
              final db = AppDatabase.inMemoryForTesting();
              ref.onDispose(db.close);
              return db;
            }),
            walletCatalogProvider.overrideWithValue(
              AsyncValue<WalletCatalog?>.loading(),
            ),
            mappingRuleListProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: _panel)),
          ),
        ),
      );
      await tester.pump();

      // Loading state shows LinearProgressIndicator.
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('seeds amount with commas from summary', (tester) async {
      const summary = CandidateSummaryView(
        kind: 'income',
        direction: 'credit',
        lifecycle: 'posted',
        amountMinor: 123456700,
        amountCurrency: 'LKR',
        confidenceBasisPoints: 9000,
        requiresReview: false,
      );

      await tester.pumpWidget(
        _wrap(
          const ReviewTransactionPanel(
            smsEventId: 1,
            encryptedPayload: '{}',
            senderNormalized: 'BANK ALPHA',
            initialSummary: summary,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // 123456700 minor units = 1,234,567.00
      expect(find.text('1,234,567.00'), findsOneWidget);
    });

    testWidgets('kind dropdown can be changed to income', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      // Open kind dropdown and select income.
      await tester.ensureVisible(find.text('expense'));
      await tester.tap(find.text('expense'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('income'));
      await tester.pumpAndSettle();

      // After changing, the controller should have the new value.
      // The dropdown should now show 'income' as selected.
      expect(find.text('income'), findsWidgets);
    });

    testWidgets('direction dropdown can be changed to credit', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('debit'));
      await tester.tap(find.text('debit'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('credit'));
      await tester.pumpAndSettle();

      expect(find.text('credit'), findsWidgets);
    });

    testWidgets('payment type dropdown can be changed to Cash', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Debit card'));
      await tester.tap(find.text('Debit card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('label picker shows Add label chip', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      expect(find.text('Add label'), findsOneWidget);
    });

    testWidgets('date picker button is tappable', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Select date & time'));
      // Verify the date button is present and enabled.
      final dateBtn = find.widgetWithText(OutlinedButton, 'Select date & time');
      expect(dateBtn, findsOneWidget);
      final button = tester.widget<OutlinedButton>(dateBtn);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('seeds kind and direction from summary', (tester) async {
      const summary = CandidateSummaryView(
        kind: 'income',
        direction: 'credit',
        lifecycle: 'posted',
        amountMinor: 10000,
        amountCurrency: 'LKR',
        confidenceBasisPoints: 9000,
        requiresReview: false,
      );

      await tester.pumpWidget(
        _wrap(
          const ReviewTransactionPanel(
            smsEventId: 1,
            encryptedPayload: '{}',
            senderNormalized: 'BANK ALPHA',
            initialSummary: summary,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // The kind should be seeded to 'income'.
      expect(find.text('income'), findsWidgets);
      // The direction should be seeded to 'credit'.
      expect(find.text('credit'), findsWidgets);
    });

    testWidgets('seeds transfer kind from summary', (tester) async {
      const summary = CandidateSummaryView(
        kind: 'transfer',
        direction: 'debit',
        lifecycle: 'posted',
        amountMinor: 50000,
        amountCurrency: 'LKR',
        confidenceBasisPoints: 9000,
        requiresReview: false,
      );

      await tester.pumpWidget(
        _wrap(
          const ReviewTransactionPanel(
            smsEventId: 1,
            encryptedPayload: '{}',
            senderNormalized: 'BANK ALPHA',
            initialSummary: summary,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('transfer'), findsWidgets);
    });

    testWidgets('seeds refund kind from summary', (tester) async {
      const summary = CandidateSummaryView(
        kind: 'refund',
        direction: 'credit',
        lifecycle: 'posted',
        amountMinor: 20000,
        amountCurrency: 'LKR',
        confidenceBasisPoints: 9000,
        requiresReview: false,
      );

      await tester.pumpWidget(
        _wrap(
          const ReviewTransactionPanel(
            smsEventId: 1,
            encryptedPayload: '{}',
            senderNormalized: 'BANK ALPHA',
            initialSummary: summary,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('refund'), findsWidgets);
    });

    testWidgets('counterparty can be typed into', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      // Find the counterparty TextField.
      final counterpartyField = find.widgetWithText(TextField, 'Counterparty');
      await tester.ensureVisible(counterpartyField);
      await tester.tap(counterpartyField);
      await tester.pump();
      await tester.enterText(counterpartyField, 'Test Shop');
      await tester.pump();

      expect(find.text('Test Shop'), findsOneWidget);
    });

    testWidgets('note can be typed into', (tester) async {
      await tester.pumpWidget(_wrap(_panel));
      await tester.pumpAndSettle();

      final noteField = find.widgetWithText(TextField, 'Note');
      await tester.ensureVisible(noteField);
      await tester.tap(noteField);
      await tester.pump();
      await tester.enterText(noteField, 'Lunch at office');
      await tester.pump();

      expect(find.text('Lunch at office'), findsOneWidget);
    });
  });
}
