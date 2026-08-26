#!/usr/bin/env bash
# Step: Tap "Next" on current onboarding step.
# Works for: Welcome, Privacy, Source SMS, Device Protection, Permission Education, Disclosure.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)
# Determine which step we're on from visible text
step="unknown"
echo "$xml" | grep -qi "Welcome to MoneySync" && step="welcome"
echo "$xml" | grep -qi "Your data stays on your device" && step="privacy"
echo "$xml" | grep -qi "reads SMS but never changes" && step="source_sms"
echo "$xml" | grep -qi "Protect your financial data" && step="device_protection"
echo "$xml" | grep -qi "About permissions" && step="permission_education"
echo "$xml" | grep -qi "Privacy disclosure" && step="disclosure"
echo "$xml" | grep -qi "Reading your bank messages" && step="sms_disclosure"
echo "$xml" | grep -qi "Message reading is" && step="sms_decision"
echo "$xml" | grep -qi "Paste or share to import" && step="sms_decision"

echo "current_step=$step"

# Tap Next/Forward button
if echo "$xml" | grep -qi "Accept & finish"; then
  tap_desc "Accept & finish"
  echo "action=tap_finish"
elif echo "$xml" | grep -qi "Next"; then
  tap_desc "Next"
  echo "action=tap_next"
else
  echo "action=no_next_button_found"
  echo "elements:"
  ui_elements
fi
sleep 2
