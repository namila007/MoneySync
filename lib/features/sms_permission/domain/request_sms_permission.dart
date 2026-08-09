import 'sms_permission_gateway.dart';
import 'sms_permission_status.dart';

sealed class SmsPermissionRequestOutcome {
  const SmsPermissionRequestOutcome();
}

final class SmsPermissionRequestCompleted extends SmsPermissionRequestOutcome {
  const SmsPermissionRequestCompleted(this.status);
  final SmsPermissionStatus status;
}

final class SmsPermissionRequestRefusedWithoutDisclosure
    extends SmsPermissionRequestOutcome {
  const SmsPermissionRequestRefusedWithoutDisclosure();
}

final class SmsPermissionRequestUnavailable
    extends SmsPermissionRequestOutcome {
  const SmsPermissionRequestUnavailable();
}

final class RequestSmsPermission {
  const RequestSmsPermission({
    required SmsPermissionGateway gateway,
    required this.disclosureRevisionRequired,
  }) : _gateway = gateway;

  final SmsPermissionGateway _gateway;
  final int disclosureRevisionRequired;

  Future<SmsPermissionRequestOutcome> call({
    required int? acceptedDisclosureRevision,
  }) async {
    final status = await _gateway.current();
    if (status == SmsPermissionStatus.unavailableInBuild) {
      return const SmsPermissionRequestUnavailable();
    }
    if (acceptedDisclosureRevision == null ||
        acceptedDisclosureRevision < disclosureRevisionRequired) {
      return const SmsPermissionRequestRefusedWithoutDisclosure();
    }
    if (!status.isRequestable) {
      return SmsPermissionRequestCompleted(status);
    }
    return SmsPermissionRequestCompleted(await _gateway.request());
  }
}
