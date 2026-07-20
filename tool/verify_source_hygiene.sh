#!/usr/bin/env bash

set -euo pipefail

source_roots=(lib android test integration_test)

private_artifact_pattern='(^|/)(sms\.txt|\.env($|\.)|[^/]*\.(db|sqlite|sqlite3|wal|shm))$'
if rg --files "${source_roots[@]}" | rg --quiet "${private_artifact_pattern}"; then
  echo "Private data artifact found in application source paths:" >&2
  rg --files "${source_roots[@]}" | rg "${private_artifact_pattern}" >&2
  exit 1
fi

secret_pattern='BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|Authorization:[[:space:]]*Bearer[[:space:]]+[A-Za-z0-9._~+/=-]{12,}|wallet[_-]?token[[:space:]]*[:=][[:space:]]*["'"'][^"'"']{8,}["'"']'
if rg --hidden --ignore-case --line-number "${secret_pattern}" "${source_roots[@]}"; then
  echo "Possible hardcoded secret found in application source paths" >&2
  exit 1
fi

echo "Source hygiene audit passed"
