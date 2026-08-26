#!/usr/bin/env bash
# Orchestrator: Import a message via history scan.
# Seeds SMS → runs history scan → verifies message in inbox.
# Usage: bash e2e/flow_import_message.sh [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$SCRIPT_DIR/agent"

SENDER="${1:-SAMPATHTX}"
BODY="${2:-}"

echo "=========================================="
echo " Flow: Import Message"
echo "=========================================="

# Ensure senders are tracked
echo ""
echo "[1/4] Checking tracked senders..."
bash "$AGENT/step_import_ensure_sender.sh" "$SENDER"

# Seed SMS
echo ""
echo "[2/4] Seeding SMS..."
if [ -n "$BODY" ]; then
  bash "$AGENT/step_sms_seed.sh" "$SENDER" "$BODY"
else
  bash "$AGENT/step_sms_seed.sh" "$SENDER"
fi

# Run history scan
echo ""
echo "[3/4] Running history scan..."
bash "$AGENT/step_import_scan.sh"

# Verify in inbox
echo ""
echo "[4/4] Checking inbox..."
bash "$AGENT/step_inbox_open.sh"

echo ""
echo "=========================================="
echo " Import Complete"
echo "=========================================="
bash "$AGENT/step_log_check.sh" "Import" "imported"
