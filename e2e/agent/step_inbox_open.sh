#!/usr/bin/env bash
# Step: Open Inbox and list available messages.
# Uses nav_tab instead of raw coords.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

nav_tab inbox
sleep 3

xml=$(ui_dump_xml)
if echo "$xml" | grep -qi "No transaction candidates"; then
  echo "inbox_status=empty"
  echo "count=0"
  exit 0
fi

echo "screen=inbox"
local count
count=$(echo "$xml" | grep -oE 'content-desc="[^"]*"' | grep -v "Tab\|Settings\|Scan\|Home\|Inbox\|Mappings\|Activity" | wc -l | tr -d ' ')
echo "message_count=$count"

echo "--- message identifiers ---"
echo "$xml" | grep -oE 'content-desc="[^"]*"' | sed 's/content-desc="//;s/"//' | \
  grep -v "Tab\|Settings\|Scan\|Home\|Inbox\|Mappings\|Activity\|Add\|Toggle" | head -10
echo "--- end ---"
