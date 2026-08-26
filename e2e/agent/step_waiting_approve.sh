#!/usr/bin/env bash
# Step: Open the Waiting queue from home, tap a mutation, and approve it.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Go to home first
tap 135 2232
sleep 2

xml=$(ui_dump_xml)
# Check waiting count
local waiting_count
waiting_count=$(echo "$xml" | grep -oE 'content-desc="[0-9]+\\nWaiting"' | grep -oE '^[0-9]+' || echo "0")
echo "waiting_count=$waiting_count"

if [ "$waiting_count" = "0" ] || [ "$waiting_count" = "?" ]; then
  echo "ERROR: No waiting items"
  exit 1
fi

# Tap Waiting tile
if tap_desc "Waiting"; then
  sleep 3
  echo "action=opened_waiting"
else
  echo "ERROR: Waiting tile not found"
  ui_elements
  exit 1
fi

xml=$(ui_dump_xml)
# Tap the first mutation row
local first_item
first_item=$(echo "$xml" | grep -oE 'content-desc="[^"]*"' | sed 's/content-desc="//;s/"//' | grep -v "Tab\|Settings\|Approve\|Clear\|Back" | head -1)
if [ -n "$first_item" ]; then
  tap_desc "$first_item"
  sleep 3
  echo "action=tapped_mutation"
else
  # Try tapping first row by coordinates
  tap 540 377
  sleep 3
  echo "action=tapped_first_row_by_coords"
fi

# Look for Approve button
xml2=$(ui_dump_xml)
if echo "$xml2" | grep -qi "Approve"; then
  tap_desc "Approve"
  sleep 8
  echo "action=approved"

  # Check result
  xml3=$(ui_dump_xml)
  if echo "$xml3" | grep -qi "Created\|Success"; then
    echo "result=success"
  else
    echo "result=check_logs"
  fi
else
  echo "ERROR: Approve button not found"
  ui_elements
  exit 1
fi
