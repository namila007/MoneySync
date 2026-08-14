import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule.dart';
import 'package:money_sync/features/mappings/domain/mapping_rule_resolver.dart';
import 'package:money_sync/features/mappings/presentation/mapping_editor_page.dart';

void main() {
  const now = 1_700_000_000_000;

  MappingRule sampleRule() => MappingRule(
    id: 'rule-1',
    name: 'Sample credit card',
    enabled: true,
    senderMatcher: SenderMatcher(['BANK ALPHA']),
    instrumentSuffixHash: '••56',
    walletAccountId: 'wallet-1',
    paymentType: 'debit_card',
    syncMode: MappingSyncMode.review,
    priority: 0,
    ruleVersion: 1,
    createdAtEpochMs: now,
    updatedAtEpochMs: now,
  );

  testWidgets('RulePreviewPanel shows a resolved match for a sample candidate',
      (tester) async {
    final resolver = MappingRuleResolver(rules: [sampleRule()]);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RulePreviewPanel(resolver: resolver))),
    );

    expect(find.text('Preview (sample candidates)'), findsOneWidget);
    expect(find.textContaining('BANK ALPHA'), findsWidgets);
    expect(find.textContaining('Match →'), findsWidgets);
    expect(find.textContaining('No match'), findsWidgets);
  });

  testWidgets('RulePreviewPanel renders unresolved samples without writes',
      (tester) async {
    final resolver = MappingRuleResolver(
      rules: [sampleRule()],
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RulePreviewPanel(resolver: resolver))),
    );
    // Preview is read-only: no text fields, no buttons.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });
}
