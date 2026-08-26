#!/usr/bin/env bash
# Run all E2E flows sequentially.
# Usage: ./run_all.sh [flow_name]
#   flow_name: onboarding|wallet|import|create_now|save_for_later|negative|all (default: all)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

FLOW="${1:-all}"

run_flow() {
  local name="$1"
  local script="$SCRIPT_DIR/flow_${name}.sh"
  if [ -f "$script" ]; then
    echo ""
    echo "=========================================="
    echo " Running: $name"
    echo "=========================================="
    bash "$script"
    echo ""
  else
    echo "Script not found: $script" >&2
  fi
}

case "$FLOW" in
  onboarding)     run_flow onboarding ;;
  wallet)         run_flow wallet_setup ;;
  import)         run_flow import_message ;;
  create_now)     run_flow create_now_agent ;;
  save_for_later) run_flow save_for_later_agent ;;
  negative)       run_flow negative ;;
  all)
    run_flow onboarding
    run_flow wallet_setup
    run_flow import_message
    run_flow create_now_agent
    run_flow save_for_later_agent
    run_flow negative
    ;;
  *) echo "Usage: $0 [onboarding|wallet|import|create_now|save_for_later|negative|all]" >&2; exit 1 ;;
esac

echo ""
echo "=========================================="
echo " All flows complete."
echo "=========================================="
