enum NotificationPermissionStatus {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
}

extension NotificationPermissionStatusX on NotificationPermissionStatus {
  bool get canNotify => this == NotificationPermissionStatus.granted;

  bool get isRequestable =>
      this == NotificationPermissionStatus.notRequested ||
      this == NotificationPermissionStatus.denied;

  bool get requiresSystemSettings =>
      this == NotificationPermissionStatus.permanentlyDenied;
}
