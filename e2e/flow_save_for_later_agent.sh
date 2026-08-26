#!/usr/bin/env bash
# Orchestrator: Full Save for Later flow.
# Seed SMS → import → inbox → select message → save for later →
# verify waiting → approve from waiting → verify success.
# Usage: bash e2e/flow_save_for_later_agent.sh [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$SCRIPT_DIR/agent"

SENDER="${1:-SAMPATHTX}"
BODY="${2:-A/C 99999999 credited with LKR 60000.00 on $(date +%Y/%m/%d). Bal LKR 200000.00. Ref: TXN-SFL-$(date +%s)}"

echo "=========================================="
echo " Flow: Save for Later (Agent)"
echo "=========================================="

# Step 1: Seed SMS
echo ""
echo "[1/9] Seeding SMS..."
bash "$AGENT/step_sms_seed.sh" "$SENDER" "$BODY"

# Step 2: Run history scan
echo ""
echo "[2/9] Running history scan..."
bash "$AGENT/step_import_scan.sh"

# Step 3: Open inbox
echo ""
echo "[3/9] Opening inbox..."
bash "$AGENT/step_inbox_open.sh"

# Step 4: Tap message
echo ""
echo "[4/9] Selecting message..."
bash "$AGENT/step_inbox_tap_message.sh"

# Step 5: Read review fields
echo ""
echo "[5/9] Reviewing transaction fields..."
bash "$AGENT/step_review_read_fields.sh"

# Step 6: Select TEST_ACCOUNT
echo ""
echo "[6/9] Selecting TEST_ACCOUNT..."
bash "$AGENT/step_review_select_account.sh"

# Step 7: Save for later
echo ""
echo "[7/9] Saving for later..."
bash "$AGENT/step_review_save_for_later.sh"

# Step 8: Verify waiting count
echo ""
echo "[8/9] Checking home counts..."
bash "$AGENT/step_home_counts.sh"

# Step 9: Approve from waiting
echo ""
echo "[9/9] Approving from waiting queue..."
bash "$AGENT/step_waiting_approve.sh"

# Verify
echo ""
echo "=========================================="
echo " Verification"
echo "=========================================="
bash "$AGENT/step_home_counts.sh"
bash "$AGENT/step_log_check.sh" "Created record" "HttpWalletApi" "walletRecordCreated"
bash "$AGENT/step_activity_check.sh"
bash "$AGENT/step_log_error.sh"
