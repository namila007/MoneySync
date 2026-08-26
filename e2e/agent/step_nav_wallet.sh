#!/usr/bin/env bash
# Step: Navigate to Settings > Wallet Connection.
# Uses nav_tab settings instead of raw coords.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

nav_tab settings
sleep 2

xml=$(ui_dump_xml)
if echo "$xml" | grep -qi "Settings"; then
  echo "screen=settings"
  if ! ensure_visible "Wallet connection"; then
    echo "ERROR: Wallet connection not found after scrolling"
    ui_elements
    exit 1
  fi
  if tap_desc "Wallet connection"; then
    sleep 2
    echo "screen=wallet_connection"
    echo "action=navigated_to_wallet"
  else
    echo "ERROR: Could not tap Wallet connection"
    ui_elements
    exit 1
  fi
else
  echo "ERROR: Not on settings screen"
  ui_elements
  exit 1
fi
