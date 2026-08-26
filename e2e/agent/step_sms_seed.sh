#!/usr/bin/env bash
# Step: Seed a bank SMS on the emulator.
# Usage: step_sms_seed.sh [sender] [body]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SENDER="${1:-SAMPATHTX}"
BODY="${2:-A/C 77778888 credited with LKR 40000.00 on 2026/08/26. Bal LKR 110000.00. Ref: TXN-E2E-$(date +%s)}"

seed_sms "$SENDER" "$BODY"
echo "sender=$SENDER"
echo "body=$BODY"
