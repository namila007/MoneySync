import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/settings/presentation/configuration_hub_page.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

const _activityMarker = 'ACTIVITY-LOG-DESTINATION';
const _securityMarker = 'APP-LOCK-DESTINATION';

Widget _app() {
  final router = GoRouter(
    initialLocation: '/settings/configuration',
    routes: [
      GoRoute(
        path: '/activity',
        builder: (context, state) =>
            const Scaffold(body: Text(_activityMarker)),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) =>
            const Scaffold(body: Text(_securityMarker)),
      ),
      GoRoute(
        path: '/settings/configuration',
        builder: (context, state) => const ConfigurationHubPage(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.playManual()),
      smsPermissionGatewayProvider.overrideWithValue(_UnavailableGateway()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('Configuration hub navigation', () {
    testWidgets('Activity history opens the activity log, not the app lock', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Activity history'));
      await tester.pumpAndSettle();

      expect(find.text(_activityMarker), findsOneWidget);
      expect(find.text(_securityMarker), findsNothing);
    });

    testWidgets('App lock still opens the security page', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('App lock'));
      await tester.pumpAndSettle();

      expect(find.text(_securityMarker), findsOneWidget);
    });

    testWidgets('Message reading resolves off the loading placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Checking…'), findsNothing);
      expect(find.text('Message reading'), findsOneWidget);
    });
  });
}

final class _UnavailableGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionStatus> current() async =>
      SmsPermissionStatus.unavailableInBuild;

  @override
  Future<SmsPermissionStatus> request() async =>
      SmsPermissionStatus.unavailableInBuild;

  @override
  Future<void> openAppSettings() async {}
}
