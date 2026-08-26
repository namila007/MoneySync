#!/usr/bin/env bash
# Step: Check Flutter logs for specific patterns.
# Usage: step_log_check.sh [pattern1] [pattern2] ...
# Default patterns: ReviewSubmitted, HttpWalletApi, Created record, error
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

if [ $# -eq 0 ]; then
  set -- "ReviewSubmitted" "HttpWalletApi" "Created record" "ERROR" "Exception"
fi

echo "=== LOG CHECK ==="
for pattern in "$@"; do
  local matches
  matches=$(log_search "$pattern" 3)
  if [ -n "$matches" ]; then
    echo "pattern=$pattern"
    echo "found=true"
    echo "$matches"
  else
    echo "pattern=$pattern"
    echo "found=false"
  fi
  echo "---"
done
echo "=== END ==="
