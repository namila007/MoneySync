#!/usr/bin/env bash
# Step: Navigate to History Import and run a scan.
# Uses nav_tab settings + ensure_visible.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

nav_tab settings
sleep 2

if ! ensure_visible "History window"; then
  echo "ERROR: History window not found"
  ui_elements
  exit 1
fi

if tap_desc "History window"; then
  sleep 2
else
  echo "ERROR: Could not tap History window"
  ui_elements
  exit 1
fi

xml=$(ui_dump_xml)
if echo "$xml" | grep -qi "Import from messages\|Find messages"; then
  echo "screen=history_import"

  if echo "$xml" | grep -qi "Choose senders to track first"; then
    echo "status=no_tracked_senders"
    echo "action=needs_senders_first"
    exit 1
  fi

  if tap_desc "Find messages"; then
    sleep 8
    echo "action=scan_started"
    xml2=$(ui_dump_xml)
    if echo "$xml2" | grep -qi "Done"; then
      echo "action=scan_complete"
      tap_desc "Done"
      sleep 2
    elif echo "$xml2" | grep -qi "Stored"; then
      echo "action=scan_complete"
      echo "$xml2" | grep -oE 'Stored: [0-9]+' | head -1
      echo "$xml2" | grep -oE 'Not recognised: [0-9]+' | head -1
      echo "$xml2" | grep -oE 'Already imported: [0-9]+' | head -1
      tap_desc "Done"
      sleep 2
    fi
  else
    echo "ERROR: Find messages button not found"
    ui_elements
  fi
else
  echo "ERROR: Not on history import page"
  ui_elements
fi
