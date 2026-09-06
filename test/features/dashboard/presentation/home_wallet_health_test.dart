import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/dashboard/presentation/home_page.dart';
import 'package:money_sync/features/dashboard/presentation/home_wallet_health.dart';

void main() {
  ProviderScope wrap(HomeWalletHealth health) {
    return ProviderScope(
      overrides: [
        homeSummaryProvider.overrideWith(
          (ref) async => (imported: 5, candidates: 3),
        ),
        homeWalletHealthProvider.overrideWith((ref) => Stream.value(health)),
      ],
      child: const MaterialApp(home: HomePage()),
    );
  }

  testWidgets('renders review / retry / waiting counters', (tester) async {
    await tester.pumpWidget(
      wrap(
        const HomeWalletHealth(
          reviewCount: 3,
          retryCount: 1,
          waitingCount: 2,
          succeededCount: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('REVIEW'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('WAITING'), findsOneWidget);
  });

  testWidgets('renders the latest created record card', (tester) async {
    await tester.pumpWidget(
      wrap(
        HomeWalletHealth(
          reviewCount: 0,
          retryCount: 0,
          waitingCount: 0,
          succeededCount: 0,
          latestRecord: LatestWalletRecord(
            remoteId: 'record-9',
            amountMinor: -123456,
            currencyCode: 'LKR',
            createdAtEpochMs: 1_700_000_000_000,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wallet transaction'), findsOneWidget);
    expect(find.textContaining('LKR'), findsOneWidget);
  });

  testWidgets(
    'shows the empty state when there is no outbox or link activity',
    (tester) async {
      await tester.pumpWidget(wrap(HomeWalletHealth.empty));
      await tester.pumpAndSettle();

      // No latest record card shown when health is empty
      expect(find.text('Wallet transaction'), findsNothing);
    },
  );
}
