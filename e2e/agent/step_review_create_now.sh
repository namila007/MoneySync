#!/usr/bin/env bash
# Step: Tap "Create record" to immediately create a wallet record.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)

# Ensure we can see the Create button
if ! echo "$xml" | grep -qi "Create record"; then
  scroll_down
  sleep 1
  xml=$(ui_dump_xml)
fi

if echo "$xml" | grep -qi "Create record"; then
  tap_desc "Create record"
  sleep 8
  echo "action=create_tapped"

  # Check result
  xml2=$(ui_dump_xml)
  if echo "$xml2" | grep -qi "Record created\|Success\|created"; then
    echo "result=success"
  elif echo "$xml2" | grep -qi "Error\|Failed"; then
    echo "result=error"
  else
    echo "result=unknown"
    echo "screen after create:"
    ui_elements
  fi
else
  echo "ERROR: Create record button not found"
  ui_elements
  exit 1
fi
