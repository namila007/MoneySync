#!/usr/bin/env bash
# Step: Ensure TEST_ACCOUNT is selected in the Wallet account picker.
# Uses select_test_account() from helpers.sh which scrolls automatically.
# Usage: step_review_select_account.sh [account_name]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

TARGET="${1:-$TEST_ACCOUNT_NAME}"

xml=$(ui_dump_xml)

# Check if wallet account field exists
if ! echo "$xml" | grep -qi "Wallet account"; then
  if ! ensure_visible "Wallet account"; then
    echo "ERROR: Wallet account field not found"
    echo "status=error"
    echo "message=wallet_account_field_not_found"
    ui_elements
    exit 1
  fi
fi

# Check if target is already selected
xml=$(ui_dump_xml)
if echo "$xml" | grep -qi "Wallet account&#10;${TARGET}"; then
  echo "status=ok"
  echo "account=$TARGET"
  echo "action=already_selected"
  exit 0
fi

# Open account picker
if tap_desc "Wallet account"; then
  sleep 2
  echo "action=opened_picker"
else
  echo "ERROR: Cannot open account picker"
  echo "status=error"
  echo "message=cannot_open_picker"
  ui_elements
  exit 1
fi

# Use shared helper to select account (scrolls automatically)
if select_test_account "$TARGET"; then
  echo "status=selected"
  echo "account=$TARGET"
else
  echo "ERROR: Account '$TARGET' not found"
  echo "status=error"
  echo "message=account_not_found"
  exit 1
fi
