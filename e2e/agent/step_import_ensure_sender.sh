#!/usr/bin/env bash
# Step: Navigate to Settings > Tracked Senders and ensure sender is tracked.
# Usage: step_import_ensure_sender.sh [sender_name]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SENDER="${1:-SAMPATHTX}"

nav_tab settings
sleep 2

if ! ensure_visible "Tracked senders"; then
  echo "ERROR: Tracked senders not found"
  ui_elements
  exit 1
fi

if tap_desc "Tracked senders"; then
  sleep 2
else
  echo "ERROR: Could not tap Tracked senders"
  ui_elements
  exit 1
fi

xml=$(ui_dump_xml)
if echo "$xml" | grep -qi "Tracked senders"; then
  echo "sender=$SENDER"
  if echo "$xml" | grep -qi "$SENDER"; then
    echo "status=already_listed"
    echo "action=none_needed"
  else
    echo "status=not_found"
    echo "action=needs_manual_add"
  fi
  go_back
  sleep 1
else
  echo "ERROR: Not on tracked senders page"
  ui_elements
fi
