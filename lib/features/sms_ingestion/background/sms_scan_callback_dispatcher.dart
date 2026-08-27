import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:workmanager/workmanager.dart';

import 'background_composition_root.dart';

final _log = Logger('sms.scan');

/// Entry point for the headless WorkManager isolate that runs periodic
/// SMS scans. Annotated with `@pragma('vm:entry-point')` so the Dart VM
/// preserves it through tree-shaking and the Android WorkManager runtime
/// can locate it.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final root = BackgroundCompositionRoot();
      final scan = await root.build();
      await scan();
      return Future.value(true);
    } on Exception catch (e, s) {
      _log.error('Isolate bootstrap or scan failed', e, s);
      return Future.value(false);
    }
  });
}
