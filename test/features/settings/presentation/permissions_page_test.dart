import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_gateway.dart';
import 'package:money_sync/features/notification_permission/domain/notification_permission_status.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';
import 'package:money_sync/features/settings/presentation/permissions_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

Widget _app({
  SmsPermissionStatus smsStatus = SmsPermissionStatus.granted,
  NotificationPermissionStatus notificationStatus =
      NotificationPermissionStatus.granted,
}) {
  return ProviderScope(
    overrides: [
      smsPermissionGatewayProvider.overrideWithValue(
        _FixedSmsGateway(smsStatus),
      ),
      notificationPermissionGatewayProvider.overrideWithValue(
        _FixedNotificationGateway(notificationStatus),
      ),
    ],
    child: const MaterialApp(home: PermissionsPage()),
  );
}

void main() {
  group('PermissionsPage', () {
    testWidgets('shows both permission tiles', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Message reading'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('SMS granted shows On glyph', (tester) async {
      await tester.pumpWidget(
        _app(smsStatus: SmsPermissionStatus.granted),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('On'), findsWidgets);
    });

    testWidgets('SMS off shows Off glyph', (tester) async {
      await tester.pumpWidget(
        _app(smsStatus: SmsPermissionStatus.denied),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Off'), findsWidgets);
    });

    testWidgets('notifications granted shows On', (tester) async {
      await tester.pumpWidget(
        _app(notificationStatus: NotificationPermissionStatus.granted),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('On'), findsWidgets);
    });

    testWidgets('notifications off shows Off', (tester) async {
      await tester.pumpWidget(
        _app(
          notificationStatus: NotificationPermissionStatus.notRequested,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Off'), findsWidgets);
    });
  });
}

final class _FixedSmsGateway implements SmsPermissionGateway {
  _FixedSmsGateway(this.status);

  final SmsPermissionStatus status;

  @override
  Future<SmsPermissionStatus> current() async => status;

  @override
  Future<SmsPermissionStatus> request() async => status;

  @override
  Future<void> openAppSettings() async {}
}

final class _FixedNotificationGateway
    implements NotificationPermissionGateway {
  _FixedNotificationGateway(this.status);

  final NotificationPermissionStatus status;

  @override
  Future<NotificationPermissionStatus> current() async => status;

  @override
  Future<NotificationPermissionStatus> request() async => status;

  @override
  Future<void> openAppSettings() async {}
}
