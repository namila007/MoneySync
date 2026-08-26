#!/usr/bin/env bash
# Step: Launch app and check if onboarding is showing.
# Output: screen state with onboarding detection.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

preflight > /dev/null
launch > /dev/null

xml=$(ui_dump_xml)
echo "=== APP STATE ==="
if echo "$xml" | grep -qi "Welcome to MoneySync"; then
  echo "screen=onboarding"
  echo "step=welcome"
elif echo "$xml" | grep -qi "Setup complete"; then
  echo "screen=onboarding_review"
  echo "step=complete"
elif echo "$xml" | grep -qi "Unlock MoneySync"; then
  echo "screen=lock"
elif echo "$xml" | grep -qi "Home"; then
  echo "screen=home"
else
  echo "screen=unknown"
fi
echo "--- elements ---"
ui_elements
echo "=== END ==="
