---
name: moneysync-adb-debug
description: |-
  MoneySync Android emulator workflow: checking adb devices, installing the
  privateFull/playManual flavors with their matching Dart entrypoints, driving
  the UI with uiautomator dumps + input taps, seeding SMS via the emulator
  console, reading app logs (logcat + code_cache/logs), resetting permission
  and onboarding state, and capturing device evidence when screencap returns
  solid black under the secure window.
version: 1.0.0
source: M4.15 device verification session (2026-08-14)
analyzed_commits: 1
---

# MoneySync ADB / Emulator Debug Skill

## Preflight — never build before checking the device

```bash
adb devices            # need a line reporting state "device"
```

If empty / `offline` / `unauthorized`: stop and ask the user to start the
emulator from Android Studio (Device Manager → ▶) or connect a device. Never
start an emulator yourself.

## Install a flavor with its matching Dart entrypoint

The Gradle flavor and the Dart `AppConfig` are chosen independently —
`--flavor` alone silently produces a mismatched build. Always pass `--target`:

```bash
flutter build apk --debug --flavor privateFull --target lib/main_private_full.dart
adb install -r build/app/outputs/flutter-apk/app-privatefull-debug.apk

flutter build apk --debug --flavor playManual --target lib/main_play_manual.dart
adb install -r build/app/outputs/flutter-apk/app-playmanual-debug.apk

adb shell am start -n me.namila.money_sync.privatefull/me.namila.money_sync.MainActivity
# playManual: me.namila.money_sync.playmanual/me.namila.money_sync.MainActivity
```

Confirm the running build agrees with the flavor before trusting observations:
Settings shows "Build configuration: Private full" vs "Play manual".

## Driving the UI (the primary evidence tool)

Screenshots are **solid black** while the secure window is active (FLAG_SECURE,
on by default) — screencap is useless as evidence. `uiautomator` dumps see
through the secure window, so they are the visual evidence:

```bash
adb exec-out uiautomator dump /dev/tty > /tmp/uidump.xml

# readable surface of what is on screen:
grep -oE 'content-desc="[^"]+"' /tmp/uidump.xml | sort -u

# find a tap target by its accessible label:
grep -oE '<node[^>]*content-desc="Scan messages"[^>]*>' /tmp/uidump.xml | grep -oE 'bounds="[^"]*"'
#   → bounds="[42,609][1038,735]"  (x1,y1 x2,y2)

# tap the centre: x = (42+1038)/2 = 540, y = (609+735)/2 = 672
adb shell input tap 540 672
```

Workflow per step: **dump → find bounds → tap → dump again and verify** before
the next tap. Never blind-tap from memory — a tap on the wrong screen silently
takes you somewhere unexpected.

Other input commands:

```bash
adb shell input keyevent 4              # back
adb shell input text "SAMP"             # type into the focused field
adb shell input swipe 540 1800 540 600 500   # scroll (start x y, end x y, ms)
adb shell wm size                       # screen size; convert fractions to px
```

### Discovering buttons that are not in the first dump

Text buttons appear as `content-desc`; dialogs/scrollable content may need a
swipe first, then re-dump. Clickable nodes:

```bash
grep -oE '<node[^>]*clickable="true"[^>]*>' /tmp/uidump.xml \
  | grep -oE '(text|content-desc)="[^"]{0,40}"|bounds="[^"]*"'
```

### Onboarding walkthrough

After `pm clear`, the app boots into onboarding. Tap through by re-dumping each
screen: Welcome → data-on-device → disclosure ("Continue" / "Not now — I'll
paste manually") → Android permission dialog ("Allow" — a system dialog, find
its bounds in the dump) → "Finish". Verify Home shows `Local messages` and the
flavor line before trusting any later observation.

## Seeding SMS for import tests

```bash
adb emu sms send SAMPATHTX "A/C 1234 credited with LKR 5000.00. Bal LKR 9000.00"
adb shell content query --uri content://sms/inbox --projection address,body,date | tail
```

`adb emu sms send <sender> <body>` works on the emulator's own provider; the
sender address must match a **tracked sender** for the history import to read
it. `content query` verifies the message exists before blaming the app.

## Reading logs

### logcat

```bash
adb logcat -c                                # clear first, then reproduce
adb logcat -d | grep -iE "flutter|M415-DIAG|sms.history"
adb logcat -s flutter                        # live stream of Dart print()/debugPrint
```

`debugPrint`/`print` in Dart land in logcat under the `flutter` tag. Temporary
`debugPrint('M-TAG ...')` instrumentation in the failing path is the fastest way
to surface caught exceptions the UI hides — rebuild, reproduce, read, remove.

### App log files (Android 16, `code_cache/logs/`)

```bash
adb exec-out run-as me.namila.money_sync.privatefull sh -c "cat code_cache/logs/app/info.log"
adb exec-out run-as me.namila.money_sync.privatefull sh -c "cat code_cache/logs/app/error.log"
# debug.log only exists when built with --dart-define=ENABLE_DEBUG_LOG=true
```

RollingFileHandler flushes lazily — after a crash/force-stop, restart the app
once before reading error.log, or it may look empty.

## Resetting state

```bash
adb shell pm clear me.namila.money_sync.privatefull        # fresh install state (DB + onboarding)
adb shell pm revoke me.namila.money_sync.privatefull android.permission.READ_SMS
adb shell dumpsys package me.namila.money_sync.privatefull | grep -A4 "runtime permissions"
adb shell dumpsys window | grep mCurrentFocus              # what window has focus (dialogs!)
```

Always `pm clear` / `pm revoke` before testing onboarding or permission paths —
an existing grant hides the path under test.

## Evidence capture recipe

```bash
mkdir -p worklog/evidence/m4.15
adb exec-out uiautomator dump /dev/tty > worklog/evidence/m4.15/03-activity.xml
adb logcat -d > worklog/evidence/m4.15/03-logcat.txt
# screencap is black under FLAG_SECURE — note "black = secure window active" in the worklog
```

Name files `NN-<what>.xml` and reference them from the worklog entry. Record
only what was actually observed.

## Known failure patterns (learned in M4.15)

1. **Stale screens after navigation**: Riverpod `Notifier` state persists across
   navigation — a result view can look "stuck" when it is actually the previous
   run's state. `am force-stop` + relaunch for a clean slate, or tap the reset
   button first.
2. **Lazy FutureProvider race**: code doing `ref.read(x).asData?.value` on a
   provider nobody has watched yet always sees `AsyncLoading` → silent failure.
   `await ref.read(x.future)` instead. Surface this in the UI before deep-diving.
3. **Pigeon channel hangs in widget tests**: `SmsHistoryHostApi()` never
   completes under `flutter test`; pages calling it need an injectable loader
   seam for widget tests (`@visibleForTesting`-style constructor param).
4. **`pumpAndSettle` timeouts**: an indeterminate progress bar or a focused
   TextField's blinking cursor animate forever. Use fixed
   `await tester.pump(Duration(...))` sequences instead.
5. **Drift enum columns store names, not wire values**: raw SQL inserts into
   `textEnum` columns must use `'messageImported'`, not `'sms.message.imported'`.
6. **Column name shadowing**: a Drift column named `count` shadows the generated
   table `count()` method — name it `batchCount` (learned the hard way in M4.15
   WP3).
7. **Multiple `Scrollable`s break `scrollUntilVisible`**: pass an explicit
   `scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable))`.
8. **Material pickers on the small test surface** render fullscreen with no
   CANCEL button — dismiss programmatically (`Navigator.pop`) in tests.
