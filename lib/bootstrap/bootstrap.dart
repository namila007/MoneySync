import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/bootstrap_logging.dart';
import 'package:money_sync/bootstrap/foreground_composition.dart';
import 'package:money_sync/bootstrap/providers.dart';
import 'package:money_sync/features/notification_permission/data/permission_handler_notification_gateway.dart';
import 'package:money_sync/features/notification_permission/presentation/notification_permission_controller.dart';
import 'package:money_sync/features/sms_permission/data/pigeon_sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/presentation/sms_permission_controller.dart';

void bootstrap(AppConfig config) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        // Must live in the ROOT scope. smsPermissionStatusProvider is not
        // itself overridden anywhere, so Riverpod hosts it in the root
        // container; overriding the gateway only in a nested scope leaves the
        // notifier reading the root's throwing default.
        smsPermissionGatewayProvider.overrideWithValue(
          PigeonSmsPermissionGateway(),
        ),
        // Must live in the ROOT scope, same as SMS. notificationPermissionStatusProvider
        // is not itself overridden anywhere, so Riverpod hosts it in the root
        // container; overriding the gateway only in a nested scope leaves the
        // notifier reading the root's throwing default.
        notificationPermissionGatewayProvider.overrideWithValue(
          PermissionHandlerNotificationGateway(),
        ),
      ],
      child: BootstrapGate(config: config),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    initLogFileHandlers(config);
  });
}
