#!/usr/bin/env bash
set -euo pipefail

PKEXEC_BIN=/run/wrappers/bin/pkexec

if [[ ! -x "$PKEXEC_BIN" ]]; then
  echo "error: $PKEXEC_BIN is missing; enable security.wrappers.pkexec" >&2
  exit 1
fi

secret-tool lookup vpn netxp | "${PKEXEC_BIN}" openconnect \
  --user=szymon.gluch@netxp.pl \
  --passwd-on-stdin \
  --os=win \
  --csd-wrapper=/run/current-system/sw/bin/csd-post \
  --servercert pin-sha256:+YoOexcFWlfuHPAAK40fNkfB38XA6CUSuu5JvMM2hKc= \
  --authgroup="SAML" \
  vpn.networkexpert.pl 2>&1 | while IFS= read -r line; do
    url=$(printf '%s\n' "$line" | rg -oP "(?<=')https://[^']+(?=')" || true)
    if [ -n "$url" ]; then
      xdg-open "$url" &
    fi
    echo "$line"
  done
