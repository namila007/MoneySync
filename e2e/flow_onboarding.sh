#!/usr/bin/env bash
# Orchestrator: Complete onboarding flow.
# Launches app → taps through all steps → grants SMS → finishes → reaches home.
# Usage: bash e2e/flow_onboarding.sh [sms_grant|sms_skip]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$SCRIPT_DIR/agent"

SMS_MODE="${1:-sms_grant}"

echo "=========================================="
echo " Flow: Complete Onboarding ($SMS_MODE)"
echo "=========================================="

# Step 1: Launch app
echo ""
echo "[1/6] Launching app..."
bash "$AGENT/step_app_launch.sh"

# Step 2-7: Tap through onboarding steps
# Welcome -> Privacy -> Source SMS -> Device Protection -> Permission Education -> Disclosure
for i in 1 2 3 4 5 6; do
  echo ""
  echo "[$((i+1))/6] Tapping Next on step $i..."
  bash "$AGENT/step_onboard_next.sh"
  sleep 1
done

# Step 8: SMS disclosure
echo ""
echo "[8/6] SMS disclosure..."
if [ "$SMS_MODE" = "sms_grant" ]; then
  echo "Granting SMS access..."
  bash "$AGENT/step_onboard_sms_grant.sh"
else
  echo "Skipping SMS access..."
  # Tap "Not now — I'll paste manually"
  bash "$AGENT/step_onboard_next.sh"
fi

# Step 9: SMS decision -> Finish
echo ""
echo "[9/6] Finishing onboarding..."
bash "$AGENT/step_onboard_finish.sh"

# Step 10: Dismiss review if shown
echo ""
echo "[10/6] Navigating to home..."
bash "$AGENT/step_onboard_dismiss_review.sh"

# Verify final state
echo ""
echo "=========================================="
echo " Onboarding Complete - Final State"
echo "=========================================="
bash "$AGENT/step_home_counts.sh"
bash "$AGENT/step_log_check.sh" "onboarding" "SMS"
