import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/use_cases/save_mapping_rule.dart';
import 'package:money_sync/features/mappings/presentation/mapping_editor_page.dart';
import 'package:money_sync/features/mappings/presentation/mapping_providers.dart';
import 'package:money_sync/features/mappings/presentation/mappings_page.dart';

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
        mappingRuleListProvider.overrideWith((ref) async => [
          rule('a'),
          rule('b', enabled: false),
        ]),
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

  testWidgets('merchant matcher section is progressively disclosed',
      (tester) async {
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
