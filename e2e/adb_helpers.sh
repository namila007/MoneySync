#!/usr/bin/env bash
# Common ADB helpers for MoneySync E2E tests.
# Source this file: source "$(dirname "$0")/adb_helpers.sh"

PKG="me.namila.money_sync.privatefull"
ACTIVITY="$PKG/me.namila.money_sync.MainActivity"
APP_ID="me.namila.money_sync.privatefull"

# --- Preflight -----------------------------------------------------------

preflight() {
  local devices
  devices=$(adb devices 2>/dev/null | grep -w "device" | head -1)
  if [ -z "$devices" ]; then
    echo "ERROR: No device attached. Start emulator from Android Studio." >&2
    exit 1
  fi
  echo "Device: $devices"
}

# --- Build & Install -----------------------------------------------------

build_and_install() {
  local flavor="${1:-privateFull}"
  local target="${2:-lib/main_private_full.dart}"
  echo "Building $flavor..."
  flutter build apk --debug --flavor "$flavor" --target "$target" 2>&1 | tail -3
  local apk="build/app/outputs/flutter-apk/app-${flavor,,}-debug.apk"
  if [ ! -f "$apk" ]; then
    echo "ERROR: APK not found at $apk" >&2
    exit 1
  fi
  adb install -r "$apk"
  echo "Installed: $apk"
}

launch() {
  adb shell am force-stop "$PKG" 2>/dev/null
  sleep 1
  adb shell am start -n "$ACTIVITY" 2>&1
  sleep 4
  echo "App launched."
}

# --- UI Interaction ------------------------------------------------------

# Dump UI and extract content-desc values
dump_ui() {
  adb exec-out uiautomator dump /dev/tty 2>/dev/null \
    | grep -oE 'content-desc="[^"]+"' | sort -u
}

# Find bounds for a content-desc match
find_bounds() {
  local desc="$1"
  adb exec-out uiautomator dump /dev/tty 2>/dev/null \
    | grep -oE "<node[^>]*content-desc=\"[^\"]*${desc}[^\"]*\"[^>]*>" \
    | grep -oE 'bounds="[^"]*"' | head -1
}

# Parse bounds string "[x1,y1][x2,y2]" and return center x,y
center_of() {
  local bounds="$1"
  local x1 y1 x2 y2
  x1=$(echo "$bounds" | grep -oE '\[(\d+),' | head -1 | tr -dc '0-9')
  y1=$(echo "$bounds" | grep -oE ',(\d+)\]' | head -1 | tr -dc '0-9')
  x2=$(echo "$bounds" | grep -oE '\[(\d+),' | tail -1 | tr -dc '0-9')
  y2=$(echo "$bounds" | grep -oE ',(\d+)\]' | tail -1 | tr -dc '0-9')
  echo "$(( (x1 + x2) / 2 )) $(( (y1 + y2) / 2 ))"
}

# Tap center of a content-desc element
tap_desc() {
  local desc="$1"
  local bounds
  bounds=$(find_bounds "$desc")
  if [ -z "$bounds" ]; then
    echo "WARN:元素未找到: $desc" >&2
    return 1
  fi
  local cx cy
  cx=$(center_of "$bounds" | cut -d' ' -f1)
  cy=$(center_of "$bounds" | cut -d' ' -f2)
  echo "Tap '$desc' at ($cx, $cy)"
  adb shell input tap "$cx" "$cy"
}

# Tap at absolute coordinates
tap() {
  echo "Tap ($1, $2)"
  adb shell input tap "$1" "$2"
}

# Scroll down (swipe up)
scroll_down() {
  adb shell input swipe 540 1800 540 600 500
  sleep 1
}

# Scroll up (swipe down)
scroll_up() {
  adb shell input swipe 540 600 540 1800 500
  sleep 1
}

# Press back
go_back() {
  adb shell input keyevent 4
  sleep 1
}

# Type text into focused field
type_text() {
  adb shell input text "$1"
}

# Clear focused field (6x backspace)
clear_field() {
  for _ in 1 2 3 4 5 6; do
    adb shell input keyevent 67
  done
  sleep 0.3
}

# --- Account Selection ---------------------------------------------------

TEST_ACCOUNT_NAME="${TEST_ACCOUNT_NAME:-HNB}"

# Select TEST_ACCOUNT from the account picker bottom sheet
select_test_account() {
  local name="$TEST_ACCOUNT_NAME"
  echo "Selecting TEST_ACCOUNT: $name"
  if tap_desc "$name"; then
    sleep 2
    echo "Selected: $name"
  else
    echo "ERROR: TEST_ACCOUNT '$name' not found in picker" >&2
    echo "Available accounts:" >&2
    dump_ui | grep -E "content-desc=\"[A-Z]" | head -10 >&2
    return 1
  fi
}

# --- SMS -----------------------------------------------------------------

seed_sms() {
  local sender="$1"
  local body="$2"
  echo "Seeding SMS from $sender..."
  adb emu sms send "$sender" "$body"
  sleep 2
}

# --- Logging -------------------------------------------------------------

check_log() {
  local pattern="$1"
  adb logcat -d -s flutter 2>/dev/null | grep -i "$pattern" | tail -5
}

check_error_log() {
  adb exec-out run-as "$PKG" sh -c "cat code_cache/logs/app/error.log 2>/dev/null" || echo "(no error log)"
}

# --- Evidence ------------------------------------------------------------

dump_to_file() {
  local filepath="$1"
  adb exec-out uiautomator dump /dev/tty 2>/dev/null > "$filepath"
  echo "Dumped UI to $filepath"
}

logcat_to_file() {
  local filepath="$1"
  adb logcat -d > "$filepath"
  echo "Logcat saved to $filepath"
}

# --- State Check ---------------------------------------------------------

get_home_counts() {
  dump_ui | grep -oE 'content-desc="[0-9]+\\n(Review|Retry|Waiting|Success)"' \
    | sed 's/content-desc="//;s/"//;s/\\n/ /'
}

assert_count() {
  local tile="$1"
  local expected="$2"
  local actual
  actual=$(get_home_counts | grep "$tile" | awk '{print $1}')
  if [ "$actual" = "$expected" ]; then
    echo "PASS: $tile = $actual (expected $expected)"
  else
    echo "FAIL: $tile = $actual (expected $expected)" >&2
    return 1
  fi
}
