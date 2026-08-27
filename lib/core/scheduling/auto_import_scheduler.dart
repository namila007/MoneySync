import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

const _kTaskName = 'money_sync_sms_scan';

abstract interface class AutoImportScheduler {
  Future<void> enable({Duration frequency = const Duration(minutes: 15)});
  Future<void> disable();
}

final autoImportSchedulerProvider = Provider<AutoImportScheduler>((ref) {
  return WorkmanagerAutoImportScheduler();
});

final class WorkmanagerAutoImportScheduler implements AutoImportScheduler {
  @override
  Future<void> enable({Duration frequency = const Duration(minutes: 15)}) {
    return Workmanager().registerPeriodicTask(
      _kTaskName,
      'sms_scan',
      frequency: frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(requiresBatteryNotLow: true),
    );
  }

  @override
  Future<void> disable() {
    return Workmanager().cancelByUniqueName(_kTaskName);
  }
}
