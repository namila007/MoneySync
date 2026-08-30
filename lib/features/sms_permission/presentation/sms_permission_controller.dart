import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';
import 'package:money_sync/features/sms_permission/domain/request_sms_permission.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_gateway.dart';
import 'package:money_sync/features/sms_permission/domain/sms_permission_status.dart';

final _log = Logger('sms_permission');

final smsPermissionGatewayProvider = Provider<SmsPermissionGateway>((ref) {
  throw StateError('smsPermissionGatewayProvider must be overridden.');
});

final smsPermissionStatusProvider =
    NotifierProvider<SmsPermissionNotifier, AsyncValue<SmsPermissionStatus>>(
      SmsPermissionNotifier.new,
    );

class SmsPermissionNotifier extends Notifier<AsyncValue<SmsPermissionStatus>> {
  SmsPermissionStatus? _lastObserved;

  @override
  AsyncValue<SmsPermissionStatus> build() {
    unawaited(refresh());
    return const AsyncValue.loading();
  }

  Future<void> refresh() async {
    // build() fires this without awaiting it, so anything that escapes here is
    // swallowed and the UI keeps showing AsyncValue.loading() forever. Both the
    // gateway lookup and the platform call therefore sit inside the guard, and
    // the guard catches Object rather than Exception: a missing provider
    // override throws StateError, which `on Exception` would not catch.
    try {
      final gateway = ref.read(smsPermissionGatewayProvider);
      final status = await gateway.current().timeout(
        const Duration(seconds: 5),
      );
      if (_lastObserved == SmsPermissionStatus.granted &&
          status != SmsPermissionStatus.granted &&
          _lastObserved != null) {
        _lastObserved = SmsPermissionStatus.revoked;
        state = AsyncValue.data(SmsPermissionStatus.revoked);
        return;
      }
      _lastObserved = status;
      state = AsyncValue.data(status);
    } on TimeoutException catch (e, s) {
      _log.error('SMS permission status check timed out after 5s', e, s);
      state = AsyncValue.error(e, s);
    } on Object catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<SmsPermissionRequestOutcome> request({
    required int? acceptedDisclosureRevision,
  }) async {
    final gateway = ref.read(smsPermissionGatewayProvider);
    final useCase = RequestSmsPermission(
      gateway: gateway,
      disclosureRevisionRequired: 1,
    );
    final outcome = await useCase(
      acceptedDisclosureRevision: acceptedDisclosureRevision,
    );
    await refresh();
    return outcome;
  }

  Future<void> openSystemSettings() async {
    final gateway = ref.read(smsPermissionGatewayProvider);
    await gateway.openAppSettings();
  }
}
