import 'package:money_sync/features/settings/domain/configuration.dart';

sealed class HistoryImportUpdateResult {
  const HistoryImportUpdateResult();
}

final class HistoryImportUpdated extends HistoryImportUpdateResult {
  const HistoryImportUpdated(this.applied);
  final HistoryImportPreferences applied;
}

final class HistoryImportRejected extends HistoryImportUpdateResult {
  const HistoryImportRejected(this.reason);
  final HistoryImportRejectionReason reason;
}

enum HistoryImportRejectionReason {
  windowOutOfRange,
  capOutOfRange,
  capabilityUnavailable,
  permissionNotGranted,
  disclosureNotAccepted,
}

final class UpdateHistoryImport {
  const UpdateHistoryImport({
    required this.isCapabilityAvailable,
    required this.isPermissionGranted,
    required this.isDisclosureAccepted,
  });

  final bool isCapabilityAvailable;
  final bool isPermissionGranted;
  final bool isDisclosureAccepted;

  HistoryImportUpdateResult call(HistoryImportPreferences requested) {
    if (requested.windowDays < kHistoryMinWindowDays ||
        requested.windowDays > kHistoryMaxWindowDays) {
      return const HistoryImportRejected(
        HistoryImportRejectionReason.windowOutOfRange,
      );
    }
    if (requested.messageCap < 1 || requested.messageCap > kHistoryHardCap) {
      return const HistoryImportRejected(
        HistoryImportRejectionReason.capOutOfRange,
      );
    }
    if (requested.enabled) {
      if (!isCapabilityAvailable) {
        return const HistoryImportRejected(
          HistoryImportRejectionReason.capabilityUnavailable,
        );
      }
      if (!isPermissionGranted) {
        return const HistoryImportRejected(
          HistoryImportRejectionReason.permissionNotGranted,
        );
      }
      if (!isDisclosureAccepted) {
        return const HistoryImportRejected(
          HistoryImportRejectionReason.disclosureNotAccepted,
        );
      }
    }
    return HistoryImportUpdated(requested);
  }
}
