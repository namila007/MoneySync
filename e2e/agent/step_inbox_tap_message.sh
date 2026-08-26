#!/usr/bin/env bash
# Step: Tap a message in the inbox to open its detail/review page.
# Usage: step_inbox_tap_message.sh [search_text]
# search_text: partial text to match in content-desc (e.g. account number, bank name)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SEARCH="${1:-}"

xml=$(ui_dump_xml)

if [ -n "$SEARCH" ]; then
  # Try to find and tap element containing search text
  if tap_desc "$SEARCH"; then
    sleep 3
    echo "action=tapped_message"
    echo "search=$SEARCH"
  else
    # Try scrolling to find it
    for i in 1 2 3; do
      scroll_down
      sleep 1
      if tap_desc "$SEARCH"; then
        sleep 3
        echo "action=tapped_message_after_scroll"
        echo "search=$SEARCH"
        exit 0
      fi
    done
    echo "ERROR: Message matching '$SEARCH' not found"
    echo "available elements:"
    ui_elements
    exit 1
  fi
else
  # Tap the first message (first item after the filter bar)
  # Messages are typically in a ListView, tap the first one
  local first_msg
  first_msg=$(echo "$xml" | grep -oE 'content-desc="[^"]*"' | sed 's/content-desc="//;s/"//' | grep -v "Tab\|Settings\|Scan\|Home\|Inbox\|Mappings\|Activity\|Add\|Toggle\|All senders" | head -1)
  if [ -n "$first_msg" ]; then
    tap_desc "$first_msg"
    sleep 3
    echo "action=tapped_first_message"
    echo "message=$first_msg"
  else
    echo "ERROR: No messages in inbox"
    exit 1
  fi
fi

# Show what screen we're on now
xml2=$(ui_dump_xml)
echo "--- current screen ---"
if echo "$xml2" | grep -qi "Review transaction"; then
  echo "screen=review_panel"
elif echo "$xml2" | grep -qi "Message"; then
  echo "screen=inbox_detail"
else
  echo "screen=unknown"
fi
ui_elements
