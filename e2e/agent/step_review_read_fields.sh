#!/usr/bin/env bash
# Step: Read the review transaction panel fields.
# Shows current values of all review fields (amount, kind, direction, account, etc.)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)

echo "=== REVIEW PANEL STATE ==="

# Check if review panel is visible
if ! echo "$xml" | grep -qi "Review transaction"; then
  echo "panel_visible=false"
  echo "Action needed: scroll down to see review panel"
  scroll_down
  sleep 1
  xml=$(ui_dump_xml)
  if ! echo "$xml" | grep -qi "Review transaction"; then
    echo "ERROR: Review transaction panel not found"
    ui_elements
    exit 1
  fi
fi

echo "panel_visible=true"

# Read field values from the XML
# Amount field - look for the text field near "Amount"
echo "--- fields ---"

# Check for kind dropdown (expense/income/transfer/refund)
if echo "$xml" | grep -qi "expense"; then echo "kind=expense"; fi
if echo "$xml" | grep -qi "income"; then echo "kind=income"; fi
if echo "$xml" | grep -qi "transfer"; then echo "kind=transfer"; fi
if echo "$xml" | grep -qi "refund"; then echo "kind=refund"; fi

# Check for direction
if echo "$xml" | grep -qi "debit"; then echo "direction=debit"; fi
if echo "$xml" | grep -qi "credit"; then echo "direction=credit"; fi
if echo "$xml" | grep -qi "neutral"; then echo "direction=neutral"; fi

# Check wallet account
if echo "$xml" | grep -qi "Wallet account"; then
  echo "wallet_account_field=present"
  # Check if an account is selected
  local acct
  acct=$(echo "$xml" | grep -oE 'HNB|Sampath|Bank|Account[^(]+' | head -1)
  if [ -n "$acct" ]; then
    echo "wallet_account=$acct"
  else
    echo "wallet_account=not_selected"
  fi
fi

# Check for action buttons
echo "--- actions ---"
if echo "$xml" | grep -qi "Create record"; then echo "has_create_button=true"; fi
if echo "$xml" | grep -qi "Save for later"; then echo "has_save_button=true"; fi

echo "=== END ==="
