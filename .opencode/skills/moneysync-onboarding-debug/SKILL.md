---
name: moneysync-onboarding-debug
description: |-
  Debugging patterns for MoneySync onboarding persistence, Riverpod state
  transitions, GoRouter redirect chains, and Flutter logcat tracing. Covers
  the button-to-state-to-redirect pipeline and common failure modes.
version: 1.0.0
source: M3.3 onboarding persistence debugging session
analyzed_commits: 8
---

# MoneySync Onboarding Debug Skill

## The Redirect Chain

When the user completes onboarding, the following chain must fire for the
app to navigate from `/onboarding` to `/`:

```
_ForwardButton.onPressed
  → OnboardingNotifier.complete()
    → OnboardingState.nextStep()  ← MUST return a NEW state object
      → Riverpod detects state change
        → ref.listen(onboardingStateProvider) fires in appRouterProvider
          → _onboardingCompletionNotifier.value = true
            → GoRouter.refreshListenable fires
              → redirect re-evaluates
                → _routeGuard returns AppRoute.home.path
                  → navigation to /
```

**Every link must work. If any link breaks, the user is stuck on onboarding.**

## Root Cause Pattern: Riverpod State Identity

Riverpod `Notifier` only emits state changes when `state = newObject`. If
`state = sameObject`, no listeners fire and the redirect chain goes silent.

```dart
// BROKEN — returns same object, Riverpod sees no change
OnboardingState nextStep() {
  if (currentIndex >= steps.length - 1) {
    return this;  // ← Same object, no state change!
  }
  ...
}

// FIXED — returns a NEW object with isComplete=true
OnboardingState nextStep() {
  if (currentIndex >= steps.length - 1) {
    return OnboardingState(
      currentStep: currentStep,
      disclosureRevision: disclosureRevision,
      isComplete: true,  // ← New object, state change detected
    );
  }
  ...
}
```

## Debugging with Logcat

### Add console output to Logger using print handler

By default MoneySync's logging framework writes to files, not logcat.
To see logs via `adb logcat -s flutter`, add a console handler:

```dart
// In _initActivityEventWriter()
Logger.root.onRecord.listen((record) {
  print('[${record.loggerName}] ${record.message}');
});
```

### Trace the onboarding flow

```bash
# Clear log buffer, launch app, capture
adb logcat -c
adb shell am start -n me.namila.money_sync.playmanual/me.namila.money_sync.MainActivity
sleep 10
adb logcat -d -s flutter | grep '\[onboard\]\|\[startup\]'

# Expected first launch output:
# [startup] Onboarding load: null → onboardingRequired
# [onboarding] No persisted onboarding state found

# Expected second launch output:
# [startup] Onboarding load: found (complete=true) → ready
```

### Identify which step is failing

```bash
adb logcat -d -s flutter | grep "\[onboard\]"
# Key log messages to watch for:
# "Onboarding complete() called"     → button reached complete()
# "Advanced to complete state"       → nextStep() produced new state
# "Onboarding persisted to Drift"    → write succeeded
# "Already complete — skipping"      → double-tap guard fired
# "No persisted onboarding state"    → Drift read returned null
```

## Common Failure Points

### 1. Button callback never fires
**Symptom**: No "complete() called" log. Page stays on disclosure.
**Cause**: `_ForwardButton` uses stale widget property instead of reading
current state from provider.
**Fix**: Read `ref.read(onboardingStateProvider)` in `onPressed` callback.

### 2. State change doesn't trigger listeners
**Symptom**: "Advanced to complete state" appears but "complete() called"
repeats infinitely.
**Cause**: `nextStep()` returns `this` — Riverpod sees no state change.
**Fix**: Return a new `OnboardingState(isComplete: true)` object.

### 3. Database never opens
**Symptom**: "Onboarding persisted to Drift" never appears.
**Cause**: `bootstrap.dart` bypasses `BootstrapGate` — `appDatabaseProvider`
never watched, SQLCipher never opens.
**Fix**: Render `BootstrapGate` as root widget in `bootstrap.dart`.

### 4. GoRouter redirect silent
**Symptom**: State changes but page stays on onboarding.
**Cause**: `_onboardingCompletionNotifier` never updated because
`ref.listen` never fired (see #2).
**Fix**: Fix the Riverpod state identity issue.

### 5. Widget `state` property stale
**Symptom**: Button shows "Next" on disclosure step instead of "Accept & finish".
**Cause**: Widget receives `state` from parent rebuild but the property is
captured at widget creation time.
**Fix**: Read `ref.read(onboardingStateProvider)` inside `onPressed` instead
of using `state.isLastStep` widget property.

## Startup Guard Chain Verification

```bash
adb logcat -d -s flutter | grep "\[startup\]"
# Expected output on first launch:
# [startup] Health check and onboarding repo ready
# [startup] Database health check: ready
# [startup] Onboarding load: null
# [startup] Startup result: onboardingRequired

# Expected output on second launch:
# [startup] Onboarding load: found (complete=true)
# [startup] Startup result: ready
```

## File Map

```
lib/features/onboarding/
  domain/onboarding_state.dart          — nextStep() → new OnboardingState(isComplete: true)
  presentation/onboarding_controller.dart — complete(), advanceToNextStep(), _loadFromDrift()
  presentation/onboarding_page.dart     — _ForwardButton, OnboardingPage.build()
  data/drift_onboarding_repository.dart — DriftOnboardingRepository.complete() / load()
lib/app/router.dart                     — _onboardingCompletionNotifier, refreshListenable, _routeGuard
lib/bootstrap/
  bootstrap.dart                        — Must render BootstrapGate, not MoneySyncApp directly
  foreground_composition.dart           — _AwaitingStartup, _initActivityEventWriter, console handler
```

## Test Reference

```bash
# Run onboarding persistence integration tests
flutter test test/features/onboarding/onboarding_persistence_test.dart
```
