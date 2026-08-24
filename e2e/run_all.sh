#!/usr/bin/env bash
# Run all E2E flows sequentially.
# Usage: ./run_all.sh [flow_number]
#   flow_number: 1-4 or "all" (default: all)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FLOW="${1:-all}"

run_flow() {
  local num="$1"
  local script="$SCRIPT_DIR/flow_${num}.sh"
  if [ ! -x "$script" ]; then
    script="$SCRIPT_DIR/$(ls "$SCRIPT_DIR"/flow_*.sh | sed "s|.*/||" | grep -E "^flow_${num}" | head -1)"
  fi
  if [ -f "$script" ]; then
    echo ""
    echo "=========================================="
    echo " Running: $(basename "$script")"
    echo "=========================================="
    bash "$script"
    echo ""
  else
    echo "Script not found for flow $num" >&2
  fi
}

case "$FLOW" in
  1) run_flow 1 ;;
  2) run_flow 2 ;;
  3) run_flow 3 ;;
  4) run_flow 4 ;;
  all)
    run_flow 1
    run_flow 2
    run_flow 3
    ;;
  *) echo "Usage: $0 [1|2|3|all]" >&2; exit 1 ;;
esac

echo ""
echo "=========================================="
echo " All flows complete."
echo "=========================================="
