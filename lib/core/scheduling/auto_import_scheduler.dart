import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

const _kTaskName = 'money_sync_sms_scan';
const _kFrequency = Duration(minutes: 15);

abstract interface class AutoImportScheduler {
  Future<void> enable();
  Future<void> disable();
}

final autoImportSchedulerProvider = Provider<AutoImportScheduler>((ref) {
  return WorkmanagerAutoImportScheduler();
});

final class WorkmanagerAutoImportScheduler implements AutoImportScheduler {
  @override
  Future<void> enable() {
    return Workmanager().registerPeriodicTask(
      _kTaskName,
      'sms_scan',
      frequency: _kFrequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(requiresBatteryNotLow: true),
    );
  }

  @override
  Future<void> disable() {
    return Workmanager().cancelByUniqueName(_kTaskName);
  }
}
