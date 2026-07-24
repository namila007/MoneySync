import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';

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

abstract interface class WalletMutationPort {
  Future<WalletMutationResult> submit(WalletMutationIntent intent);
}

/// Production composition is intentionally non-operational until M3 contract,
/// credential, fresh-auth, and reconciliation gates have passed.
final class ProductionDisabledWalletMutationPort implements WalletMutationPort {
  const ProductionDisabledWalletMutationPort();

  @override
  Future<WalletMutationResult> submit(WalletMutationIntent intent) async =>
      const WalletMutationDisabled();
}
