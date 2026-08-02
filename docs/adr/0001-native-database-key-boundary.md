# ADR 0001: Native database-key and HMAC-key boundary

Status: accepted
Date: 2026-08-02
Milestone: M3.7 Work Package 1

## Context

The SQLCipher content key protecting the local Drift database, and the HMAC
key used for source-identity digests, are both wrapped with an
AndroidKeyStore AES-GCM key and stored as blobs in the app's no-backup
directory. Before this change:

- `NativeSecurityChannel.acquireContentKeyHex()` unwrapped the content key in
  Kotlin, hex-encoded it, and returned it to Dart as a `String`.
  `ProductionEncryptedDatabaseOpener.open()` then interpolated that hex
  string directly into `PRAGMA key = "x'$keyHex'";`.
- The HMAC key was unwrapped in Kotlin into a plain `ByteArray` and used with
  a generic `SecretKeySpec` + `Mac.getInstance("HmacSHA256")` — not a
  dedicated non-exportable AndroidKeyStore HMAC operation — and it signed an
  arbitrary Dart-supplied `canonicalInput: String`.

M3.7 requires closing this stop-gate: the raw key must not cross the
Dart/native boundary as a `String`, hex string, or (per the strictest reading)
byte array at all, and HMAC signing must use a non-exportable Keystore key
over a typed, bounded input.

## Constraints

Two existing, non-negotiable constraints bound the solution space:

1. **`AGENTS.md`: "Kotlin must never open the Drift database."** This rules
   out a native `QueryExecutor`/database service where Kotlin owns the
   physical SQLite/SQLCipher file handle and Dart's Drift schema forwards SQL
   statements to it over Pigeon. That design would require Kotlin to open the
   database file — exactly what the rule forbids.
2. **The project's `sqlite3` package (sourced via the `sqlcipher` build hook)
   only exposes keying through `PRAGMA key` executed from Dart.** There is no
   raw-bytes keying API (no `sqlite3_key()` binding) and no supported way to
   hand a natively-opened, already-keyed SQLite connection to Drift's FFI
   executor. Confirmed via Drift's own encryption guide
   (https://drift.simonbinder.eu/platforms/encryption), which shows the
   canonical pattern as `rawDb.execute("PRAGMA key = '...'")` inside the
   `setup` callback of `NativeDatabase`/`NativeDatabase.createInBackground` —
   there is no pre-keyed-connection constructor.
3. Drift's `NativeDatabase(file, setup: ...)` opens the connection **lazily**,
   on first query — not synchronously at construction. Any key material
   captured by the `setup` closure necessarily outlives the function call
   that constructs the `NativeDatabase`.

Given (1) and (2), a design with **zero** Dart-side representation of the raw
key, ever, is not achievable while keeping Drift as the query layer and
respecting the "Kotlin never opens Drift" rule. The only way to reach true
zero-crossing would be to bypass Flutter's platform-channel model entirely
with a hand-rolled JNI-via-`dart:ffi` client that calls Android Keystore
`Cipher`/`KeyStore` APIs directly from native code invoked by Dart FFI,
without ever going through `MethodChannel` (which always materializes a Dart
object when a channel call returns). This was considered and rejected: it
introduces a large, fragile, security-sensitive native binding surface
(hand-written JNI lifecycle, thread attachment, error handling) that
duplicates what Flutter's platform channels already do, for a marginal
reduction in the already-small residual exposure window described below.

## Decision

Adopt a **minimized-exposure boundary**, not an absolute zero-crossing
boundary:

1. Kotlin returns the raw content key **only as `ByteArray`** — never
   hex-encoded, never printable text — via `acquireContentKeyBytes()`. The
   old `acquireContentKeyHex()` method is removed entirely.
2. On the Dart side, `DatabaseKeyHandle` wraps the `Uint8List` and exposes it
   **exactly once** through `useAndDispose<T>(T Function(Uint8List) action)`,
   which zeroizes the buffer in a `finally` block immediately after the
   callback returns and throws `StateError` on any second use. There is no
   `.id`/`.hex`/`String`-typed accessor.
3. `ProductionEncryptedDatabaseOpener.open()` calls `useAndDispose` exactly
   once, at the single call site that builds the `PRAGMA key` statement. The
   transient hex string it produces is captured by the `NativeDatabase`
   `setup` closure — the same lifetime the previous implementation already
   had (this is an unavoidable consequence of Drift's lazy `setup`
   invocation, not a regression). What changed is that the **raw bytes**
   (as opposed to the hex string) are zeroized immediately rather than left
   for the garbage collector, and the raw bytes never cross the platform
   channel as printable text.
4. The HMAC key moves to a dedicated, non-exportable
   `KeyProperties.KEY_ALGORITHM_HMAC_SHA256` AndroidKeyStore alias
   (`money_sync_source_identity_hmac_v2`). `Mac` is initialized directly from
   the Keystore-held `SecretKey` (`keyStore.getKey(alias, null)`); the key
   material never leaves the Keystore as an app-owned `ByteArray`. A one-time
   migration imports any pre-existing legacy wrapped key's raw bytes into the
   Keystore via `KeyStore.setEntry(alias, SecretKeyEntry(...), KeyProtection)`
   (preserving source-identity continuity), zeroizes the temporary buffer,
   and deletes the legacy file.
5. `deriveSourceIdentityDigest` now accepts a typed, bounded
   `SourceIdentityCanonicalizationRequest` (explicit `senderAddress`,
   `messageFamily`, `maskedInstrumentEvidence`, `occurredAtEpochSeconds`
   fields, each length/charset-validated in Dart and re-validated in Kotlin)
   instead of an arbitrary `canonicalInput: String`. The canonical byte
   encoding is built natively from the validated fields — the caller cannot
   supply a pre-built string to sign.

## Rejected alternatives

- **Native `QueryExecutor`/database service** (Kotlin opens and keys the
  physical SQLite file; Drift's Dart-side executor forwards SQL over Pigeon):
  rejected because it requires Kotlin to open the Drift database, directly
  contradicting `AGENTS.md`. It would also be a much larger rewrite of the
  entire database access layer than this milestone's security-boundary scope
  justifies.
- **Per-field AEAD encryption fallback** (documented in
  `plan/07-security-privacy-and-logging.md` as a fallback for when
  whole-database SQLCipher is "not maintainable"): does not apply here —
  SQLCipher works correctly today; the gap is only in how the key crosses the
  boundary, not whether SQLCipher itself is viable. Adopting this fallback
  would touch nearly every table/model and violate M3.7's explicit
  requirement to preserve the Drift schema v4 and its append-only migrations.
- **`NativeDatabase.createInBackground`** (moves the eventual `setup`
  execution, and the key material it captures, to a separate background
  isolate rather than the main UI isolate): a genuine, Drift-endorsed
  improvement that shrinks exposure further by isolating key material from
  the rest of the application's object graph. Not adopted in this milestone
  because it changes the app's database execution model (every query moves
  to a background isolate with message-passing overhead), which is a larger,
  separately-reviewable architectural change than this security-boundary fix
  calls for. Recorded here as a candidate follow-up.

## Consequences

- The raw key still exists, briefly, as a Dart `Uint8List` (zeroized
  immediately) and, unavoidably given Drift's lazy `setup` invocation, as a
  transient hex `String` captured by the `NativeDatabase` setup closure until
  first query. This is a smaller, more disciplined exposure window than
  before (bytes never printable-text-encoded except at the single point of
  use; explicit zeroization; no persisted handle), but it is not zero.
- HMAC key material for source-identity digests is fully non-exportable after
  migration; no Dart code and no Kotlin code outside `HmacSigner` can ever
  read the raw HMAC key bytes again.
- `deriveSourceIdentityDigest` has no production caller yet (SMS ingestion is
  out of scope through M3.7); the typed request shape may need revisiting
  once `SourceMessageCanonicalizer` (in `lib/features/sms_ingestion/domain/`)
  is wired to a real native-backed `KeyedHmac` implementation in a later
  milestone.
