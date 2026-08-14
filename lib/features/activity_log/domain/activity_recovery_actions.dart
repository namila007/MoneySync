/// Recovery actions the Activity page can dispatch (M5.12). The activity_log
/// feature is a pure display-and-dispatch layer: it never owns mutation logic
/// itself, it only triggers the same use cases the review screen and worker
/// already expose.
abstract interface class ActivityRecoveryActions {
  /// Retry the scheduled outbox mutation for [mutationId] now.
  Future<void> retryNow(String mutationId);

  /// Mark the mutation as needing user verification in the Wallet app.
  Future<void> verifyInWallet(String mutationId);
}

/// No-op fallback used when the outbox is not wired (tests / M5 fake posture).
final class NoopActivityRecoveryActions implements ActivityRecoveryActions {
  const NoopActivityRecoveryActions();

  @override
  Future<void> retryNow(String mutationId) async {}

  @override
  Future<void> verifyInWallet(String mutationId) async {}
}
