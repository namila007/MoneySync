---
name: moneysync-e2e
description: |-
  MoneySync end-to-end device testing flows via ADB: Save for Later,
  Create Now, negative validation, home dashboard verification, activity
  log checks, and success detail page verification. Uses pre-built
  scripts in money_sync/e2e/. All flows use TEST_ACCOUNT wallet only.
version: 1.1.0
source: M5.20 E2E verification session (2026-08-24)
---

# MoneySync E2E Device Testing

## Prerequisites

- Emulator running (`adb devices` → `emulator-5554 device`)
- `privateFull` flavor installed with matching Dart entrypoint
- **TEST_ACCOUNT wallet connected** (check Settings → Wallet)

## TEST_ACCOUNT Rule

**Every E2E flow MUST use the designated TEST_ACCOUNT wallet exclusively.**
Never read, write, or otherwise touch any other Wallet account during
dev/E2E verification. This is a standing project rule from `AGENTS.md`.

When selecting an account in the review flow, always pick the TEST_ACCOUNT
(e.g. "HNB" or whichever account is the designated test account). Never
select a real personal account.

## E2E Transaction Label

All E2E-created records include the label `testing_e2e` to distinguish
them from real user transactions. This label is added automatically by
the create payload serializer when the `E2E_LABEL` environment variable
is set, or when the note contains the E2E marker `[e2e]`.

In the E2E scripts, the label is applied via the note field:
```
note: "[e2e] SMS import — testing_e2e"
```

## Quick Start

```bash
cd money_sync/

# Run all flows
bash e2e/run_all.sh

# Run a specific flow
bash e2e/flow_save_for_later.sh
bash e2e/flow_create_now.sh
bash e2e/flow_negative.sh
bash e2e/flow_negative.sh zero_amount
```

## Available Scripts

| Script | Flow | What it tests |
|--------|------|---------------|
| `e2e/adb_helpers.sh` | Library | Common ADB functions (tap, dump, seed, assert) |
| `e2e/flow_save_for_later.sh` | Save for Later → Waiting → Approve → Success | Deferred create, waiting view, approve, live HTTP |
| `e2e/flow_create_now.sh` | Create Now → Immediate Success → Inbox clean | Immediate create, inbox removal, success count |
| `e2e/flow_negative.sh` | Zero amount, no account, duplicate | Validation gates, duplicate prevention |
| `e2e/run_all.sh` | All flows sequentially | Full regression |

## Script Usage

### flow_save_for_later.sh

```bash
# Default SMS
bash e2e/flow_save_for_later.sh

# Custom SMS
bash e2e/flow_save_for_later.sh SAMPATHTX "A/C 1234 credited with LKR 50000.00..."
```

**Steps:**
1. Seed SMS
2. Import via History
3. Open inbox → tap message
4. **Select TEST_ACCOUNT** from account picker
5. Tap "Save for later"
6. Verify Waiting=1 on home
7. Open Waiting view → tap mutation → Approve
8. Verify Success incremented, HTTP 200 OK
9. Verify Activity log shows event, no Retry/Verify buttons

### flow_create_now.sh

```bash
bash e2e/flow_create_now.sh
bash e2e/flow_create_now.sh SAMPATHTX "LKR 3000.00 debited..."
```

**Steps:**
1. Seed SMS
2. Import via History
3. Open inbox → tap message
4. **Select TEST_ACCOUNT** from account picker
5. Tap "Create record"
6. Verify Success incremented
7. Verify message removed from inbox

### flow_negative.sh

```bash
bash e2e/flow_negative.sh              # all negative tests
bash e2e/flow_negative.sh zero_amount  # amount=0 validation
bash e2e/flow_negative.sh no_account   # no account selected
bash e2e/flow_negative.sh duplicate    # double-submit prevention
```

## Account Selection in Scripts

When the review flow reaches the account picker, the scripts tap the
TEST_ACCOUNT entry. The default TEST_ACCOUNT name is "HNB". To use a
different account, set the `TEST_ACCOUNT_NAME` environment variable:

```bash
TEST_ACCOUNT_NAME="Sampath" bash e2e/flow_save_for_later.sh
```

The account picker is a bottom sheet with account names as content-desc
values. The script finds and taps the matching entry.

## Helper Functions (adb_helpers.sh)

Source the helpers in custom scripts:

```bash
source "$(dirname "$0")/adb_helpers.sh"
```

| Function | Purpose |
|----------|---------|
| `preflight` | Check device is attached |
| `build_and_install [flavor] [target]` | Build and install APK |
| `launch` | Force-stop and start app |
| `dump_ui` | Dump UI and list content-desc values |
| `find_bounds "desc"` | Find element bounds by content-desc |
| `tap_desc "desc"` | Tap center of element by content-desc |
| `tap X Y` | Tap absolute coordinates |
| `scroll_down` / `scroll_up` | Scroll the page |
| `go_back` | Press back button |
| `type_text "text"` | Type into focused field |
| `clear_field` | Clear focused field (6x backspace) |
| `seed_sms sender body` | Seed SMS on emulator |
| `check_log pattern` | Search Flutter logcat |
| `check_error_log` | Read app error.log |
| `get_home_counts` | Get Review/Retry/Waiting/Success counts |
| `assert_count tile expected` | Assert tile count equals expected |
| `select_test_account` | Tap TEST_ACCOUNT in account picker |
| `dump_to_file path` | Save UI dump to file |
| `logcat_to_file path` | Save logcat to file |

## UI Coordinates (1080×2400 screen)

| Target | Content-desc | Center |
|--------|-------------|--------|
| Home tab | `Home\nTab 1 of 4` | 135, 2232 |
| Inbox tab | `Inbox\nTab 2 of 4` | 405, 2232 |
| Mappings tab | `Mappings\nTab 3 of 4` | 675, 2232 |
| Activity tab | `Activity\nTab 4 of 4` | 945, 2232 |
| Scan messages | `Scan messages` | 540, 987 |
| Settings gear | `Settings` | 1017, 210 |

**Always dump first to verify coordinates before tapping.**

## Reading Logs

```bash
# App info log
adb exec-out run-as me.namila.money_sync.privatefull sh -c "cat code_cache/logs/app/info.log"

# App error log
adb exec-out run-as me.namila.money_sync.privatefull sh -c "cat code_cache/logs/app/error.log"

# Live Flutter logcat
adb logcat -s flutter

# Check for E2E transactions specifically
adb logcat -d -s flutter | grep -i "e2e\|testing_e2e"
```

## Capturing Evidence

```bash
mkdir -p worklog/evidence/m5.20
adb exec-out uiautomator dump /dev/tty > worklog/evidence/m5.20/flow1-home.xml
adb logcat -d > worklog/evidence/m5.20/flow1-logcat.txt
```

Note: `adb exec-out screencap -p` returns solid black under `FLAG_SECURE`. Use uiautomator dumps instead.

## Identifying E2E Records in BudgetBakers

E2E records can be identified by:
- **Note field:** contains `[e2e]` marker
- **Label:** `testing_e2e` (when label support is implemented)
- **Amount pattern:** round numbers (30000, 40000, etc.) from seeded SMS
- **Counterparty:** synthetic test merchants

To clean up E2E records after testing, search BudgetBakers for records
with the `[e2e]` note marker and delete them manually.
