#!/usr/bin/env bash
# Step: Read app info log (last 30 lines).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "=== INFO LOG ==="
log_info | tail -30
echo "=== END ==="
