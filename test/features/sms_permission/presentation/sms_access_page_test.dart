import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_access_page.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

Widget _app(SmsPermissionStatus status) {
  return ProviderScope(
    overrides: [
      smsPermissionGatewayProvider.overrideWithValue(_FixedGateway(status)),
    ],
    child: const MaterialApp(home: SmsAccessPage()),
  );
}

void main() {
  group('SmsAccessPage', () {
    testWidgets('granted shows On, read-only, no dead cards, and turn-off', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SmsPermissionStatus.granted));
      await tester.pumpAndSettle();

      expect(find.text('Granted · read-only'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Turn off message reading'),
        200,
      );
      expect(find.text('Turn off message reading'), findsOneWidget);
      // M4.15 WP7: the disabled Import stub and the duplicated disclosure
      // card are gone from the granted view.
      expect(find.text('Import messages…'), findsNothing);
      expect(find.text('What this allows'), findsNothing);
      expect(find.text('Turn on message reading'), findsNothing);
    });

    testWidgets('notRequested offers Turn on with disclosure-first note', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SmsPermissionStatus.notRequested));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Turn on message reading'),
        200,
      );
      expect(find.text('Turn on message reading'), findsOneWidget);
      expect(find.text('(shows the disclosure first)'), findsOneWidget);
    });

    testWidgets('denied offers Turn on, no system-settings-only path', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SmsPermissionStatus.denied));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Turn on message reading'),
        200,
      );
      expect(find.text('Turn on message reading'), findsOneWidget);
      expect(find.text('Open system settings'), findsNothing);
    });

    testWidgets('permanentlyDenied offers only Open system settings', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SmsPermissionStatus.permanentlyDenied));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Open system settings'), 200);
      expect(find.text('Open system settings'), findsOneWidget);
      expect(find.text('Turn on message reading'), findsNothing);
    });

    testWidgets('revoked shows paused banner and offers Turn on', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SmsPermissionStatus.revoked));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Message reading was turned off outside the app. Importing is paused.',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Turn on message reading'),
        200,
      );
      expect(find.text('Turn on message reading'), findsOneWidget);
    });

    testWidgets('unavailableInBuild shows paste/share copy, no request', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SmsPermissionStatus.unavailableInBuild));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('This version imports messages you paste or share'),
        200,
      );
      expect(
        find.textContaining('This version imports messages you paste or share'),
        findsOneWidget,
      );
      expect(find.text('Turn on message reading'), findsNothing);
      expect(find.text('Open system settings'), findsNothing);
    });
  });
}

final class _FixedGateway implements SmsPermissionGateway {
  const _FixedGateway(this.status);

  final SmsPermissionStatus status;

  @override
  Future<SmsPermissionStatus> current() async => status;

  @override
  Future<SmsPermissionStatus> request() async => status;

  @override
  Future<void> openAppSettings() async {}
}
