import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_tracking/domain/tracked_senders.dart';
import 'package:money_sync/features/sms_tracking/presentation/tracked_senders_controller.dart';
import 'package:money_sync/features/sms_tracking/presentation/tracked_senders_page.dart';

Widget _app(_FakeController controller) {
  return ProviderScope(
    overrides: [
      trackedSendersControllerProvider.overrideWith(() => controller),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TrackedSendersPage(
                    loadDeviceSenders: _loadDeviceSenders,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<List<String>> _loadDeviceSenders() async => const ['DEVICE A'];

void main() {
  // Fixed pumps instead of pumpAndSettle: the search field's cursor blinks
  // forever, so the test never settles.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('typing filters the sender list and clearing restores', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeController()));
    await tester.tap(find.text('open'));
    await settle(tester);

    expect(find.text('BANKX'), findsOneWidget);
    expect(find.text('TELCO Z'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tel');
    await settle(tester);

    expect(find.text('BANKX'), findsNothing);
    expect(find.text('TELCO Z'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await settle(tester);

    expect(find.text('BANKX'), findsOneWidget);
    expect(find.text('TELCO Z'), findsOneWidget);
  });

  testWidgets('a filter with no matches shows the empty-search message', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeController()));
    await tester.tap(find.text('open'));
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'zzz');
    await settle(tester);

    expect(find.textContaining('No senders match'), findsOneWidget);
  });

  testWidgets('save lives in the AppBar, counts selection and pops', (
    tester,
  ) async {
    final controller = _FakeController();
    await tester.pumpWidget(_app(controller));
    await tester.tap(find.text('open'));
    await settle(tester);

    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.text('DEVICE A'));
    await settle(tester);
    expect(find.text('3 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check));
    await settle(tester);

    expect(controller.saved, isTrue);
    expect(find.text('open'), findsOneWidget); // popped back to the host page
  });
}

class _FakeController extends TrackedSendersController {
  _FakeController();

  bool saved = false;

  @override
  AsyncValue<List<String>> build() =>
      AsyncValue.data(const ['BANKX', 'TELCO Z']);

  @override
  Future<UpdateTrackedSendersResult> save() async {
    saved = true;
    return TrackedSendersUpdated(state.value ?? const []);
  }
}
