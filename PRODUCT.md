# MoneySync — Product Context

## What it is

MoneySync is an Android-first personal finance app that reads SMS bank alerts from Sri Lankan financial institutions and syncs them as structured transactions to a Wallet API. All processing is on-device; no message content leaves the phone.

## Who it is for

Sri Lankan users who receive SMS transaction alerts from banks (COMBANK, HNB, Sampath, NDB), wallets (Dialog eZ Cash, FriMi, mCash), and payment systems (LankaQR). They want a local, private ledger that captures every transaction without manual entry.

## Product principles

1. **Privacy-first.** SMS bodies never leave the device. Only user-approved structured payloads reach the Wallet API. Encrypted local storage (SQLCipher), Android Keystore-backed keys, no backup.
2. **Review-first default.** Financial automation earns trust gradually. New senders and high-value transactions require explicit user review before syncing. Automatic mode is opt-in per mapping rule.
3. **Plain language.** No "AI magic." Show suggestions, evidence, confidence, and correction controls in plain financial terms.
4. **Idempotent and recoverable.** No duplicate creates. No blind retries. Killed processes resume from watermarks. Unknown wallet states reconcile before retry.
5. **Flavor-gated capabilities.** `playManual` (no SMS permission) and `privateFull` (SMS + background scan) share the Dart codebase but differ in manifest and native capabilities.

## Core flows

1. **Onboarding** — 8-step wizard: welcome, privacy explanation, SMS promise, device protection, permission education, disclosure, SMS access decision.
2. **SMS ingestion** — Background polling (privateFull) or manual import. Tracked-sender allowlist. HMAC-based deduplication.
3. **Review inbox** — Parse candidates, confirm merchant/amount/category/account, approve or reject.
4. **Mapping rules** — Sender + instrument + payment type → wallet account + sync mode (manual/review/automatic).
5. **Wallet sync** — Outbox with waiting/retry/success states. No blind retry; unknown states reconcile first.
6. **Settings** — Security (app lock, screenshot protection), SMS access, history import, tracked senders, data control.

## Platform

- **Android only.** Flutter + Kotlin. Drift (SQLCipher) for local storage. Riverpod for state. GoRouter for navigation.
- **Flavors:** `privateFull` (READ_SMS, WorkManager background scan) and `playManual` (no SMS permission, manual import only).
- **Min SDK:** Android 8.0 (API 26). Target: Android 16.

## Surface inventory

22 routable pages: 4 shell tabs (Home, Inbox, Mappings, Activity), 2 auth gates (Lock, Onboarding), 6 settings sub-pages, 5 wallet sync views, 3 inbox flow views, mapping editor, manual import.

## Design prototype

`app-design/MoneySync.dc.html` — Modernist design system (Archivo typeface, warm neutrals, red-orange accent, zero border-radius, 2px borders, bold typography). This is the target visual language for the UI refactoring.
