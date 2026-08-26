#!/usr/bin/env bash
# Step: Tap "Save for later" to queue the record for later approval.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)

if ! echo "$xml" | grep -qi "Save for later"; then
  scroll_down
  sleep 1
  xml=$(ui_dump_xml)
fi

if echo "$xml" | grep -qi "Save for later"; then
  tap_desc "Save for later"
  sleep 5
  echo "action=save_for_later_tapped"

  xml2=$(ui_dump_xml)
  if echo "$xml2" | grep -qi "Saved\|Waiting\|queued"; then
    echo "result=queued"
  else
    echo "result=unknown"
    ui_elements
  fi
else
  echo "ERROR: Save for later button not found"
  ui_elements
  exit 1
fi
