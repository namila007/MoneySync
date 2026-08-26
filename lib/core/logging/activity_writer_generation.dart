/// Fences activity-event writes against a concurrent clear-activity
/// action. Distinct from the global privacy epoch — clearing the activity
/// log must not invalidate other epoch-gated writes across the app, so it
/// advances this counter instead of [AppDatabase.advancePrivacyEpoch].
final class ActivityWriterGeneration {
  int _current = 0;

  int get current => _current;

  void advance() => _current++;
}
