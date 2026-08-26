#!/usr/bin/env bash
# Step: Navigate back to home from any screen.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

for _ in 1 2 3 4; do
  if ui_dump_xml 2>/dev/null | grep -qi "Home.*Tab"; then
    echo "screen=home"
    exit 0
  fi
  go_back
  sleep 1
done

nav_tab home
echo "screen=home"
