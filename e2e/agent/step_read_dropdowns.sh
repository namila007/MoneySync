#!/usr/bin/env bash
# Step: Read all dropdown/picker widgets on current screen.
# Returns structured info: which dropdowns exist, their current value,
# bounds, and available options (if a picker is open).
# Usage: step_read_dropdowns.sh [open_picker_name]
# If open_picker_name is given, also reads options inside that picker.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OPEN_PICKER="${1:-}"

xml=$(ui_dump_xml)

echo "=== DROPDOWNS ==="

# --- Detect open picker/dialog first ---
if echo "$xml" | grep -qi "Select category\|Select.*picker\|DropdownMenu\|Scrim"; then
  echo "picker_open=true"
  echo "picker_type=$(echo "$xml" | grep -oE 'Select [A-Za-z ]+' | head -1)"

  # List all items inside the picker
  echo "--- picker_options ---"
  echo "$xml" | grep -oE 'content-desc="[^"]+"' | sed 's/content-desc="//;s/"//' | \
    grep -v "Tab\|Settings\|Scrim\|Dismiss\|Collapsed\|Expanded\|Primary nav" | \
    while read -r opt; do
      echo "option=$opt"
    done
  echo "--- end_options ---"
fi

# --- Detect dropdown triggers in the review form ---
# Common patterns: "Kind\nexpense", "Direction\ndebit", "Payment type\nDebit card", "Wallet account\nHNB"

echo "--- form_dropdowns ---"

# Kind dropdown — content-desc uses &#10; (HTML newline) e.g. "Kind&#10;expense"
kind_bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Kind&#10;[^"]*"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
kind_value=$(echo "$xml" | grep -oE 'content-desc="Kind&#10;[^"]*"' | sed 's/content-desc="Kind&#10;//;s/"//')
if [ -n "$kind_bounds" ]; then
  echo "dropdown=kind"
  echo "  current_value=$kind_value"
  echo "  bounds=$kind_bounds"
  cx=$(center_of "$kind_bounds" | cut -d' ' -f1)
  cy=$(center_of "$kind_bounds" | cut -d' ' -f2)
  echo "  center=$cx,$cy"
  echo "  options=expense|income|transfer|refund"
  echo "  hint=credited_sms=income, debited_sms=expense"
fi

# Direction dropdown
dir_bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Direction&#10;[^"]*"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
dir_value=$(echo "$xml" | grep -oE 'content-desc="Direction&#10;[^"]*"' | sed 's/content-desc="Direction&#10;//;s/"//')
if [ -n "$dir_bounds" ]; then
  echo "dropdown=direction"
  echo "  current_value=$dir_value"
  echo "  bounds=$dir_bounds"
  cx=$(center_of "$dir_bounds" | cut -d' ' -f1)
  cy=$(center_of "$dir_bounds" | cut -d' ' -f2)
  echo "  center=$cx,$cy"
  echo "  options=debit|credit|neutral"
  echo "  hint=credited_sms=credit, debited_sms=debit"
fi

# Payment type dropdown
pt_bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Payment type&#10;[^"]*"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
pt_value=$(echo "$xml" | grep -oE 'content-desc="Payment type&#10;[^"]*"' | sed 's/content-desc="Payment type&#10;//;s/"//')
if [ -n "$pt_bounds" ]; then
  echo "dropdown=payment_type"
  echo "  current_value=$pt_value"
  echo "  bounds=$pt_bounds"
  cx=$(center_of "$pt_bounds" | cut -d' ' -f1)
  cy=$(center_of "$pt_bounds" | cut -d' ' -f2)
  echo "  center=$cx,$cy"
  echo "  options=Cash|Debit card|Credit card|Transfer"
fi

# Wallet account
wa_bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Wallet account&#10;[^"]*"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
wa_value=$(echo "$xml" | grep -oE 'content-desc="Wallet account&#10;[^"]*"' | sed 's/content-desc="Wallet account&#10;//;s/"//')
if [ -n "$wa_bounds" ]; then
  echo "dropdown=wallet_account"
  echo "  current_value=$wa_value"
  echo "  bounds=$wa_bounds"
  cx=$(center_of "$wa_bounds" | cut -d' ' -f1)
  cy=$(center_of "$wa_bounds" | cut -d' ' -f2)
  echo "  center=$cx,$cy"
  echo "  hint=must be TEST_ACCOUNT"
fi

# Category
cat_text=$(echo "$xml" | grep -oE 'content-desc="[^"]*Uncategorized[^"]*"' | head -1)
cat_bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Uncategorized"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
# Also check for named categories
if [ -z "$cat_bounds" ]; then
  cat_bounds=$(echo "$xml" | grep -oE '<node[^>]*hint="Category"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
fi
if [ -n "$cat_bounds" ]; then
  echo "dropdown=category"
  echo "  current_value=$(echo "$cat_text" | sed 's/content-desc="//;s/"//' || echo 'Uncategorized')"
  echo "  bounds=$cat_bounds"
  cx=$(center_of "$cat_bounds" | cut -d' ' -f1)
  cy=$(center_of "$cat_bounds" | cut -d' ' -f2)
  echo "  center=$cx,$cy"
  echo "  hint=must be selected"
fi

# Date
date_bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Select date[^"]*"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
if [ -n "$date_bounds" ]; then
  echo "dropdown=date"
  echo "  current_value=$(echo "$xml" | grep -oE 'content-desc="Select date[^"]*"' | sed 's/content-desc="//;s/"//')"
  echo "  bounds=$date_bounds"
  cx=$(center_of "$date_bounds" | cut -d' ' -f1)
  cy=$(center_of "$date_bounds" | cut -d' ' -f2)
  echo "  center=$cx,$cy"
  echo "  hint=must pick a date"
fi

echo "--- end_dropdowns ---"

# --- Text input fields ---
echo "--- text_inputs ---"
echo "$xml" | grep -oE '<node[^>]*class="android.widget.EditText"[^>]*>' | while read -r node; do
  hint=$(echo "$node" | grep -oE 'hint="[^"]*"' | sed 's/hint="//;s/"//')
  text=$(echo "$node" | grep -oE 'text="[^"]*"' | sed 's/text="//;s/"//')
  bounds=$(echo "$node" | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
  focused=$(echo "$node" | grep -oE 'focused="[^"]*"' | sed 's/focused="//;s/"//')
  if [ -n "$hint" ]; then
    echo "input=$hint"
    echo "  text=$text"
    echo "  bounds=$bounds"
    cx=$(center_of "$bounds" | cut -d' ' -f1)
    cy=$(center_of "$bounds" | cut -d' ' -f2)
    echo "  center=$cx,$cy"
    echo "  focused=$focused"
  fi
done
echo "--- end_inputs ---"

echo "=== END ==="
