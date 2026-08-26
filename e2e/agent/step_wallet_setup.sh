#!/usr/bin/env bash
# Step: Check wallet connection status and enter token if disconnected.
# Usage: step_wallet_setup.sh [token]
# If token arg is provided and wallet is disconnected, enters it and connects.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

TOKEN="${1:-}"

xml=$(ui_dump_xml)

# Check if already connected
if echo "$xml" | grep -qi "Connected"; then
  echo "wallet_status=connected"
  echo "action=already_connected"
  # Check for account count
  echo "$xml" | grep -oE 'Accounts[^<]*' | head -1
  exit 0
fi

# Check if on wallet connection page
if echo "$xml" | grep -qi "Connect Wallet\|API token"; then
  echo "wallet_status=disconnected"

  if [ -z "$TOKEN" ]; then
    echo "action=needs_token"
    echo "Provide token as argument: step_wallet_setup.sh <token>"
    exit 0
  fi

  # Find and fill the token field
  # The TextField has hint "API token" - find its bounds
  local bounds
  bounds=$(find_bounds "API token")
  if [ -z "$bounds" ]; then
    # Try finding by node attributes
    bounds=$(echo "$xml" | grep -oE '<node[^>]*text=""[^>]*bounds="[^"]*"' | head -1 | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
  fi

  if [ -n "$bounds" ]; then
    local cx cy
    cx=$(center_of "$bounds" | cut -d' ' -f1)
    cy=$(center_of "$bounds" | cut -d' ' -f2)
    tap "$cx" "$cy"
    sleep 1
    type_text "$TOKEN"
    sleep 1
    echo "action=token_entered"

    # Scroll down to see Save button
    scroll_down
    sleep 1

    # Tap Save & connect
    if tap_desc "Save & connect"; then
      sleep 5
      echo "action=connecting"
      # Check if connected now
      xml2=$(ui_dump_xml)
      if echo "$xml2" | grep -qi "Connected"; then
        echo "wallet_status=connected"
        echo "action=connected_successfully"
      else
        echo "wallet_status=unknown"
        echo "action=connect_pending"
        ui_elements
      fi
    else
      echo "ERROR: Save & connect button not found"
      ui_elements
    fi
  else
    echo "ERROR: Token field not found"
    ui_elements
  fi
else
  echo "ERROR: Not on wallet connection page"
  echo "current screen:"
  ui_elements
fi
