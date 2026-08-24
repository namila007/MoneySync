#!/usr/bin/env bash
# Flow 1: Save for Later → Waiting → Approve → Success
# Usage: ./flow_save_for_later.sh [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/adb_helpers.sh"

SENDER="${1:-SAMPATHTX}"
BODY="${2:-A/C 77778888 credited with LKR 40000.00 on 2026/08/24. Bal LKR 110000.00. Ref: TXN-SFL-001}"

echo "=== Flow 1: Save for Later ==="
preflight

# Step 1: Seed SMS
seed_sms "$SENDER" "$BODY"

# Step 2: Import via History
echo "[2/7] Importing via history..."
tap 540 987; sleep 3       # Scan messages
tap 540 1743; sleep 3      # Find messages
tap 540 1573; sleep 3      # Done
go_back; sleep 2           # Back to home
check_log "Import complete"

# Step 3: Open inbox, tap new message
echo "[3/7] Opening inbox..."
tap 405 2232; sleep 3      # Inbox tab
tap_desc "$BODY"; sleep 3  # Tap the new message (partial match)
scroll_down; sleep 1       # See Save for later button

# Step 4: Select TEST_ACCOUNT → Save for later
echo "[4/7] Selecting TEST_ACCOUNT and saving for later..."
tap_desc "Wallet account"; sleep 2
select_test_account
scroll_down; sleep 1
tap_desc "Save for later"; sleep 5
check_log "ReviewSubmitted"

# Step 5: Verify home counts
echo "[5/7] Checking home counts..."
tap 135 2232; sleep 3      # Home tab
get_home_counts
assert_count "Waiting" "1"

# Step 6: Approve from Waiting
echo "[6/7] Approving from Waiting..."
tap_desc "Waiting"; sleep 3          # Tap Waiting tile
tap 540 377; sleep 3                 # Tap mutation row
tap_desc "Approve"; sleep 8         # Tap Approve
check_log "HttpWalletApi"

# Step 7: Verify success
echo "[7/7] Verifying success..."
go_back; sleep 2                     # Back to home
get_home_counts
check_log "Created record"

echo "=== Flow 1: DONE ==="
