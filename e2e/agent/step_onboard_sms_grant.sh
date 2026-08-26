#!/usr/bin/env bash
# Step: On the SMS disclosure screen, tap "Continue" to grant SMS access.
# This records consent and triggers the system permission dialog.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)
if ! echo "$xml" | grep -qi "Reading your bank messages"; then
  echo "ERROR: Not on SMS disclosure screen"
  echo "current elements:"
  ui_elements
  exit 1
fi

tap_desc "Continue"
sleep 2

# Check if system permission dialog appeared
xml2=$(ui_dump_xml)
if echo "$xml2" | grep -qi "Allow.*READ_SMS\|Allow.*SMS\|Allow.*messages"; then
  echo "system_dialog=permission_prompt"
  # Grant via adb for emulator
  grant_sms_permission
  sleep 1
  # Dismiss dialog - tap Allow if still showing
  xml3=$(ui_dump_xml)
  if echo "$xml3" | grep -qi "Allow"; then
    tap_desc "Allow"
    sleep 2
  fi
  echo "action=granted_via_adb"
elif echo "$xml2" | grep -qi "Message reading is"; then
  echo "action=moved_to_decision_step"
else
  echo "action=continued"
  echo "new elements:"
  ui_elements
fi
