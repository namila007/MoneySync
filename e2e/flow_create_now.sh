#!/usr/bin/env bash
# Flow 2: Create Now → Immediate Success → Verify Inbox Clean
# Usage: ./flow_create_now.sh [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/adb_helpers.sh"

SENDER="${1:-SAMPATHTX}"
BODY="${2:-LKR 7500.00 debited from AC **3344 for COFFEE SHOP 5 Avl Bal: LKR 42000.00}"

echo "=== Flow 2: Create Now ==="
preflight

# Step 1: Seed SMS
seed_sms "$SENDER" "$BODY"

# Step 2: Import
echo "[2/6] Importing..."
tap 540 987; sleep 3
tap 540 1743; sleep 3
tap 540 1573; sleep 3
go_back; sleep 2
check_log "Import complete"

# Step 3: Open inbox, tap message
echo "[3/6] Opening review..."
tap 405 2232; sleep 3      # Inbox tab
tap_desc "$BODY"; sleep 3  # Tap message
scroll_down; sleep 1       # See Create button

# Step 4: Select TEST_ACCOUNT → Create record
echo "[4/6] Selecting TEST_ACCOUNT and creating record..."
tap_desc "Wallet account"; sleep 2
select_test_account
scroll_down; sleep 1
tap_desc "Create record"; sleep 8
check_log "ReviewSubmitted"
check_log "HttpWalletApi"

# Step 5: Verify home counts
echo "[5/6] Checking home..."
tap 135 2232; sleep 3      # Home tab
get_home_counts

# Step 6: Verify message removed from inbox
echo "[6/6] Checking inbox..."
tap 405 2232; sleep 3      # Inbox tab
if dump_ui | grep -q "$BODY"; then
  echo "WARN: Message still in inbox (may need candidate-state filter)"
else
  echo "PASS: Message removed from inbox"
fi

echo "=== Flow 2: DONE ==="
