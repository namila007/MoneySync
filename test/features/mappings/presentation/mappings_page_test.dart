import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/use_cases/save_mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_editor_page.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/mappings/presentation/mappings_page.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule rule(String id, {bool enabled = true}) => MappingRule(
    id: id,
    name: 'Rule $id',
    enabled: enabled,
    senderMatcher: SenderMatcher(['SAMPATH BANK']),
    walletAccountId: 'wallet-1',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: 0,
    ruleVersion: 1,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  ProviderScope wrapWith(Widget child) {
    return ProviderScope(
      overrides: [
        mappingRuleListProvider.overrideWith(
          (ref) async => [rule('a'), rule('b', enabled: false)],
        ),
        walletCatalogProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('list shows rules and their enabled state', (tester) async {
    await tester.pumpWidget(wrapWith(const MappingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Rule a'), findsOneWidget);
    expect(find.text('Rule b'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('empty list shows the create hint', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mappingRuleListProvider.overrideWith((ref) async => []),
          walletCatalogProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(home: MappingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No mapping rules yet'), findsOneWidget);
  });

  testWidgets('new-mapping editor renders fields and save', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mappingRuleStoreProvider.overrideWith(
            (ref) async => _FakeMappingRuleStore(),
          ),
          walletCatalogProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(home: MappingEditorPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New mapping'), findsOneWidget);
    expect(find.text('Rule name'), findsOneWidget);
    expect(find.text('Sender (comma separated)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save mapping'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Save mapping'), findsOneWidget);
  });

  testWidgets('merchant matcher section is progressively disclosed', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mappingRuleStoreProvider.overrideWith(
            (ref) async => _FakeMappingRuleStore(),
          ),
          walletCatalogProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(home: MappingEditorPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Hidden by default; toggling reveals exact/contains (no regex input).
    final merchantTitle = find.text('Merchant matcher');
    await tester.scrollUntilVisible(
      merchantTitle,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Merchant'), findsNothing);
    final merchantSwitch = find.descendant(
      of: find.ancestor(of: merchantTitle, matching: find.byType(ListTile)),
      matching: find.byType(Switch),
    );
    await tester.tap(merchantSwitch);
    await tester.pumpAndSettle();
    expect(find.text('Exact'), findsOneWidget);
    expect(find.text('Contains'), findsOneWidget);
  });

  testWidgets('save invalidates list provider so new rule appears on return', (
    tester,
  ) async {
    final store = _StatefulFakeMappingRuleStore();
    final catalog = WalletCatalog(
      accounts: [
        const WalletAccount(
          id: 'wallet-1',
          name: 'Spending',
          currencyCode: 'LKR',
          isArchived: false,
          isBankSynced: false,
          isWritable: true,
        ),
      ],
      categories: const [],
    );

    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mappingRuleStoreProvider.overrideWith((ref) async => store),
          mappingRuleListProvider.overrideWith((ref) async => store.list()),
          walletCatalogProvider.overrideWith((ref) async => catalog),
        ],
        child: MaterialApp(navigatorKey: navKey, home: const MappingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Mappings list is initially empty.
    expect(find.textContaining('No mapping rules yet'), findsOneWidget);

    // Push editor directly (bypasses GoRouter).
    navKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const MappingEditorPage()),
    );
    await tester.pumpAndSettle();

    // Fill required form fields.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rule name'),
      'Test Rule',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Sender (comma separated)'),
      'SAMPATH BANK',
    );

    // Select wallet account from dropdown.
    await tester.tap(find.text('Wallet account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spending'));
    await tester.pumpAndSettle();

    // Save and pop back to mappings list.
    await tester.scrollUntilVisible(
      find.text('Save mapping'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save mapping'));
    await tester.pumpAndSettle();

    // List now shows the saved rule — no manual refresh needed.
    expect(find.text('Test Rule'), findsOneWidget);
    expect(find.textContaining('No mapping rules yet'), findsNothing);
  });
}

final class _FakeMappingRuleStore implements MappingRuleStore {
  @override
  Future<List<MappingRule>> list() async => [];

  @override
  Future<MappingRule?> latest(String ruleId) async => null;

  @override
  Future<MappingRule> saveVersioned({
    required MappingRule rule,
    String? supersededRuleId,
  }) async => rule;
}

/// Mutable fake: [list] returns whatever has been saved so far, proving
/// that provider invalidation triggers a fresh fetch with new data.
final class _StatefulFakeMappingRuleStore implements MappingRuleStore {
  final List<MappingRule> _rules = [];

  @override
  Future<List<MappingRule>> list() async => List.unmodifiable(_rules);

  @override
  Future<MappingRule?> latest(String ruleId) async =>
      _rules.isEmpty ? null : _rules.lastWhere((r) => r.id == ruleId);

  @override
  Future<MappingRule> saveVersioned({
    required MappingRule rule,
    String? supersededRuleId,
  }) async {
    _rules.add(rule);
    return rule;
  }
}
