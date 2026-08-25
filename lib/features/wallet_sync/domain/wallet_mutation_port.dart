sealed class WalletMutationResult {
  const WalletMutationResult();
}

final class WalletMutationDisabled extends WalletMutationResult {
  const WalletMutationDisabled();
}

final class WalletMutationPreTransmissionFailure extends WalletMutationResult {
  const WalletMutationPreTransmissionFailure();
}

final class WalletMutationRemoteSuccess extends WalletMutationResult {
  factory WalletMutationRemoteSuccess({
    required int statusCode,
    required String remoteRecordId,
  }) {
    if ((statusCode != 200 && statusCode != 207) || remoteRecordId.isEmpty) {
      throw ArgumentError(
        'A remote success needs status 200/207 and a non-empty record ID.',
      );
    }
    return WalletMutationRemoteSuccess._(
      statusCode: statusCode,
      remoteRecordId: remoteRecordId,
    );
  }

  const WalletMutationRemoteSuccess._({
    required this.statusCode,
    required this.remoteRecordId,
  });

  final int statusCode;
  final String remoteRecordId;
}

final class WalletMutationClientFailure extends WalletMutationResult {
  const WalletMutationClientFailure();
}

final class WalletMutationServerFailure extends WalletMutationResult {
  const WalletMutationServerFailure();
}

/// The transport outcome is ambiguous; callers must reconcile before retrying.
final class WalletMutationPostTransmissionAmbiguity
    extends WalletMutationResult {
  const WalletMutationPostTransmissionAmbiguity();
}

/// Explicit ownership evidence created only by successful reconciliation.
final class WalletMutationReconciledOwnership extends WalletMutationResult {
  factory WalletMutationReconciledOwnership(String remoteRecordId) {
    if (remoteRecordId.isEmpty) {
      throw ArgumentError.value(
        remoteRecordId,
        'remoteRecordId',
        'must not be empty',
      );
    }
    return WalletMutationReconciledOwnership._(remoteRecordId);
  }

  const WalletMutationReconciledOwnership._(this.remoteRecordId);

  final String remoteRecordId;
}

// M5.22 WP-B: `WalletMutationPort` and `ProductionDisabledWalletMutationPort`
// were removed here. They had no production consumer — the live create path is
// walletRepositoryProvider -> WalletRepository -> HttpWalletApiDataSource, live
// since M5.20 — and their presence implied Wallet writes were still disabled
// when they are not. The result types below remain in use.
