#!/usr/bin/env bash
# Step: Read app error log.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "=== ERROR LOG ==="
local log
log=$(log_error)
if [ -z "$log" ] || [ "$log" = "(no error log)" ]; then
  echo "status=clean"
  echo "message=No errors logged"
else
  echo "status=has_errors"
  echo "$log"
fi
echo "=== END ==="
