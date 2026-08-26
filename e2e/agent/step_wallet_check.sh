#!/usr/bin/env bash
# Step: Verify wallet connection status AND validate TEST_ACCOUNT exists.
# If TEST_ACCOUNT is missing, outputs actionable message for agent/user.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)

if echo "$xml" | grep -qi "Connected"; then
  echo "wallet_status=connected"
  # Check for account count
  echo "$xml" | grep -oE '[0-9]+&#10;Accounts' | grep -oE '^[0-9]+' | head -1 | \
    xargs -I{} echo "accounts={}"

  # Validate TEST_ACCOUNT exists in the wallet
  echo "--- checking TEST_ACCOUNT ---"
  if check_test_account_exists; then
    echo "test_account=found"
  else
    echo "test_account=missing"
    echo "ACTION_REQUIRED: Create account '$TEST_ACCOUNT_NAME' in BudgetBakers wallet, then re-run E2E."
    exit 1
  fi
  exit 0
elif echo "$xml" | grep -qi "Connect Wallet"; then
  echo "wallet_status=disconnected"
  exit 1
else
  echo "wallet_status=unknown"
  echo "elements:"
  ui_elements
  exit 2
fi
