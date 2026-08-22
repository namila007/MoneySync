import 'package:money_sync/features/wallet_sync/domain/mutation_intent.dart';
import 'package:money_sync/features/wallet_sync/domain/wallet_mutation_port.dart';

/// Sealed classification of a Wallet create failure, mapped from HTTP per
/// plan/05 §Retry and error classification (M5.6).
sealed class WalletMutationFailureClassification {
  const WalletMutationFailureClassification();
}

/// Local validation / 400 / per-item client error — permanent until edited.
/// No automatic retry; surface a safe field error.
final class PermanentClientFailure extends WalletMutationFailureClassification {
  const PermanentClientFailure({this.safeErrorCode});
  final String? safeErrorCode;
}

/// 401/403 — pause all Wallet work and replace the token.
final class AuthenticationRequired extends WalletMutationFailureClassification {
  const AuthenticationRequired();
}

/// Initial-sync 409 — retryable onboarding state honoring
/// `retry_after_minutes`. Other conflicts are NOT this class.
final class RetryableConflict extends WalletMutationFailureClassification {
  const RetryableConflict({this.retryAfterMinutes});
  final int? retryAfterMinutes;
}

/// 429 — honor `Retry-After` (and live rate headers).
final class RateLimited extends WalletMutationFailureClassification {
  const RateLimited({this.retryAfterSeconds});
  final int? retryAfterSeconds;
}

/// 5xx proven by contract to occur before execution, or DNS/offline before
/// send — retryable with bounded exponential backoff.
final class RetryablePreTransmission
    extends WalletMutationFailureClassification {
  const RetryablePreTransmission();
}

/// Any 5xx, cancellation, timeout, or connection loss after request
/// transmission may have begun, or a malformed success body — reconcile
/// first; never blanket retry.
final class AmbiguousPostTransmission
    extends WalletMutationFailureClassification {
  const AmbiguousPostTransmission();
}

/// Maps a failure classification onto the [WalletMutationPort] result space
/// (plan/05 §Retry; M5.6). [AmbiguousPostTransmission] is the ONLY class that
/// maps to [WalletMutationPostTransmissionAmbiguity]; every other class maps
/// to Client/Server/PreTransmission.
final class WalletMutationFailureMapper {
  const WalletMutationFailureMapper();

  WalletMutationResult toPortResult(
    WalletMutationFailureClassification classification,
  ) => switch (classification) {
    PermanentClientFailure() ||
    AuthenticationRequired() => const WalletMutationClientFailure(),
    RetryableConflict() ||
    RateLimited() ||
    RetryablePreTransmission() => const WalletMutationServerFailure(),
    AmbiguousPostTransmission() =>
      const WalletMutationPostTransmissionAmbiguity(),
  };
}

/// Classifies raw HTTP signal into the sealed taxonomy (pure function).
WalletMutationFailureClassification classifyWalletMutationFailure({
  required int? statusCode,
  String? errorCode,
  int? retryAfterSeconds,
  int? retryAfterMinutes,
  required bool transmissionMayHaveBegun,
}) {
  if (statusCode == 200 || statusCode == 207) {
    // Success is handled by the caller; classify defensively as ambiguous so
    // a malformed success body never auto-retries.
    return const AmbiguousPostTransmission();
  }
  if (statusCode == null) {
    return transmissionMayHaveBegun
        ? const AmbiguousPostTransmission()
        : const RetryablePreTransmission();
  }
  return switch (statusCode) {
    400 => const PermanentClientFailure(),
    401 || 403 => const AuthenticationRequired(),
    409 when errorCode == 'init_sync_in_progress' => RetryableConflict(
      retryAfterMinutes: retryAfterMinutes,
    ),
    429 => RateLimited(retryAfterSeconds: retryAfterSeconds),
    int status when status >= 500 =>
      transmissionMayHaveBegun
          ? const AmbiguousPostTransmission()
          : const RetryablePreTransmission(),
    _ => const PermanentClientFailure(),
  };
}

/// Convenience: `transmissionMayHaveBegun` for a create whose request was
/// handed to the transport. The domain state machine lives on
/// [WalletMutationState] — this only classifies the transport result.
WalletMutationState stateForClassification(
  WalletMutationFailureClassification classification,
) => switch (classification) {
  AmbiguousPostTransmission() => WalletMutationState.unknownDelivery,
  PermanentClientFailure() ||
  AuthenticationRequired() => WalletMutationState.permanentFailure,
  RetryableConflict() ||
  RateLimited() ||
  RetryablePreTransmission() => WalletMutationState.retryScheduled,
};
