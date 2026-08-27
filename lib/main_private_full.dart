import 'package:money_sync/bootstrap/app_config.dart';
import 'package:money_sync/bootstrap/bootstrap.dart';
import 'package:money_sync/features/sms_ingestion/background/sms_scan_callback_dispatcher.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  Workmanager().initialize(callbackDispatcher);
  bootstrap(const AppConfig.privateFull());
}
