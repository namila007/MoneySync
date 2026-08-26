#!/usr/bin/env bash
# Orchestrator: Full Create Now flow.
# Seed SMS → import → open inbox → select message → review → select account → create → verify.
# Usage: bash e2e/flow_create_now_agent.sh [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$SCRIPT_DIR/agent"

SENDER="${1:-SAMPATHTX}"
BODY="${2:-A/C 99999999 debited with LKR 3000.00 at TESTPOS. Ref: TXN-CR-$(date +%s)}"

echo "=========================================="
echo " Flow: Create Now (Agent)"
echo "=========================================="

# Step 1: Seed SMS
echo ""
echo "[1/7] Seeding SMS..."
bash "$AGENT/step_sms_seed.sh" "$SENDER" "$BODY"

# Step 2: Run history scan
echo ""
echo "[2/7] Running history scan..."
bash "$AGENT/step_import_scan.sh"

# Step 3: Open inbox
echo ""
echo "[3/7] Opening inbox..."
bash "$AGENT/step_inbox_open.sh"

# Step 4: Tap message
echo ""
echo "[4/7] Selecting message..."
bash "$AGENT/step_inbox_tap_message.sh"

# Step 5: Read review fields
echo ""
echo "[5/7] Reviewing transaction fields..."
bash "$AGENT/step_review_read_fields.sh"

# Step 6: Select TEST_ACCOUNT
echo ""
echo "[6/7] Selecting TEST_ACCOUNT..."
bash "$AGENT/step_review_select_account.sh"

# Step 7: Create record
echo ""
echo "[7/7] Creating record..."
bash "$AGENT/step_review_create_now.sh"

# Verify
echo ""
echo "=========================================="
echo " Verification"
echo "=========================================="
bash "$AGENT/step_home_counts.sh"
bash "$AGENT/step_log_check.sh" "Created record" "HttpWalletApi" "ReviewSubmitted"
bash "$AGENT/step_inbox_open.sh"
bash "$AGENT/step_log_error.sh"
