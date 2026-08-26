#!/usr/bin/env bash
# Step: Tap "Finish" on the SMS access decision step (last onboarding step).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)
if ! echo "$xml" | grep -qi "Message reading is\|Paste or share\|Not in this build\|Checking"; then
  echo "ERROR: Not on SMS decision step"
  echo "current elements:"
  ui_elements
  exit 1
fi

tap_desc "Finish"
sleep 3

# Check where we ended up
xml2=$(ui_dump_xml)
if echo "$xml2" | grep -qi "Setup complete"; then
  echo "action=onboarding_complete"
  echo "screen=onboarding_review"
elif echo "$xml2" | grep -qi "Home"; then
  echo "action=onboarding_complete"
  echo "screen=home"
else
  echo "action=finished"
  echo "screen:"
  ui_elements
fi
