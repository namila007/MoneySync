#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <apk> [<apk> ...]" >&2
  exit 64
fi

if command -v apkanalyzer >/dev/null 2>&1; then
  apk_analyzer="$(command -v apkanalyzer)"
elif [[ -n "${ANDROID_HOME:-}" && -x "${ANDROID_HOME}/cmdline-tools/latest/bin/apkanalyzer" ]]; then
  apk_analyzer="${ANDROID_HOME}/cmdline-tools/latest/bin/apkanalyzer"
else
  echo "apkanalyzer was not found; install Android command-line tools or set ANDROID_HOME" >&2
  exit 69
fi

for apk_path in "$@"; do
  if [[ ! -f "${apk_path}" ]]; then
    echo "APK does not exist: ${apk_path}" >&2
    exit 66
  fi

  permissions="$("${apk_analyzer}" manifest permissions "${apk_path}")"
  manifest="$("${apk_analyzer}" manifest print "${apk_path}")"

  forbidden_permission_pattern='android\.permission\.(READ_SMS|RECEIVE_SMS|SEND_SMS|WRITE_SMS|RECEIVE_MMS|READ_CONTACTS|WRITE_CONTACTS|READ_CALL_LOG|WRITE_CALL_LOG|READ_EXTERNAL_STORAGE|WRITE_EXTERNAL_STORAGE|MANAGE_EXTERNAL_STORAGE|ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|ACCESS_BACKGROUND_LOCATION)'

  if printf '%s\n' "${permissions}" | rg --quiet "${forbidden_permission_pattern}"; then
    echo "Forbidden Android permission found in ${apk_path}:" >&2
    printf '%s\n' "${permissions}" | rg "${forbidden_permission_pattern}" >&2
    exit 1
  fi

  if ! printf '%s\n' "${manifest}" | rg --quiet 'android:usesCleartextTraffic="false"'; then
    echo "Cleartext network traffic is not explicitly disabled in ${apk_path}" >&2
    exit 1
  fi

  forbidden_sms_component_pattern='android\.provider\.Telephony\.SMS_RECEIVED|android\.permission\.BROADCAST_SMS|application/vnd\.wap\.mms-message'
  if printf '%s\n' "${manifest}" | rg --quiet "${forbidden_sms_component_pattern}"; then
    echo "Forbidden SMS/MMS receiver declaration found in ${apk_path}:" >&2
    printf '%s\n' "${manifest}" | rg "${forbidden_sms_component_pattern}" >&2
    exit 1
  fi

  echo "Permission audit passed: ${apk_path}"
done
