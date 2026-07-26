---
name: moneysync-logger
description: |-
  MoneySync logging framework usage: log levels, Logger naming, redaction rules,
  insertion points for debug/info/error logs across bootstrap, onboarding, lock,
  and networking flows. Covers both Dart and Android native layers.
version: 1.0.0
source: M3.4-logging-framework implementation
analyzed_commits: 7
---

# MoneySync Logger Skill

## Log Architecture

```
package:logging  →  Logger(name)  →  RollingFileHandler  →  rotating files on disk
                                       LogRedactionPolicy  →  allowlist filter
                                       ActivityEventWriter  →  Drift ActivityEvents table
```

Three tiers, compile-time gated:

| Tier | Level | File | Production | Guard |
|------|-------|------|------------|-------|
| DEBUG | `Level.FINE` | `$appDocDir/logs/debug/debug.log` | Stripped | `--dart-define=ENABLE_DEBUG_LOG=true` |
| INFO | `Level.INFO` | `$appDocDir/logs/app/info.log` | Always on | None |
| ERROR | `Level.SEVERE` | `$appDocDir/logs/app/error.log` | Always on | None |

INFO and ERROR also dual-write sanitized entries to the encrypted Drift `ActivityEvents` table.

## Logger Naming Convention

Use hierarchical namespaces so log files are greppable by feature:

```dart
Logger('bootstrap')         // startup sequence, database open
Logger('startup')           // StartupNotifier state transitions
Logger('onboarding')        // OnboardingNotifier load/complete
Logger('lock')              // ForegroundLockNotifier auth/lock
Logger('wallet.connection') // Wallet token/catalog/connect
Logger('native.<tag>')      // Android (Timber) → Dart bridge
Logger('app.info')          // reserved: app lifecycle info tier
Logger('app.debug')         // reserved: verbose debug tier
Logger('app.error')         // reserved: root error tier (inherited by all)
```

## Where to Insert Logs

### Always add .info() on:
- Entry/exit of non-trivial async operations (`_loadFromDrift`, `complete`, `initialize`)
- State transitions (startup status, lock state, onboarding step)
- Database health check results
- Token lifecycle events (save, replace, disconnect)

### Always add .error() on:
- `catch` blocks in async operations — include the exception and stack trace
- `rethrow` paths that lose context without the log
- Fresh-auth failures (cancelled, locked out, timeout)
- Any unexpected runtime state that should never occur

### Never log:
- Bearer tokens, API keys, secrets
- Raw SMS/OTP text
- Phone numbers, full instrument suffixes, full merchant names
- HTTP request/response bodies or headers
- Wallet `_value` or key material
- Arbitrary `Map<String, Object?>` data

Redaction is automatic via `LogRedactionPolicy` — but the policy blocks at the
handler boundary, so avoid formatting secrets into strings at the call site.

## How to Add a Logger

```dart
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';

final log = Logger('my.feature');

void doSomething() {
  log.info('Starting doSomething');
  try {
    // ... work ...
    log.info('doSomething completed');
  } catch (e, s) {
    log.error('doSomething failed', e, s);
    rethrow;
  }
}
```

The `LogLevelX` extension (`log_levels.dart`) provides `.debug()`, `.info()`,
`.error()` helpers. `.debug()` maps to `Level.FINE` and is stripped in release.
`.error()` maps to `Level.SEVERE` and accepts an optional error + stack trace.

## LogRedactionPolicy — Allowlist Rules

The policy lets through only these patterns. Everything else is silently dropped:

| Category | Example | Allowed? |
|----------|---------|----------|
| SafeErrorCode | `SafeErrorCode: DB_KEY_INVALID` | ✓ |
| CorrelationId | `CorrelationId: abc-123` | ✓ |
| Bank label | `bank_label: institutionA` | ✓ |
| Instrument tail | `Instrument: **34` | ✓ |
| Amount | `amount_minor: 1500` | ✓ |
| Currency | `currency: LKR` | ✓ |
| State transition | `state_transition: needsReview` | ✓ |
| Event code | `event_code: app.log.info` | ✓ |
| Schema operations | `migration v1->v2`, `PRAGMA` | ✓ |
| Bearer/token/API key | any match | ✗ blocked |
| 4-8 digit bare number | `123456` (OTP) | ✗ blocked |
| Phone number | `077-123-4567` | ✗ blocked |
| Free text | any unmatched string | ✗ blocked |

## Bootstrap Wiring

Logging initializes in `_AwaitingStartupState._initializeLogging()` after the
database opens. The `_initLogging()` function in `foreground_composition.dart`
configures hierarchical logging, creates the three rolling file handlers, and
wires the Drift ActivityEvent dual-writer.

```dart
Future<void> _initLogging(AppConfig config, AppDatabase db) async {
  hierarchicalLoggingEnabled = true;

  final logConfig = LogConfig(
    flavor: config.flavor.name,
    enableDebugLog: const bool.fromEnvironment('ENABLE_DEBUG_LOG'),
    safeLogPolicy: config.logPolicy,
  );

  final dirs = LogDirectoryResolver();
  final redaction = const LogRedactionPolicy();

  // Root logger → ERROR → app/error.log
  Logger.root.level = Level.SEVERE;
  Logger.root.onRecord.listen(RollingFileHandler(/*...*/).handleLogRecord);

  // Logger('app.info') → INFO → app/info.log + Drift ActivityEvents
  // Logger('app.debug') → FINE → debug/debug.log (only with ENABLE_DEBUG_LOG)
}
```

## Testing Logging Code

```dart
// Capture log records in tests
final captured = <LogRecord>[];
final logger = Logger('test.my_feature');
logger.onRecord.listen(captured.add);

// Exercise code that uses logger
doSomething();

expect(captured.any((r) => r.message.contains('expected text')), isTrue);
```

Always use unique `Logger` instances per test group (append `_$counter` or use
unique names to avoid record accumulation from the logger singleton).

## Android Native (Timber)

The `NativeLogBridge` class handles the Dart side. It maps Android `Log` priority
to Dart levels (ERROR/WTF → SEVERE, INFO/DEBUG → INFO, VERBOSE → FINE) and
applies `LogRedactionPolicy` before dispatching.

To wire from Kotlin:
```kotlin
Timber.plant(NativeLogTree(NativeLogHostApi()))
Timber.plant(Timber.DebugTree())
```

The Pigeon channel definition is:
```dart
@HostApi()
abstract class NativeLogHostApi {
  void onNativeLog(int priority, String tag, String message, String? safeErrorCode);
}
```

## Existing Log Insertion Points (M0-M3.x)

| Flow | Logger name | What's logged |
|------|------------|---------------|
| BootstrapGate | `bootstrap` | Database open success/failure |
| StartupNotifier.initialize | `startup` | Health check result, onboarding load state, routing decision |
| OnboardingNotifier._loadFromDrift | `onboarding` | DB availability, persisted state found/null/complete |
| OnboardingNotifier.complete | `onboarding` | Completion call, state advance, Drift persistence |
| ForegroundLockNotifier.unlock | `lock` | Current state, auth outcome, resulting state |
| ForegroundLockNotifier.onAppPaused | `lock` | App background event |
| DioLogInterceptor | `test.dio.*` | Request path/method, response status/size, error type/path |

## File Map

```
lib/core/logging/
  log_config.dart               — LogConfig composition input
  log_levels.dart               — LogLevelX extension (.debug/.info/.error)
  log_directory.dart            — LogDirectoryResolver (path resolution + cleanup)
  rolling_file_handler.dart     — RollingFileHandler (rotation + format + redaction)
  activity_event_writer.dart    — ActivityEventWriter (Drift dual-write)
  native_log_bridge.dart        — NativeLogBridge (Android Timber → Dart)
  dio_log_interceptor.dart      — DioLogInterceptor (safe HTTP logging)
lib/core/privacy/
  log_redaction_policy.dart     — allowlist-based redaction
```

## References

- `plan/07-security-privacy-and-logging.md` — redaction rules, event schema
- `milestone/M3.4-logging-framework.md` — full milestone spec
- `worklog/M3.4-logging-framework.md` — implementation evidence
- `test/core/logging/` — test examples
- `test/core/privacy/log_redaction_policy_test.dart` — redaction test examples
