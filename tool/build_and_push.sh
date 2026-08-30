#!/usr/bin/env bash
# Build a debug APK and install it on the one active adb device/emulator.
# Usage: tool/build_and_push.sh [privateFull|playManual]  (default: privateFull)

set -euo pipefail

cd "$(dirname "$0")/.."

flavor="${1:-privateFull}"
case "$flavor" in
  privateFull) target="lib/main_private_full.dart" ;;
  playManual)  target="lib/main_play_manual.dart" ;;
  *)
    echo "usage: $0 [privateFull|playManual]" >&2
    exit 64
    ;;
esac

devices="$(adb devices | grep -w "device" || true)"
device_count="$(printf '%s\n' "$devices" | grep -c . || true)"

if [[ "$device_count" -eq 0 ]]; then
  echo "No active adb device found. Start the emulator from Android Studio" \
    "(Device Manager -> the AVD's Play button) or connect and unlock a" \
    "physical device with USB debugging authorised, then retry." >&2
  exit 1
fi

if [[ "$device_count" -gt 1 ]]; then
  echo "Multiple active adb devices found; specify one with -s <serial>:" >&2
  printf '%s\n' "$devices" >&2
  exit 1
fi

serial="$(printf '%s\n' "$devices" | cut -f1)"
echo "Target device: ${serial}"

echo "Building ${flavor} (${target})..."
flutter build apk --debug --flavor "$flavor" --target "$target"

apk_flavor_lower="$(printf '%s' "$flavor" | tr '[:upper:]' '[:lower:]')"
apk="build/app/outputs/flutter-apk/app-${apk_flavor_lower}-debug.apk"
if [[ ! -f "$apk" ]]; then
  echo "Built APK not found at expected path: ${apk}" >&2
  exit 1
fi

echo "Installing ${apk} on ${serial}..."
adb -s "$serial" install -r "$apk"

echo "Done: ${flavor} installed on ${serial}."
