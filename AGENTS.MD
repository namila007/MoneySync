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

1. Inspect the current state and preserve unrelated user changes.
2. Use Serena for symbol-level code navigation: find the definition first, inspect references before changing a public symbol, then review the resulting diff. Use `rg` for filenames, strings, comments, configuration, and documentation. If Serena is unavailable, state that briefly and use the Dart analyzer plus `rg` as the fallback.
3. Use Context7 for current Flutter, Dart, Android, or package documentation. Resolve the library ID first, then query with the specific implementation question. Do not infer current APIs or versions from the planning documents.
4. Follow test-driven development: write a failing behavioral test, implement the smallest passing change, refactor, and rerun the affected suite.
5. After Dart or Kotlin changes, run the applicable formatter, analyzer, tests, coverage checks, and Android build. Review all changes before handoff.
6. After code changes, request the appropriate Flutter/Dart/Kotlin review and address critical or high findings. Add a security review for permissions, SMS, storage, authentication, cryptography, network, imports, exports, or Wallet mutations.

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
