#!/usr/bin/env bash
# Step: Navigate to a specific tab.
# Usage: step_nav_tab.sh <tab_name>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

TAB="${1:-home}"
nav_tab "$TAB"
echo "navigated_to=$TAB"
