---
name: moneysync-e2e
description: |-
  MoneySync end-to-end device testing flows via ADB. Agent-driven step
  scripts in e2e/agent/ return structured output for AI decision-making.
  Orchestrator scripts in e2e/ chain steps for full flows. Covers
  onboarding, wallet setup, SMS import, Create Now, Save for Later,
  and full E2E. All flows use TEST_ACCOUNT only.
version: 3.0.0
source: M5.20 E2E verification session (2026-08-24), agent rewrite (2026-08-26)
---

# MoneySync E2E Device Testing

> See also: `e2e/README.md` for quick-start, directory layout, and flow diagrams.

## Architecture

```
e2e/
  agent/                          # Step scripts (agent-driven, structured output)
    helpers.sh                    # Shared library — ALL UI logic lives here
    step_app_launch.sh            # Launch app, detect screen
    step_screen_dump.sh           # Full screen state dump
    step_onboard_next.sh          # Tap Next on onboarding step
    step_onboard_sms_grant.sh     # Grant SMS permission during onboarding
    step_onboard_finish.sh        # Tap Finish on last onboarding step
    step_onboard_dismiss_review.sh  # Dismiss "Setup complete" page
    step_nav_tab.sh               # Navigate to bottom nav tab (canonical)
    step_nav_home.sh              # Navigate back to home
    step_nav_wallet.sh            # Navigate to Settings > Wallet Connection
    step_wallet_setup.sh          # Enter API token and connect wallet
    step_wallet_check.sh          # Check wallet + validate TEST_ACCOUNT exists
    step_sms_seed.sh              # Seed SMS on emulator
    step_import_ensure_sender.sh  # Ensure sender is tracked
    step_import_scan.sh           # Run history import scan
    step_inbox_open.sh            # Open inbox, list messages
    step_inbox_tap_message.sh     # Tap a message to open review
    step_read_dropdowns.sh        # Read all dropdowns (values, bounds, options)
    step_select_dropdown.sh       # Select dropdown option (scrolls if needed)
    step_review_read_fields.sh    # Read review panel field values
    step_review_select_account.sh # Select TEST_ACCOUNT in picker (uses helpers)
    step_review_create_now.sh     # Tap "Create record"
    step_review_save_for_later.sh # Tap "Save for later"
    step_waiting_approve.sh       # Open waiting queue, approve mutation
    step_home_counts.sh           # Get Review/Retry/Waiting/Success counts
    step_log_check.sh             # Search logs for patterns
    step_log_error.sh             # Read error log
    step_log_info.sh              # Read info log
    step_activity_check.sh        # Check activity log entries
  flow_onboarding.sh              # Orchestrator: complete onboarding
  flow_wallet_setup.sh            # Orchestrator: connect wallet
  flow_import_message.sh          # Orchestrator: import a message
  flow_create_now_agent.sh        # Orchestrator: full Create Now flow
  flow_save_for_later_agent.sh    # Orchestrator: full Save for Later flow
  flow_full_e2e.sh                # Orchestrator: all flows chained
  flow_negative.sh                # Negative test cases
  run_all.sh                      # Run all flows
```

## Prerequisites

- Emulator running (`adb devices` → `emulator-5554 device`)
- `privateFull` flavor installed with matching Dart entrypoint
- **TEST_ACCOUNT wallet connected** (check Settings → Wallet)

## TEST_ACCOUNT Rule

**Every E2E flow MUST use the designated TEST_ACCOUNT wallet exclusively.**

Default: `TEST_ACCOUNT`. Override with:
```bash
TEST_ACCOUNT_NAME="MyTestAccount" bash e2e/flow_create_now_agent.sh
```

**Validation:** `step_wallet_check.sh` automatically verifies TEST_ACCOUNT
exists after wallet connection. If missing, it outputs:
```
test_account=missing
ACTION_REQUIRED: Create account 'TEST_ACCOUNT' in BudgetBakers wallet, then re-run E2E.
```

**Scrolling:** TEST_ACCOUNT is typically below the visible area. All
account selection functions scroll automatically (up to 5 times).

## Agent-Driven Mode (Recommended)

Step scripts return structured output so an AI agent can read state
and decide the next action. Each script is atomic and idempotent.

### Agent Workflow Pattern

```
1. Run step → get structured output
2. Parse output to understand screen state
3. Decide next action based on output
4. Run next step
5. Repeat until flow complete
```

### Quick Reference: Agent Steps

| Script | Purpose | Key Output |
|--------|---------|------------|
| `step_screen_dump.sh` | Full screen state | `screen=`, `onboarding=`, `panel=` |
| `step_app_launch.sh` | Launch app | `screen=onboarding\|home\|lock` |
| `step_onboard_next.sh` | Tap Next | `current_step=`, `action=tap_next` |
| `step_onboard_sms_grant.sh` | Grant SMS | `action=granted_via_adb` |
| `step_onboard_finish.sh` | Finish onboarding | `action=onboarding_complete` |
| `step_nav_wallet.sh` | Go to wallet settings | `screen=wallet_connection` |
| `step_wallet_setup.sh [token]` | Enter token | `wallet_status=connected` |
| `step_wallet_check.sh` | Check wallet + TEST_ACCOUNT | `test_account=found\|missing` |
| `step_sms_seed.sh [sender] [body]` | Seed SMS | `sender=`, `body=` |
| `step_import_scan.sh` | Run scan | `action=scan_complete` |
| `step_inbox_open.sh` | Open inbox | `message_count=N` |
| `step_inbox_tap_message.sh [text]` | Tap message | `screen=review_panel` |
| `step_read_dropdowns.sh` | Read dropdowns | `dropdown=kind`, `current_value=`, `options=` |
| `step_select_dropdown.sh <dd> <opt>` | Select option | `status=selected`, `value=` |
| `step_review_read_fields.sh` | Read fields | `kind=`, `wallet_account=` |
| `step_review_select_account.sh` | Pick TEST_ACCOUNT | `account=TEST_ACCOUNT`, `status=selected` |
| `step_review_create_now.sh` | Create record | `result=success` |
| `step_review_save_for_later.sh` | Save for later | `result=queued` |
| `step_waiting_approve.sh` | Approve waiting | `result=success` |
| `step_home_counts.sh` | Dashboard counts | `{"review":N,"waiting":N,...}` |
| `step_log_check.sh [patterns]` | Search logs | `found=true/false` per pattern |
| `step_log_error.sh` | Error log | `status=clean\|has_errors` |
| `step_activity_check.sh` | Activity entries | `status=empty\|has_entries` |

### Dropdown Scripts

**Read all dropdowns on current screen:**
```bash
bash e2e/agent/step_read_dropdowns.sh
```

**Select a dropdown option (scrolls automatically):**
```bash
bash e2e/agent/step_select_dropdown.sh kind income
bash e2e/agent/step_select_dropdown.sh direction credit
bash e2e/agent/step_select_dropdown.sh wallet_account TEST_ACCOUNT
bash e2e/agent/step_select_dropdown.sh category "All Income"
```

**Available dropdowns:** kind, direction, payment_type, wallet_account, category, date

**Field rules:**
- Credited SMS → kind=income, direction=credit
- Debited SMS → kind=expense, direction=debit
- Wallet account must be TEST_ACCOUNT (scrolls to find)
- Category must be selected
- Date must be picked
- Amount must be non-zero

## Orchestrator Scripts (Full Flows)

```bash
cd money_sync/

# Full onboarding (grant SMS)
bash e2e/flow_onboarding.sh sms_grant

# Connect wallet
bash e2e/flow_wallet_setup.sh <wallet_token>

# Import a message
bash e2e/flow_import_message.sh SAMPATHTX "LKR 5000 debited..."

# Full Create Now flow
bash e2e/flow_create_now_agent.sh SAMPATHTX "LKR 5000 debited..."

# Full Save for Later flow
bash e2e/flow_save_for_later_agent.sh SAMPATHTX "LKR 5000 credited..."

# Complete E2E (all flows)
bash e2e/flow_full_e2e.sh <wallet_token> SAMPATHTX

# Negative tests
bash e2e/flow_negative.sh zero_amount

# Run all
bash e2e/run_all.sh
```

## Helper Functions (agent/helpers.sh)

Source in custom scripts:
```bash
source "$(dirname "$0")/agent/helpers.sh"
```

### Navigation (canonical — use these instead of raw coords)
| Function | Purpose |
|----------|---------|
| `nav_tab NAME` | Navigate to tab (home/inbox/mappings/activity/settings) |
| `ensure_visible DESC [max]` | Scroll until element visible |

### UI State
| Function | Purpose |
|----------|---------|
| `detect_screen` | Returns which screen/step is showing |
| `ui_dump_xml` | Raw UI XML dump |
| `ui_check "text"` | Check if text exists (exit 0/1) |
| `ui_elements` | List all content-desc values |
| `ui_texts` | List all text values |
| `wait_for "text" [timeout] [poll]` | Poll until text appears |

### UI Interaction
| Function | Purpose |
|----------|---------|
| `find_bounds "desc"` | Find element bounds by content-desc |
| `find_bounds_with_scroll "desc" [max]` | Find with scroll |
| `tap_bounds BOUNDS` | Tap center of bounds string |
| `tap_desc "desc"` | Tap element by content-desc |
| `tap X Y` | Tap coordinates |
| `scroll_down` / `scroll_up` | Scroll page |
| `go_back` | Press back |
| `type_text "text"` | Type into field |
| `clear_field` | Clear field (10x backspace) |

### Account Selection
| Function | Purpose |
|----------|---------|
| `select_test_account [name]` | Select TEST_ACCOUNT (scrolls) |
| `check_test_account_exists` | Validate TEST_ACCOUNT in wallet |

### Logging
| Function | Purpose |
|----------|---------|
| `log_flutter [lines]` | Read Flutter logcat |
| `log_search "pattern"` | Search logs for pattern |
| `log_info` | Read app info log |
| `log_error` | Read app error log |
| `log_check "pattern"` | Structured log search |

### State
| Function | Purpose |
|----------|---------|
| `get_home_counts` | Get dashboard counts |
| `home_counts_json` | Counts as JSON |
| `assert_count tile expected` | Assert count equals |
| `check_wallet_connected` | Check wallet status |
| `check_sms_permission` | Check SMS permission |

### Device
| Function | Purpose |
|----------|---------|
| `preflight` | Check device attached |
| `build_and_install` | Build and install APK |
| `launch` | Force-stop and start app |
| `grant_sms_permission` | Grant via adb |
| `revoke_sms_permission` | Revoke via adb |
| `seed_sms sender body` | Seed SMS on emulator |

## UI Coordinates (1080×2400 screen)

| Target | Constant | Value |
|--------|----------|-------|
| Home tab | `TAB_HOME_X/Y` | 135, 2232 |
| Inbox tab | `TAB_INBOX_X/Y` | 405, 2232 |
| Mappings tab | `TAB_MAPPINGS_X/Y` | 675, 2232 |
| Activity tab | `TAB_ACTIVITY_X/Y` | 945, 2232 |
| Settings gear | `SETTINGS_GEAR_X/Y` | 1017, 210 |

**Always use `nav_tab` instead of raw coordinates.**

## Reading Logs

```bash
# App info log
adb exec-out run-as me.namila.money_sync.privatefull sh -c "cat code_cache/logs/app/info.log"

# App error log
adb exec-out run-as me.namila.money_sync.privatefull sh -c "cat code_cache/logs/app/error.log"

# Live Flutter logcat
adb logcat -s flutter
```

## E2E Transaction Label

All E2E-created records include the label `testing_e2e` via the note field:
```
note: "[e2e] SMS import — testing_e2e"
```
