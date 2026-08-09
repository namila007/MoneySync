import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets(
    'Settings hub shows actionable M3.2 rows and keeps future rows gated',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.playManual()),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('open-wallet-connection')),
        250,
        scrollable: scrollable,
      );
      final walletConnection = tester.widget<ListTile>(
        find.byKey(const ValueKey('open-wallet-connection')),
      );
      await tester.scrollUntilVisible(
        find.text('Processing default'),
        250,
        scrollable: scrollable,
      );
      final actionableRows = tester
          .widgetList<ListTile>(find.byType(ListTile, skipOffstage: false))
          .where((tile) => tile.onTap != null)
          .toList();

      expect(walletConnection.onTap, isNotNull);
      expect(actionableRows.length, greaterThanOrEqualTo(3));
    },
  );

  testWidgets(
    'Configuration hub shows its sections and keeps future controls gated',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.playManual()),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      final scrollable = find.byType(Scrollable).first;

      expect(find.text('Security & Privacy'), findsOneWidget);
      // SMS controls moved to the Configuration hub in M4.4; the settings page
      // must no longer carry a duplicate permanently-locked SMS section.
      expect(find.text('SMS & Tracking'), findsNothing);
      expect(
        find.text('Available in M4: SMS import remains disabled.'),
        findsNothing,
      );

      await tester.scrollUntilVisible(
        find.text('Wallet'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Review is the current safe default.'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Data & Diagnostics'),
        250,
        scrollable: scrollable,
      );
      expect(find.text('Data & Diagnostics'), findsOneWidget);
      expect(find.text('Wallet creation'), findsOneWidget);
    },
  );
}
