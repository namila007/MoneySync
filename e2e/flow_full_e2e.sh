#!/usr/bin/env bash
# Orchestrator: Complete E2E test - all flows chained.
# 1. Onboarding
# 2. Wallet connection
# 3. Import message
# 4. Create Now flow
# 5. Save for Later flow
# Usage: bash e2e/flow_full_e2e.sh <wallet_token> [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

TOKEN="${1:-}"
if [ -z "$TOKEN" ]; then
  echo "Usage: bash e2e/flow_full_e2e.sh <wallet_token> [sender] [body]"
  exit 1
fi

SENDER="${2:-SAMPATHTX}"
BODY="${3:-}"

echo "╔══════════════════════════════════════════╗"
echo "║   MoneySync Full E2E Test Suite          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Flow 1: Onboarding
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PHASE 1: Onboarding"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/flow_onboarding.sh" sms_grant
echo ""

# Flow 2: Wallet Setup
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PHASE 2: Wallet Connection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/flow_wallet_setup.sh" "$TOKEN"
echo ""

# Flow 3: Import Message
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PHASE 3: Import Message"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/flow_import_message.sh" "$SENDER" "$BODY"
echo ""

# Flow 4: Create Now
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PHASE 4: Create Now"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/flow_create_now_agent.sh" "$SENDER"
echo ""

# Flow 5: Save for Later
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PHASE 5: Save for Later"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/flow_save_for_later_agent.sh" "$SENDER"
echo ""

echo "╔══════════════════════════════════════════╗"
echo "║   All E2E Flows Complete                 ║"
echo "╚══════════════════════════════════════════╝"
