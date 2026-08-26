#!/usr/bin/env bash
# Step: Dismiss onboarding review / navigate to home.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

xml=$(ui_dump_xml)
if echo "$xml" | grep -qi "Setup complete"; then
  go_back
  sleep 2
fi

nav_tab home
echo "screen=home"
