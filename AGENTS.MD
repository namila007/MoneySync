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
6. **Review.** Request a Flutter/Dart/Kotlin review via the appropriate skill or subagent. Add a security review for permissions, SMS, storage, authentication, cryptography, network, imports, exports, or Wallet mutations. Address critical and high findings.
7. **Add a worklog.** Write a dated entry in the guides `worklog/` directory describing what was done, what evidence was produced, what tests were added, what gates remain, and what milestone rows are affected. Reference the milestone, plan sections, and app commits. Do not pre-claim results — record only after tests pass and builds succeed.

Do not commit, push, upload, publish, change credentials, or call a production Wallet mutation unless the user explicitly authorizes that external action.

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

## Testing rules

- Coverage is informational for M0 placeholder/framework boilerplate; do not add tests solely to increase that metric. From M1, minimum substantive authored-code coverage is 80% line and branch. Parser, identity, redaction, state machine, outbox/reconciliation, ownership, policy, cryptography/envelope validation, and model-bundle validation target at least 90% line and branch.
- Flutter 3.44.6 supports native branch coverage. Use `flutter test --coverage --branch-coverage`, and report unavailable coverage dimensions honestly on older toolchains.
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

- [moneysync-logger](.opencode/skills/moneysync-logger/SKILL.md) — logging framework usage: levels, logger naming, redaction rules, insertion points for debug/info/error logs. Load via `/skill moneysync-logger`.
- [moneysync-onboarding-debug](.opencode/skills/moneysync-onboarding-debug/SKILL.md) — debugging patterns for onboarding persistence, Riverpod state transitions, GoRouter redirect chains, and Flutter logcat tracing. Load via `/skill moneysync-onboarding-debug`.

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
