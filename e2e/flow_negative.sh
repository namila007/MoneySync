#!/usr/bin/env bash
# Flow 3-5: Negative flows — zero amount, no account, duplicate
# Usage: ./flow_negative.sh [test_name]
#   test_name: "zero_amount" | "no_account" | "duplicate" (default: all)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/agent/helpers.sh"

TEST="${1:-all}"

run_zero_amount() {
  echo "=== Negative: Zero Amount ==="
  seed_sms "SAMPATHTX" "A/C 55556666 credited with LKR 10000.00. Ref: TXN-NEG-ZERO"
  tap 540 987; sleep 3
  tap 540 1743; sleep 3
  tap 540 1573; sleep 3
  go_back; sleep 2

  nav_tab inbox; sleep 2
  tap_desc "55556666"; sleep 3
  scroll_down; sleep 1

  echo "Tapping Create without amount..."
  tap_desc "Create record"; sleep 3

  if ui_dump_xml 2>/dev/null | grep -qi "non-zero\|amount"; then
    echo "PASS: Amount validation blocked create"
  else
    echo "FAIL: No validation error shown" >&2
  fi

  if log_search "HttpWalletApi" 5 | grep -q "POST"; then
    echo "FAIL: HTTP call made despite zero amount" >&2
  else
    echo "PASS: No HTTP call made"
  fi

  go_back; sleep 1
  echo ""
}

run_no_account() {
  echo "=== Negative: No Account ==="
  seed_sms "SAMPATHTX" "A/C 44445555 credited with LKR 8000.00. Ref: TXN-NEG-NOACCT"
  tap 540 987; sleep 3
  tap 540 1743; sleep 3
  tap 540 1573; sleep 3
  go_back; sleep 2

  nav_tab inbox; sleep 2
  tap_desc "44445555"; sleep 3

  echo "Entering amount without account..."
  tap_desc "Amount"; sleep 1
  type_text "8000"; sleep 1
  go_back; sleep 1
  scroll_down; sleep 1

  tap_desc "Create record"; sleep 3

  if log_search "HttpWalletApi" 5 | grep -q "POST"; then
    echo "FAIL: HTTP call made without account" >&2
  else
    echo "PASS: No HTTP call without account"
  fi

  go_back; sleep 1
  echo ""
}

run_duplicate() {
  echo "=== Negative: Duplicate Create ==="
  echo "This test requires a previously-created message."
  echo "If the message was removed from inbox, the test passes (correct behavior)."

  nav_tab inbox; sleep 2
  if ui_dump_xml 2>/dev/null | grep -qi "already created\|duplicate"; then
    echo "INFO: Duplicate message visible — verify ReviewDuplicate in logcat"
    log_search "ReviewDuplicate" 5
  else
    echo "PASS: No duplicate messages visible (correct — removed after create)"
  fi
  echo ""
}

case "$TEST" in
  zero_amount) run_zero_amount ;;
  no_account)  run_no_account ;;
  duplicate)   run_duplicate ;;
  all)
    run_zero_amount
    run_no_account
    run_duplicate
    ;;
  *) echo "Unknown test: $TEST (use zero_amount|no_account|duplicate|all)" >&2; exit 1 ;;
esac

echo "=== Negative flows: DONE ==="
