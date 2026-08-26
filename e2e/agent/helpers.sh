#!/usr/bin/env bash
# Agent-driven E2E helpers for MoneySync.
# Provides structured output so an AI agent can read state and decide actions.
# Source: source "$(dirname "$0")/helpers.sh"

PKG="me.namila.money_sync.privatefull"
ACTIVITY="$PKG/me.namila.money_sync.MainActivity"
APP_ID="me.namila.money_sync.privatefull"
TEST_ACCOUNT_NAME="${TEST_ACCOUNT_NAME:-TEST_ACCOUNT}"

# === Constants ============================================================

# Canonical tab coordinates (1080×2400 screen)
TAB_HOME_X=135;     TAB_HOME_Y=2232
TAB_INBOX_X=405;    TAB_INBOX_Y=2232
TAB_MAPPINGS_X=675; TAB_MAPPINGS_Y=2232
TAB_ACTIVITY_X=945; TAB_ACTIVITY_Y=2232
SETTINGS_GEAR_X=1017; SETTINGS_GEAR_Y=210

# === Device Preflight =====================================================

preflight() {
  local devices
  devices=$(adb devices 2>/dev/null | grep -w "device" | head -1)
  if [ -z "$devices" ]; then
    echo '{"status":"error","message":"No device attached. Start emulator from Android Studio."}'
    exit 1
  fi
  echo "{\"status\":\"ok\",\"device\":\"$devices\"}"
}

# === Build & Install ======================================================

build_and_install() {
  local flavor="${1:-privateFull}"
  local target="${2:-lib/main_private_full.dart}"
  echo "Building $flavor..."
  flutter build apk --debug --flavor "$flavor" --target "$target" 2>&1 | tail -3
  local apk="build/app/outputs/flutter-apk/app-${flavor,,}-debug.apk"
  if [ ! -f "$apk" ]; then
    echo '{"status":"error","message":"APK not found","path":"'"$apk"'"}'
    exit 1
  fi
  adb install -r "$apk"
  echo "{\"status\":\"ok\",\"installed\":\"$apk\"}"
}

launch() {
  adb shell am force-stop "$PKG" 2>/dev/null
  sleep 1
  adb shell am start -n "$ACTIVITY" 2>&1
  sleep 4
  echo '{"status":"ok","action":"launched"}'
}

# === UI State Reading =====================================================

ui_dump_xml() {
  adb exec-out uiautomator dump /dev/tty 2>/dev/null
}

ui_check() {
  local text="$1"
  local xml
  xml=$(ui_dump_xml)
  if echo "$xml" | grep -qi "$text"; then
    echo "{\"status\":\"ok\",\"found\":true,\"text\":\"$text\"}"
    return 0
  else
    echo "{\"status\":\"ok\",\"found\":false,\"text\":\"$text\"}"
    return 1
  fi
}

ui_elements() {
  local xml
  xml=$(ui_dump_xml)
  echo "$xml" | grep -oE 'content-desc="[^"]+"' | sort -u | sed 's/content-desc="//;s/"//'
}

ui_texts() {
  local xml
  xml=$(ui_dump_xml)
  echo "$xml" | grep -oE 'text="[^"]+"' | sort -u | sed 's/text="//;s/"//'
}

ui_state() {
  echo "=== SCREEN STATE ==="
  echo "--- Content descriptions ---"
  ui_elements
  echo "--- Text elements ---"
  ui_texts
  echo "=== END STATE ==="
}

wait_for() {
  local text="$1"
  local timeout="${2:-15}"
  local interval="${3:-2}"
  local elapsed=0
  while [ "$elapsed" -lt "$timeout" ]; do
    if ui_dump_xml 2>/dev/null | grep -qi "$text"; then
      echo "{\"status\":\"ok\",\"found\":true,\"text\":\"$text\",\"elapsed\":$elapsed}"
      return 0
    fi
    sleep "$interval"
    elapsed=$((elapsed + interval))
  done
  echo "{\"status\":\"timeout\",\"found\":false,\"text\":\"$text\",\"elapsed\":$elapsed}"
  return 1
}

# === Screen Detection =====================================================
# Returns which screen/onboarding step is showing.

detect_screen() {
  local xml
  xml=$(ui_dump_xml)
  # Onboarding steps
  echo "$xml" | grep -qi "Welcome to MoneySync"     && echo "onboarding=welcome"     && return 0
  echo "$xml" | grep -qi "Your data stays"           && echo "onboarding=privacy"     && return 0
  echo "$xml" | grep -qi "reads SMS but never"       && echo "onboarding=source_sms"  && return 0
  echo "$xml" | grep -qi "Protect your financial"    && echo "onboarding=device_protection" && return 0
  echo "$xml" | grep -qi "About permissions"         && echo "onboarding=permission_education" && return 0
  echo "$xml" | grep -qi "Privacy disclosure"        && echo "onboarding=disclosure"  && return 0
  echo "$xml" | grep -qi "Reading your bank messages" && echo "onboarding=sms_disclosure" && return 0
  echo "$xml" | grep -qi "Message reading is"        && echo "onboarding=sms_decision" && return 0
  echo "$xml" | grep -qi "Setup complete"            && echo "onboarding=complete"    && return 0
  # App screens
  echo "$xml" | grep -qi "Unlock MoneySync"          && echo "screen=lock"            && return 0
  echo "$xml" | grep -qi "Connect Wallet"            && echo "screen=wallet_connect"  && return 0
  echo "$xml" | grep -qi "Review transaction"        && echo "panel=review"           && return 0
  echo "$xml" | grep -qi "Home.*Tab"                 && echo "screen=home"            && return 0
  echo "$xml" | grep -qi "Inbox.*Tab"                && echo "screen=inbox"           && return 0
  echo "$xml" | grep -qi "Tracked senders"           && echo "screen=tracked_senders" && return 0
  echo "$xml" | grep -qi "Import from messages"      && echo "screen=history_import"  && return 0
  echo "screen=unknown"
}

# === UI Interaction =======================================================

find_bounds() {
  local desc="$1"
  adb exec-out uiautomator dump /dev/tty 2>/dev/null \
    | grep -oE "<node[^>]*content-desc=\"[^\"]*${desc}[^\"]*\"[^>]*>" \
    | grep -oE 'bounds="[^"]*"' | head -1
}

# Find bounds with scroll. Tries up to max_scrolls times.
find_bounds_with_scroll() {
  local desc="$1"
  local max="${2:-5}"
  local bounds=""
  for _ in $(seq 1 "$max"); do
    bounds=$(find_bounds "$desc")
    if [ -n "$bounds" ]; then
      echo "$bounds"
      return 0
    fi
    scroll_down
    sleep 1
  done
  return 1
}

center_of() {
  local bounds="$1"
  local x1 y1 x2 y2
  x1=$(echo "$bounds" | grep -oE '\[(\d+),' | head -1 | tr -dc '0-9')
  y1=$(echo "$bounds" | grep -oE ',(\d+)\]' | head -1 | tr -dc '0-9')
  x2=$(echo "$bounds" | grep -oE '\[(\d+),' | tail -1 | tr -dc '0-9')
  y2=$(echo "$bounds" | grep -oE ',(\d+)\]' | tail -1 | tr -dc '0-9')
  echo "$(( (x1 + x2) / 2 )) $(( (y1 + y2) / 2 ))"
}

# Tap center of a bounds string "[x1,y1][x2,y2]"
tap_bounds() {
  local bounds="$1"
  local cx cy
  cx=$(center_of "$bounds" | cut -d' ' -f1)
  cy=$(center_of "$bounds" | cut -d' ' -f2)
  adb shell input tap "$cx" "$cy"
  echo "{\"status\":\"ok\",\"action\":\"tap_bounds\",\"x\":$cx,\"y\":$cy}"
}

tap_desc() {
  local desc="$1"
  local bounds
  bounds=$(find_bounds "$desc")
  if [ -z "$bounds" ]; then
    echo "{\"status\":\"error\",\"action\":\"tap_desc\",\"element\":\"$desc\",\"message\":\"not found\"}"
    return 1
  fi
  tap_bounds "$bounds"
}

tap() {
  adb shell input tap "$1" "$2"
  echo "{\"status\":\"ok\",\"action\":\"tap\",\"x\":$1,\"y\":$2}"
}

scroll_down() {
  adb shell input swipe 540 1800 540 600 500
  sleep 1
}

scroll_up() {
  adb shell input swipe 540 600 540 1800 500
  sleep 1
}

go_back() {
  adb shell input keyevent 4
  sleep 1
}

type_text() {
  adb shell input text "$1"
}

clear_field() {
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    adb shell input keyevent 67
  done
  sleep 0.3
}

long_press() {
  adb shell input swipe "$1" "$2" "$1" "$2" 1000
}

# === Navigation ===========================================================
# Canonical tab navigation — all scripts should use these instead of raw coords.

nav_tab() {
  local tab="${1:-home}"
  case "$tab" in
    home)     tap "$TAB_HOME_X" "$TAB_HOME_Y" ;;
    inbox)    tap "$TAB_INBOX_X" "$TAB_INBOX_Y" ;;
    mappings) tap "$TAB_MAPPINGS_X" "$TAB_MAPPINGS_Y" ;;
    activity) tap "$TAB_ACTIVITY_X" "$TAB_ACTIVITY_Y" ;;
    settings) tap "$SETTINGS_GEAR_X" "$SETTINGS_GEAR_Y" ;;
    *) echo "{\"status\":\"error\",\"message\":\"unknown tab: $tab\"}"; return 1 ;;
  esac
  sleep 2
}

# Ensure an element is visible; if not found, scroll down up to max times.
ensure_visible() {
  local desc="$1"
  local max="${2:-5}"
  local xml
  xml=$(ui_dump_xml)
  if echo "$xml" | grep -qi "$desc"; then
    return 0
  fi
  for _ in $(seq 1 "$max"); do
    scroll_down
    sleep 1
    xml=$(ui_dump_xml)
    if echo "$xml" | grep -qi "$desc"; then
      return 0
    fi
  done
  return 1
}

# === Account Selection ====================================================
# TEST_ACCOUNT is typically below visible area — must scroll to find it.

select_test_account() {
  local name="${1:-$TEST_ACCOUNT_NAME}"
  local opt_bounds=""
  for _ in 1 2 3 4 5; do
    opt_bounds=$(find_bounds "$name" 2>/dev/null)
    if [ -n "$opt_bounds" ]; then
      break
    fi
    scroll_down
    sleep 1
  done

  if [ -n "$opt_bounds" ]; then
    tap_bounds "$opt_bounds"
    sleep 2
    echo "{\"status\":\"ok\",\"action\":\"select_account\",\"account\":\"$name\"}"
  else
    echo "{\"status\":\"error\",\"action\":\"select_account\",\"account\":\"$name\",\"message\":\"not found after 5 scrolls\"}"
    return 1
  fi
}

# Check if TEST_ACCOUNT exists in the wallet. Returns account list if missing.
check_test_account_exists() {
  local xml
  xml=$(ui_dump_xml)
  if echo "$xml" | grep -qi "$TEST_ACCOUNT_NAME"; then
    echo "{\"status\":\"ok\",\"account\":\"$TEST_ACCOUNT_NAME\",\"exists\":true}"
    return 0
  fi
  # Scroll to check below visible area
  for _ in 1 2 3 4 5; do
    scroll_down
    sleep 1
    xml=$(ui_dump_xml)
    if echo "$xml" | grep -qi "$TEST_ACCOUNT_NAME"; then
      echo "{\"status\":\"ok\",\"account\":\"$TEST_ACCOUNT_NAME\",\"exists\":true}"
      return 0
    fi
  done
  echo "{\"status\":\"error\",\"account\":\"$TEST_ACCOUNT_NAME\",\"exists\":false}"
  echo "Available accounts:"
  echo "$xml" | grep -oE 'content-desc="[^"]+"' | sed 's/content-desc="//;s/"//' | \
    grep -v "Tab\|Settings\|Dismiss\|Primary\|Back\|Activity\|Home\|Inbox\|Mappings\|Review\|Wallet" | sort
  return 1
}

# === SMS ==================================================================

seed_sms() {
  local sender="$1"
  local body="$2"
  adb emu sms send "$sender" "$body"
  sleep 2
  echo "{\"status\":\"ok\",\"action\":\"seed_sms\",\"sender\":\"$sender\"}"
}

# === Logging ==============================================================

log_flutter() {
  local lines="${1:-30}"
  adb logcat -d -s flutter 2>/dev/null | tail -"$lines"
}

log_search() {
  local pattern="$1"
  local lines="${2:-20}"
  adb logcat -d -s flutter 2>/dev/null | grep -i "$pattern" | tail -"$lines"
}

log_info() {
  adb exec-out run-as "$PKG" sh -c "cat code_cache/logs/app/info.log 2>/dev/null" || echo "(no info log)"
}

log_error() {
  adb exec-out run-as "$PKG" sh -c "cat code_cache/logs/app/error.log 2>/dev/null" || echo "(no error log)"
}

log_check() {
  local pattern="$1"
  local matches
  matches=$(log_search "$pattern" 5)
  if [ -n "$matches" ]; then
    echo "{\"status\":\"ok\",\"found\":true,\"pattern\":\"$pattern\",\"matches\":$(echo "$matches" | wc -l | tr -d ' ')}"
    echo "$matches"
  else
    echo "{\"status\":\"ok\",\"found\":false,\"pattern\":\"$pattern\",\"matches\":0}"
  fi
}

# === Home Counts ==========================================================
# Content-desc uses &#10; (HTML newline) e.g. "1&#10;Review"

get_home_counts() {
  local xml
  xml=$(ui_dump_xml)
  local review retry waiting success
  review=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Review"' | grep -oE '^[0-9]+' || echo "?")
  retry=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Retry"' | grep -oE '^[0-9]+' || echo "?")
  waiting=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Waiting"' | grep -oE '^[0-9]+' || echo "?")
  success=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Success"' | grep -oE '^[0-9]+' || echo "?")
  echo "review=$review retry=$retry waiting=$waiting success=$success"
}

home_counts_json() {
  local xml
  xml=$(ui_dump_xml)
  local review retry waiting success
  review=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Review"' | grep -oE '^[0-9]+' || echo "0")
  retry=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Retry"' | grep -oE '^[0-9]+' || echo "0")
  waiting=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Waiting"' | grep -oE '^[0-9]+' || echo "0")
  success=$(echo "$xml" | grep -oE 'content-desc="[0-9]+&#10;Success"' | grep -oE '^[0-9]+' || echo "0")
  echo "{\"review\":$review,\"retry\":$retry,\"waiting\":$waiting,\"success\":$success}"
}

assert_count() {
  local tile="$1"
  local expected="$2"
  local actual
  actual=$(get_home_counts | grep -oE "${tile}=[0-9]+" | cut -d= -f2)
  if [ "$actual" = "$expected" ]; then
    echo "{\"status\":\"pass\",\"assertion\":\"$tile == $expected\"}"
  else
    echo "{\"status\":\"fail\",\"assertion\":\"$tile == $expected\",\"actual\":\"$actual\"}"
    return 1
  fi
}

# === Evidence =============================================================

dump_to_file() {
  local filepath="$1"
  adb exec-out uiautomator dump /dev/tty 2>/dev/null > "$filepath"
  echo "{\"status\":\"ok\",\"action\":\"dump\",\"path\":\"$filepath\"}"
}

logcat_to_file() {
  local filepath="$1"
  adb logcat -d > "$filepath"
  echo "{\"status\":\"ok\",\"action\":\"logcat_save\",\"path\":\"$filepath\"}"
}

# === Permission Helpers ===================================================

grant_sms_permission() {
  adb shell pm grant "$PKG" android.permission.READ_SMS 2>/dev/null
  echo "{\"status\":\"ok\",\"action\":\"grant_sms_permission\"}"
}

revoke_sms_permission() {
  adb shell pm revoke "$PKG" android.permission.READ_SMS 2>/dev/null
  echo "{\"status\":\"ok\",\"action\":\"revoke_sms_permission\"}"
}

check_sms_permission() {
  local result
  result=$(adb shell dumpsys package "$PKG" 2>/dev/null | grep -A5 "runtime permissions" | grep "READ_SMS" || echo "not granted")
  echo "{\"status\":\"ok\",\"permission\":\"READ_SMS\",\"state\":\"$result\"}"
}

# === Wallet Status ========================================================

check_wallet_connected() {
  local xml
  xml=$(ui_dump_xml)
  if echo "$xml" | grep -qi "Connected"; then
    echo "{\"status\":\"ok\",\"wallet\":\"connected\"}"
    return 0
  elif echo "$xml" | grep -qi "Connect Wallet"; then
    echo "{\"status\":\"ok\",\"wallet\":\"disconnected\"}"
    return 1
  else
    echo "{\"status\":\"ok\",\"wallet\":\"unknown\"}"
    return 2
  fi
}
