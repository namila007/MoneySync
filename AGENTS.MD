# Money Sync Application Agent Guide

## Scope and authority

This file applies to all work under `money_sync/`. The application is Android-first and handles sensitive financial SMS from Sri Lankan banks. Treat privacy, exact financial behavior, idempotency, and recoverability as correctness requirements.

Read these sources in the separate [MoneySync guides repository](https://github.com/namila007/moneysync-guides) before implementation:

1. `plan/README.md` and the relevant product/architecture plan.
2. `milestone/README.md` and the milestone currently being implemented.
3. `milestone/quality-gates.md`, `milestone/traceability.md`, and `milestone/configuration-matrix.md`.

The plan owns product and architecture decisions. The milestone pack owns implementation order and exit evidence. This directory owns application code. Do not create another Flutter project or duplicate those documents here.

The generated sample has been reshaped into the M0 architecture shell. Do not enable a capability or mark a milestone passed until its tests and recorded exit evidence succeed.

## Required workflow

Before implementing any change:

1. **Read the plan.** Open the relevant `plan/` document in the guides repository for product, architecture, security, or API guidance. The plan owns product and architecture decisions.
2. **Read the milestone.** Open the current milestone spec, quality gates, traceability matrix, and configuration matrix in `milestone/`. Understand the exit criteria before coding.

For every code change:

3. **Inspect and plan.** Inspect the current state and preserve unrelated user changes. Use Serena for symbol-level navigation and Context7 for current API documentation.
4. **Implement with tests.** Follow test-driven development: write a failing behavioral test, implement the smallest passing change, refactor. Unit-test domain/value objects/use cases with fakes. Widget-test rendering, navigation, and provider overrides. Integration-test Drift, platform bridges, and lifecycle boundaries.
5. **Verify.** Run the full verification suite from `money_sync/`:
   ```sh
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test --coverage --branch-coverage
   flutter build apk --debug
   ```
   For both flavors, build and inspect merged manifests. Verify generated code is reproducible.

   **Pre-commit gate (mandatory):** Before EVERY commit, both of these must pass with zero issues:
   ```sh
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   ```
   If either fails, fix the issues before committing. No exceptions. `flutter analyze --fatal-infos --fatal-warnings` is the strictest check — use it when in doubt.

6. **Deploy and test on a device.** Any change to UI, navigation, permissions, platform channels, or lifecycle must be exercised on a real Android device or emulator — a green test suite is not sufficient evidence for these. Follow "Device deployment and testing" below: check `adb`, ask the user to start the emulator if none is attached, install the flavor with its matching Dart entrypoint, then exercise the changed flow and capture evidence.
7. **Review.** Request a Flutter/Dart/Kotlin review via the appropriate skill or subagent. Add a security review for permissions, SMS, storage, authentication, cryptography, network, imports, exports, or Wallet mutations. Address critical and high findings.
8. **Add a worklog.** Write a dated entry in the guides `worklog/` directory describing what was done, what evidence was produced, what tests were added, what gates remain, and what milestone rows are affected. Reference the milestone, plan sections, and app commits. Do not pre-claim results — record only after tests pass and builds succeed.

Do not commit, push, upload, publish, change credentials, or call a production Wallet mutation unless the user explicitly authorizes that external action.

When live Wallet API calls are authorized for development or end-to-end device testing, use the designated `TEST_ACCOUNT` wallet exclusively. Never read, write, or otherwise touch any other Wallet account during dev/E2E verification.

## Architecture rules

Use the feature-first Clean Architecture described in `plan/02-solution-architecture.md` in the guides repository:

```text
lib/
  app/                 # App, router, theme
  bootstrap/           # Foreground and background composition roots
  core/                # Cross-cutting primitives and bounded adapters
  features/<feature>/
    presentation/      # Widgets, routes, Riverpod UI state/controllers
    domain/            # Entities, value objects, ports, use cases
    data/               # DTOs, services, repository implementations
```

- Dependency direction is `presentation -> domain <- data`; bootstrap wires implementations to ports.
- Domain and application policy must remain pure Dart. They must not import Flutter widgets, Riverpod, Dio, Drift, Pigeon, Android, or ML Kit.
- Widgets render immutable state and forward user intent. They do not construct Wallet JSON, query Drift, parse SMS, or decide automation eligibility.
- Repositories are the single source of truth for their boundary. Domain declares ports; data implements them.
- Kotlin owns Android-only concerns: SMS provider reads, the broadcast receiver, encrypted native spool, WorkManager, device authentication, ML Kit, and scoped document access.
- Kotlin must never open the Drift database. Flutter/Dart must never update, delete, archive, or mark read an Android SMS-provider row.
- Foreground and headless background execution use separate composition roots with the same domain rules.
- Prefer immutable value objects, sealed states, exhaustive switches, constructor injection, `const` widgets, and scoped Riverpod rebuilds. Avoid `!`, mutable shared state, service locators inside domain code, and hidden global configuration.
- Keep functions focused and files cohesive. Extract widgets as classes, not widget-returning helper methods.

## Financial and synchronization invariants

- Never use `double` for money or exchange rates. Use integer minor units or an exact decimal/rational value with explicit currency, scale, and rounding.
- Preserve direction separately from transaction kind and lifecycle.
- Canonical SMS identity is a transport-independent keyed HMAC. Android provider row IDs are aliases, not deduplication keys.
- Mapping requires sender plus parser/message family plus masked instrument evidence. Sender-only routing is unsafe.
- A Wallet create needs a validated candidate, stable lineage, immutable payload, and reconciliation path.
- Never install a generic retry for Wallet mutations. A possibly transmitted operation with no conclusive response enters an unknown state and is reconciled before any retry.
- PATCH and DELETE require a confirmed app-owned Wallet record link. Similar notes or markers are evidence, not ownership.
- Authorization, reversal, refund, transfer, and foreign-currency cases remain review-only unless a later milestone explicitly changes the policy. An approved authorization may create one `uncleared` record immediately; settlement creates no duplicate; reversal is a separate linked positive transaction.
- Imported or newly trained local model snapshots are candidate-only until compatibility, regression, calibration, and pinned-safety evaluation pass and the user explicitly activates them.

## Privacy and security

- `plan/sms.txt` in the private guides workspace is private source material. Never copy it into this application, tests, fixtures, snapshots, logs, screenshots, prompts, CI artifacts, or generated model data. Use redacted or synthetic examples only.
- Raw SMS, labels, extracted entities, model features/weights, Wallet tokens, and account mappings are sensitive. Keep them on-device except for the minimum user-approved structured Wallet payload or explicit encrypted export.
- Logs and activity events use an allowlist of sanitized metadata. Never log bodies, tokens, complete account/card suffixes, full merchant strings, request payloads, database keys, passphrases, or biometric data.
- Store Wallet tokens only through Android Keystore-backed secure storage. Do not place secrets in Drift, preferences, source, fixtures, build arguments, or screenshots.
- Keep Android cleartext traffic disabled. Use one audited Dio configuration and explicit timeouts.
- SMS access is read-only. Do not request `SEND_SMS`, `WRITE_SMS`, broad storage, contacts, call-log, location, or unrelated permissions.
- `playManual` must contain no SMS permission or receiver. Add `READ_SMS` or `RECEIVE_SMS` only to the gated `privateFull` source set in its owning milestone.
- Use Android Create Document/Open Document flows for exports/imports; do not request broad storage permission or retain passphrases/plaintext temporary files.
- No personal data may be used until the encrypted database, backup exclusion, secure storage, retention, and deletion gates pass.

## Activity log vs application log

The `activity_events` table (shown on the Activity tab) is the **user's personal record** of what MoneySync did on their behalf. It answers: "What actions did this app take with my data or accounts?" Examples: wallet connected or refreshed, a transaction was reviewed and then queued or created in the Wallet or failed, a message was imported or rejected back to inbox, a mapping rule was created, the user's stored data was removed.

This is **not** a developer log. Database health checks ("ready code=null"), schema migrations, PRAGMA statements, schema version bumps, and startup diagnostics must never appear in the activity table — they belong in the `Logger` output or on-disk log files in `code_cache/logs/`.

Activity events are written **explicitly and deliberately** only at the moment the user-facing action actually occurs, via `AppDatabase.insertActivity(...)`. They are never scraped or copied from Logger records. M5.22 removed an `ActivityEventWriter` that listened to `Logger.root` and copied allowlisted log lines into the table — that design caused health checks and startup noise to dominate the user's view of their own activity.

Entries must be **truthful about timing and outcome**. Record what has actually happened at that instant, not what is expected to happen. For example: log `walletRecordQueued` when the outbox entry is created; log `walletRecordCreated` only after the API has confirmed a successful create; log `walletRecordFailed` if the create was rejected or timed out. M5.22 fixed a case where "Save for Later" logged "Wallet record created" before any transmission occurred, causing users to see both "created" and "not created" entries for the same record, and failed creates to claim creation as well.

Redaction uses two independent guards — do not confuse them:
- `ActivityRedaction` (`core/privacy/redaction.dart`): guards the `activity_events` table strictly — throws on any violation and maintains a tightly scoped allowlist of sanitized metadata.
- `LogRedactionPolicy` (`core/privacy/log_redaction_policy.dart`): governs only the on-disk log files and masks sensitive spans rather than dropping entire records.

When adding a user-facing capability, first ask: would the user want to see this action in their own history? If yes, define an `ActivityEventCode` and write it explicitly when the action completes; if it is only useful to a developer or operator, route it to the logger instead.

## Testing rules

- Coverage is informational for M0 placeholder/framework boilerplate; do not add tests solely to increase that metric. From M1, minimum substantive authored-code coverage is 80% line and branch. Parser, identity, redaction, state machine, outbox/reconciliation, ownership, policy, cryptography/envelope validation, and model-bundle validation target at least 90% line and branch.
- Flutter 3.44.6 (Dart 3.12.2, `package:coverage` 1.15.1) accepts `--branch-coverage` and the Dart VM returns branch data, but the lcov formatter emits only `BRDA` records (per-line hit/miss) — the `BRF`/`BRH` summary totals are not written. Branch coverage IS collected at the BRDA level (verified: 3641 BRDA records across 142 source files on a full test run), but standard lcov consumers (e.g. `genhtml`) that rely on BRF/BRH will report zero branch coverage. To measure a branch-coverage percentage, parse BRDA records directly. The `--branch-coverage` flag should remain in the test command so the data is present when tooling catches up. Report unavailable coverage dimensions honestly on older toolchains.
- Unit-test domain/value objects/use cases with fakes. Widget-test rendering, navigation, accessibility, loading/error/locked states, and provider overrides. Integration-test Drift, platform bridges, manifests, storage, network contracts, and lifecycle boundaries. Exercise critical journeys end to end on Pixel 7/Android 16.
- Tests must prove negative behavior: no source-SMS mutation, no duplicate create, no blind retry, no unsafe permission, no secret/log leakage, and fail-closed behavior after cancellation, crash, restart, timeout, or corrupt input.
- Never weaken a correct test to make an implementation pass. Fix the implementation unless the requirement or test is demonstrably wrong, then update the authoritative plan and test together.

Run from `money_sync/` as applicable.

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage --branch-coverage
flutter build apk --debug
```

When flavors exist, also build and inspect both merged manifests. Run code generation only after the relevant source definitions and dependencies exist, then verify generated output is reproducible. Do not hand-edit `.g.dart`, `.freezed.dart`, generated Pigeon bindings, `pubspec.lock`, Flutter metadata, `.dart_tool/`, `build/`, or Gradle caches to simulate a dependency or toolchain change; update them only through their owning tool.

## Change boundaries

- Preserve the existing `money_sync/` scaffold and make intentional, reviewable changes. Do not regenerate it.
- Replace the placeholder `com.example.money_sync` application ID and debug signing only through the explicit M0/release work; never invent production identifiers or credentials.
- The generated `ios/` folder may remain, but this product plan supports Android only. Do not add iOS feature implementations unless the product scope changes.
- Add packages incrementally, resolve current versions with Context7 and official package documentation, and keep analysis/tests/build green after each group.
- Source models, Drift schemas, Pigeon definitions, and configuration declarations are reviewed inputs. Generated files are outputs.
- Update the relevant existing plan or milestone when implementation evidence changes a decision. Do not create a new top-level planning file when an existing owner exists.

## Data storage architecture

All configuration and app-owned data is stored in an encrypted SQLCipher database opened by Drift. Key material is wrapped with Android Keystore AES-256-GCM and stored as a blob in the no-backup directory.

| Data | Storage | Backed up? |
|------|---------|-----------|
| Wallet bearer token | Keystore-wrapped blob in `no_backup/money_sync/database/wallet_token.blob` | No (no-backup directory + allowBackup=false) |
| DB encryption key | Keystore-AES-GCM-wrapped blob in `no_backup/money_sync/database/db_key_wrapped.blob` | No |
| HMAC key | Keystore-AES-GCM-wrapped blob in `no_backup/money_sync/database/hmac_key_wrapped.blob` | No |
| App configuration | Drift `app_settings` table (singleton row), `app_lock_state` table, `database_metadata` key-value store — all inside encrypted SQLCipher DB | No (DB file is in no-backup directory) |
| Wallet cache | Drift `wallet_account_cache`, `wallet_category_cache` tables — inside encrypted SQLCipher DB | No |
| Schema version/metadata | Drift `schema_metadata` table — inside encrypted SQLCipher DB | No |

### Startup flow

```
Cold open → BootstrapGate → appDatabaseProvider (init Keystore, open SQLCipher)
  → DatabaseHealthRepository.check()
  → OnboardingRepository.load() from Drift
  → Redirect: recovery → onboarding → lock → requested route
```

### Lock flow

```
App requires lock → router guard captures intended route via _intendedRouteNotifier
  → redirect to /lock → user authenticates via biometric/device credential
  → lock state → unlocked → router guard reads _intendedRouteNotifier
  → redirect to intended route (or home if null)
```

## Available skills

Skills live in `.opencode/skills/` and are symlinked into `.claude/skills/` for Claude CLI access.

- [moneysync-logger](.opencode/skills/moneysync-logger/SKILL.md) — logging framework usage: levels, logger naming, redaction rules, insertion points for debug/info/error logs across bootstrap, onboarding, lock, and networking flows. Load via `/skill moneysync-logger`.
- [moneysync-onboarding-debug](.opencode/skills/moneysync-onboarding-debug/SKILL.md) — debugging patterns for onboarding persistence, Riverpod state transitions, GoRouter redirect chains, and Flutter logcat tracing. Covers the button→state→redirect pipeline. Load via `/skill moneysync-onboarding-debug`.
- [moneysync-adb-debug](.opencode/skills/moneysync-adb-debug/SKILL.md) — Android emulator workflow: checking adb devices, installing privateFull/playManual flavors, driving the UI with uiautomator, seeding SMS via the console, reading app logs, and capturing device evidence. Load via `/skill moneysync-adb-debug`.
- [moneysync-e2e](.opencode/skills/moneysync-e2e/SKILL.md) — end-to-end device testing flows via ADB: Save for Later, Create Now, negative validation, home dashboard verification, activity log checks. Scripts in `money_sync/e2e/`. Load via `/skill moneysync-e2e`.

## Relevant rules (ECC)

Always-loaded standards live in `~/.config/opencode/rules/`. Read the pack before coding in the matching layer — they supplement (never override) the plan and milestone packs in the guides repository:

- `common/` — coding style (immutability, readability), testing (min 80% coverage), security, git workflow, code review, performance.
- `dart/` — Dart/Flutter style, patterns, security, and testing for `lib/` and `test/`.
- `kotlin/` — Android Kotlin style, patterns, security, and testing for `android/` source sets.
- `python/` — Python style and pytest for `tool/` scripts.

## Device deployment and testing

A passing `flutter test` run does not prove UI, navigation, permission, platform-channel, or
lifecycle behaviour. Those must be exercised on a device. Follow this order every time.

### 1. Check that a device is attached — before building anything

```bash
adb devices
```

Proceed only when a line reports state `device`:

```text
List of devices attached
emulator-5554   device
```

**If the list is empty, or the only entries report `offline`, `unauthorized`, or `bootloader`,
stop and ask the user to start the emulator from Android Studio** (Device Manager → ▶ on an AVD)
or to plug in and unlock a physical device with USB debugging authorised. Do not try to start an
emulator yourself, do not run `emulator -avd`, and do not silently skip device verification and
report the change as complete. Wait for the user, then re-run `adb devices`.

### 2. Install the flavor with its matching Dart entrypoint

The Gradle flavor and the Dart `AppConfig` are selected independently. `--flavor privateFull`
alone builds the privateFull Android flavor but defaults to `lib/main.dart`, which hardcodes
`AppConfig.playManual()` — producing a binary with privateFull native behaviour and playManual
capability gating. Always pass `--target`:

```bash
# privateFull — READ_SMS manifest, runtime SMS delegate
flutter build apk --debug --flavor privateFull --target lib/main_private_full.dart
adb install -r build/app/outputs/flutter-apk/app-privatefull-debug.apk

# playManual — no SMS permission, unavailable-in-build delegate
flutter build apk --debug --flavor playManual --target lib/main_play_manual.dart
adb install -r build/app/outputs/flutter-apk/app-playmanual-debug.apk
```

Confirm the running build agrees with the intended flavor — Settings shows
"Build configuration: Private full" or "Play manual".

### 3. Exercise the changed flow and capture evidence

```bash
adb logcat -c
adb shell am start -n me.namila.money_sync.privatefull/me.namila.money_sync.MainActivity
adb shell input tap <x> <y>            # device pixels; check `adb shell wm size`
adb exec-out screencap -p > shot.png
adb logcat -d | grep -iE "E/flutter|RenderFlex|Exception"
```

Useful state checks that do not depend on the UI:

```bash
adb shell dumpsys package <applicationId> | grep -A4 "runtime permissions"   # permission grants
adb shell dumpsys window | grep mCurrentFocus                                 # system dialog on top
adb shell pm clear <applicationId>                                            # fresh-install state
adb shell pm revoke <applicationId> android.permission.READ_SMS               # re-test the request path
```

For a clean permission or onboarding test, `pm clear` and `pm revoke` first — otherwise a
previously granted permission hides the very path being verified.

`FLAG_SECURE` blanks `adb exec-out screencap` to solid black. If screenshots are black, the
secure window is active, not the app. Verify through `dumpsys`, `logcat`, and
`uiautomator dump` instead, or ask the user before changing the secure-window behaviour.

Record what was actually observed on the device in the worklog. Never claim device verification
that was not run.

## Reading device logs

After deploying and running the app:

```bash
# List log files
adb exec-out run-as me.namila.money_sync.playmanual sh -c "find code_cache/logs -type f"

# Read app info log
adb exec-out run-as me.namila.money_sync.playmanual sh -c "cat code_cache/logs/app/info.log"

# Read app error log
adb exec-out run-as me.namila.money_sync.playmanual sh -c "cat code_cache/logs/app/error.log"

# Read debug log (only if ENABLE_DEBUG_LOG=true)
adb exec-out run-as me.namila.money_sync.playmanual sh -c "cat code_cache/logs/debug/debug.log"

# Stream live Flutter logcat (includes print() and engine messages)
adb logcat -s flutter
```

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

## serena — Durable Project Memory

This project uses **Serena** (`mcp__serena__*` MCP tools) for stable, non-obvious project knowledge that persists across sessions.

### For Agents (REQUIRED — Read First)

**Before starting any coding task:**

1. Call `mcp__serena__read_memory` with `memory_name: core`
2. From `mem:core`, follow references to other memories as needed:
   - `mem:tech_stack` — frameworks, build tools, language versions
   - `mem:conventions` — code style, domain purity, patterns
   - `mem:suggested_commands` — dev/test/deploy commands
   - `mem:task_completion` — pre-commit verification steps

These memories replace redundant rediscovery and document project invariants (financial exactness, privacy, Android boundaries, Riverpod patterns, etc.).

### Updating Memories (IMPORTANT — Once Per Discovery Cycle)

When you discover **stable, non-obvious** project conventions not yet documented:

1. Check if the discovery belongs in `mem:core`, `mem:conventions`, `mem:tech_stack`, `mem:suggested_commands`, or `mem:task_completion`
2. Call `mcp__serena__read_memory` with that memory name
3. Call `mcp__serena__write_memory` with the updated content
4. **Do not** add quick-read facts, generic framework knowledge, one-off task notes, or volatile line-level details

Examples of what to add:
- ✅ "Never use `double` for money; use integer minor units" (financial invariant)
- ✅ "Domain code must be pure Dart; no Pigeon/Drift/Flutter imports" (architecture rule)
- ✅ "Wallet operations review-only until M3; no blind retry" (product policy)
- ✅ "Use `final log = Logger('feature.domain.service')` naming pattern" (logging convention)

Examples of what NOT to add:
- ❌ "MainActivity.kt is at android/app/src/..." (read file when needed)
- ❌ "Riverpod is a state management library" (generic framework knowledge)
- ❌ "Run tests before commit" (task-local, goes in task comment)
- ❌ "Line 42 in FeatureController has a bug" (volatile, use commits/issues)

### Verification

After modifying memories, run from `money_sync/`:
```bash
serena memories check
```

This validates all `mem:` references and reports stale entries.

