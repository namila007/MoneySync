#!/usr/bin/env bash
# Step: Get home dashboard counts.
# Uses nav_tab instead of raw coords.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

nav_tab home
sleep 2

echo "=== HOME COUNTS ==="
home_counts_json
echo "=== END ==="
