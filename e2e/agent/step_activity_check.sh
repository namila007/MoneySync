#!/usr/bin/env bash
# Step: Check activity log entries.
# Uses nav_tab instead of raw coords.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

nav_tab activity
sleep 3

xml=$(ui_dump_xml)
echo "=== ACTIVITY LOG ==="

if echo "$xml" | grep -qi "No activity here yet"; then
  echo "status=empty"
else
  echo "status=has_entries"
  echo "$xml" | grep -oE 'content-desc="[^"]*"' | sed 's/content-desc="//;s/"//' | \
    grep -v "Tab\|Settings\|Filter\|All\|Created\|Review\|Errors" | head -10
fi
echo "=== END ==="
