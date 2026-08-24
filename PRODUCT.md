# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

One adult user managing their own BudgetBakers Wallet account, on one personal Android phone (MVP validation device: Pixel 7, Android 16). The user reviews financial SMS from Sri Lankan banks and wants those transactions reflected in Wallet without re-typing them. No shared accounts, multiple app users, or backend-hosted users in MVP.

## Product Purpose

Money Sync reads financial transaction SMS on-device, turns supported messages into explainable structured candidates (deterministic bank parsers plus optional on-device ML assistance), maps each candidate to the correct Wallet account/category, and safely creates and manages the corresponding app-owned Wallet record — without ever uploading raw SMS or requiring the user to manually transcribe bank messages into Wallet. Success means correct, non-duplicate Wallet records with full user visibility and control over automation.

## Positioning

Unlike a generic SMS-to-spreadsheet exporter or a cloud-based statement importer, Money Sync is local-first and privacy-first: raw SMS, labels, and any learned model data never leave the device — only the minimum approved structured transaction fields are sent to Wallet. It also treats financial correctness as a first-class constraint (exact integer/decimal money handling, idempotent outbox-based sync, reconciliation-before-retry, explicit authorization/settlement/reversal lifecycle) rather than best-effort scraping.

## Operating Context

- Android-only, portrait-first with usable landscape/tablet layouts.
- SMS is read-only: the app queries the Android SMS provider but never updates, marks-read, archives, or deletes a source message.
- Intermittent connectivity and Android background-execution restrictions are normal operating conditions; Wallet sync waits for network, everything else (detection, parsing, mapping, review) works offline.
- Two build flavors: `playManual` (no SMS permission, manual paste/share ingestion only) and `privateFull` (gated `READ_SMS`/`RECEIVE_SMS` access for live tracking).
- Distribution is private/sideloaded first; a public Play listing is a later, separate milestone gated on permission-disclosure approval.
- Product and architecture decisions live in the sibling `moneysync-guides` repository (`plan/`, `milestone/`); this repo (`money_sync/`) is application code only and must not duplicate or fork those documents.

## Capabilities and Constraints

- Connects to one Wallet account via a personal API bearer token (Wallet Premium required), stored only in Android Keystore-backed secure storage.
- Three processing modes: Manual (user-initiated), Review (queued, confirmed before Wallet create — recommended default), Automatic (feature-flagged, gated on calibrated confidence, eligible account, no duplicate/warning, and recent successful connection).
- Supports expense, income/credit, refund, transfer, authorization, settlement, reversal, and non-transaction classification, each with explicit sign/lifecycle rules (e.g. an authorization creates one `uncleared` record immediately; a matched settlement never creates a duplicate; a reversal is a separate linked compensating transaction).
- Every Wallet create/mutation goes through a durable outbox with reconciliation-before-retry; an inconclusive result is held for manual verification rather than retried blind.
- Mapping key is sender + parser/message family + masked instrument — never sender name alone.
- Initial bank coverage: Sampath credit card, Sampath savings/transfer, and NDB card SMS shapes; new banks are added as versioned parser rule packs, not UI/transport changes.
- ML Kit Entity Extraction (candidate money/date/address/IBAN/card spans) plus a separate on-device personalization classifier trained only from user-approved local examples; GenAI Summarization is explicitly excluded from any financial decision.
- Money is never represented as `double`; integer minor units or exact decimal with explicit currency/scale/rounding only.
- Edit/delete is allowed only on Wallet records this app created and confirmed-linked.
- Minimum Android API 23+ (unless bootstrap/package requirements demand higher); SQLite via Drift with whole-database encryption as a release gate.
- Undecided/deferred: public Play distribution timing, dual-SIM routing, iOS (explicitly out of scope — third-party apps cannot read the general SMS inbox on iOS).

## Brand Commitments

App name: "Money Sync" (package/display name `money_sync`). No further visual identity, logo, or voice commitments are recorded yet.

## Evidence on Hand

- Full product/architecture specification: `../plan/01-requirements-and-scope.md` through `../plan/10-ml-assisted-interpretation.md` in the sibling `moneysync-guides` repository.
- Milestone implementation order and exit criteria: `../milestone/README.md`, `../milestone/M0`–`M10`, `quality-gates.md`, `traceability.md`, `configuration-matrix.md`.
- `../plan/sms.txt` is private redacted sample source material — it must never be used as a fixture, copied into application artifacts, logs, or screenshots.
- No production Wallet test-account data, screenshots, or customer evidence is on hand yet; do not fabricate any.

## Product Principles

1. Privacy is structural, not a setting: raw SMS, labels, and training data never leave the device; only user-approved structured fields reach Wallet.
2. Correctness over convenience for money: exact decimal/integer amounts, idempotent creates, reconciliation before any retry, and no automatic write for authorization/refund/foreign-currency/transfer cases.
3. Deterministic parsing leads, ML assists: bank parser rules are the source of truth; ML Kit and the local classifier only add candidate evidence and never override a deterministic safety rule.
4. Review is the safe default; automation is earned per rule through calibrated evidence, not assumed.
5. The user stays in control of and can inspect/undo everything the app decides, without needing technical knowledge.

## Accessibility & Inclusion

Material 3 semantics, 48dp touch targets, text scaling support, non-color-only status labels, AA contrast — per `../plan/01-requirements-and-scope.md` quality attributes.
