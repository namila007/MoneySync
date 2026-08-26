#!/usr/bin/env bash
# Step: Select an option from a dropdown/picker.
# Usage: step_select_dropdown.sh <dropdown_name> <option>
# Examples:
#   step_select_dropdown.sh kind income
#   step_select_dropdown.sh direction credit
#   step_select_dropdown.sh category "Food & Drinks"
#   step_select_dropdown.sh payment_type Cash
#   step_select_dropdown.sh wallet_account HNB
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

DROPDOWN="${1:-}"
OPTION="${2:-}"

if [ -z "$DROPDOWN" ] || [ -z "$OPTION" ]; then
  echo "Usage: step_select_dropdown.sh <dropdown_name> <option>"
  echo "Dropdowns: kind, direction, payment_type, wallet_account, category, date"
  exit 1
fi

xml=$(ui_dump_xml)

case "$DROPDOWN" in
  kind|direction|payment_type|wallet_account|category|date)
    # Find the dropdown trigger bounds — content-desc uses &#10; (HTML newline)
    case "$DROPDOWN" in
      kind)         pattern="Kind&#10;" ;;
      direction)    pattern="Direction&#10;" ;;
      payment_type) pattern="Payment type&#10;" ;;
      wallet_account) pattern="Wallet account&#10;" ;;
      category)     pattern="Uncategorized\|Category" ;;
      date)         pattern="Select date" ;;
    esac

    # Try to find and tap the dropdown — content-desc uses literal \n
    bounds=""
    if [ "$DROPDOWN" = "category" ]; then
      bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Uncategorized"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
    elif [ "$DROPDOWN" = "date" ]; then
      bounds=$(echo "$xml" | grep -oE '<node[^>]*content-desc="Select date[^"]*"[^>]*bounds="[^"]*"' | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//')
    else
      # Match content-desc like "Kind\nexpense" where \n is literal
      bounds=$(echo "$xml" | grep -oE "<node[^>]*content-desc=\"${pattern}[^\"]*\"[^>]*bounds=\"[^\"]*\"" | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//' | head -1)
    fi

    if [ -z "$bounds" ]; then
      echo "ERROR: Dropdown '$DROPDOWN' not found on screen"
      echo "Screen elements:"
      ui_elements
      exit 1
    fi

    # Tap the dropdown to open it
    cx=$(center_of "$bounds" | cut -d' ' -f1)
    cy=$(center_of "$bounds" | cut -d' ' -f2)
    echo "action=open_dropdown"
    echo "dropdown=$DROPDOWN"
    tap "$cx" "$cy"
    sleep 2

    # Now find and tap the option — scroll if needed for wallet_account
    opt_bounds=""
    max_scrolls=5

    for attempt in $(seq 1 $max_scrolls); do
      xml2=$(ui_dump_xml)
      opt_bounds=$(echo "$xml2" | grep -oE "<node[^>]*content-desc=\"${OPTION}\"[^>]*bounds=\"[^\"]*\"" | grep -oE 'bounds="[^"]*"' | sed 's/bounds="//;s/"//' | head -1)

      if [ -n "$opt_bounds" ]; then
        break
      fi

      # Scroll down and try again
      if [ "$DROPDOWN" = "wallet_account" ] || [ "$DROPDOWN" = "category" ]; then
        echo "  scroll_attempt=$attempt"
        scroll_down
        sleep 1
      else
        break
      fi
    done

    if [ -n "$opt_bounds" ]; then
      ox=$(center_of "$opt_bounds" | cut -d' ' -f1)
      oy=$(center_of "$opt_bounds" | cut -d' ' -f2)
      echo "action=select_option"
      echo "option=$OPTION"
      tap "$ox" "$oy"
      sleep 2
      echo "status=selected"
      echo "dropdown=$DROPDOWN"
      echo "value=$OPTION"
    else
      echo "ERROR: Option '$OPTION' not found in dropdown '$DROPDOWN' after $max_scrolls scrolls"
      echo "Available options:"
      echo "$xml2" | grep -oE 'content-desc="[^"]+"' | sed 's/content-desc="//;s/"//' | \
        grep -v "Tab\|Settings\|Scrim\|Dismiss\|Collapsed\|Expanded\|Primary\|Back\|Message\|Review\|Delete" | head -20
      exit 1
    fi
    ;;
  *)
    echo "ERROR: Unknown dropdown '$DROPDOWN'"
    echo "Available: kind, direction, payment_type, wallet_account, category, date"
    exit 1
    ;;
esac
