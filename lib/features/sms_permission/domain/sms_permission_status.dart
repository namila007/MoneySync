enum SmsPermissionStatus {
  unavailableInBuild,
  notRequested,
  granted,
  denied,
  permanentlyDenied,
  revoked,
}

extension SmsPermissionStatusX on SmsPermissionStatus {
  bool get canRead => this == SmsPermissionStatus.granted;

  bool get isRequestable =>
      this == SmsPermissionStatus.notRequested ||
      this == SmsPermissionStatus.denied ||
      this == SmsPermissionStatus.revoked;

  bool get requiresSystemSettings =>
      this == SmsPermissionStatus.permanentlyDenied;
}
