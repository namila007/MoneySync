import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money_sync/app/app.dart';
import 'package:money_sync/bootstrap/app_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const flavorName = String.fromEnvironment(
    'MONEY_SYNC_FLAVOR',
    defaultValue: 'playManual',
  );
  final config = switch (flavorName) {
    'privateFull' => const AppConfig.privateFull(),
    'playManual' => const AppConfig.playManual(),
    _ => throw StateError('Unsupported MONEY_SYNC_FLAVOR: $flavorName'),
  };

  testWidgets('$flavorName shell launches with gated capabilities', (
    tester,
  ) async {
    await tester.pumpWidget(MoneySyncApp(config: config));

    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text(config.displayName), findsOneWidget);
    expect(find.text('Disabled'), findsWidgets);
    expect(find.text('Enabled'), findsNothing);
  });
}
