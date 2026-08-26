#!/usr/bin/env bash
# Step: Dump full screen state for agent inspection.
# Returns all content-desc and text elements, plus screen detection.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)
echo "=== FULL SCREEN DUMP ==="
echo "--- screen detection ---"
echo "$xml" | grep -qi "Welcome to MoneySync" && echo "onboarding=welcome"
echo "$xml" | grep -qi "Your data stays" && echo "onboarding=privacy"
echo "$xml" | grep -qi "reads SMS but never" && echo "onboarding=source_sms"
echo "$xml" | grep -qi "Protect your financial" && echo "onboarding=device_protection"
echo "$xml" | grep -qi "About permissions" && echo "onboarding=permission_education"
echo "$xml" | grep -qi "Privacy disclosure" && echo "onboarding=disclosure"
echo "$xml" | grep -qi "Reading your bank messages" && echo "onboarding=sms_disclosure"
echo "$xml" | grep -qi "Message reading is" && echo "onboarding=sms_decision"
echo "$xml" | grep -qi "Setup complete" && echo "onboarding=complete"
echo "$xml" | grep -qi "Unlock MoneySync" && echo "screen=lock"
echo "$xml" | grep -qi "Home.*Tab" && echo "screen=home"
echo "$xml" | grep -qi "Inbox.*Tab" && echo "screen=inbox"
echo "$xml" | grep -qi "Connect Wallet" && echo "screen=wallet_connect"
echo "$xml" | grep -qi "Review transaction" && echo "panel=review"
echo "$xml" | grep -qi "Tracked senders" && echo "screen=tracked_senders"
echo "$xml" | grep -qi "Import from messages" && echo "screen=history_import"

echo ""
echo "--- content descriptions ---"
ui_elements

echo ""
echo "--- text elements ---"
ui_texts

echo "=== END ==="
