#!/usr/bin/env bash
# Orchestrator: Connect wallet with API token.
# Navigates to settings → wallet → enters token → verifies connected.
# Usage: bash e2e/flow_wallet_setup.sh <token>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$SCRIPT_DIR/agent"

TOKEN="${1:-}"
if [ -z "$TOKEN" ]; then
  echo "Usage: bash e2e/flow_wallet_setup.sh <wallet_api_token>"
  echo "Get token from BudgetBakers → Settings → API"
  exit 1
fi

echo "=========================================="
echo " Flow: Connect Wallet"
echo "=========================================="

# Navigate to wallet settings
echo ""
echo "[1/3] Navigating to wallet connection..."
bash "$AGENT/step_nav_wallet.sh"

# Setup wallet with token
echo ""
echo "[2/3] Entering token and connecting..."
bash "$AGENT/step_wallet_setup.sh" "$TOKEN"

# Verify connection
echo ""
echo "[3/3] Verifying connection..."
bash "$AGENT/step_wallet_check.sh"

echo ""
echo "=========================================="
echo " Wallet Setup Complete"
echo "=========================================="
bash "$AGENT/step_log_check.sh" "walletConnected" "HttpWalletApi"
