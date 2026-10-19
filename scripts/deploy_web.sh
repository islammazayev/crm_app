#!/usr/bin/env bash
# Bygger webbappen och publicerar den på Firebase Hosting.
#
#   scripts/deploy_web.sh            # publicerar live (crm-app-1e5fe.web.app)
#   scripts/deploy_web.sh preview    # förhandsversion på en tillfällig adress (7 dagar)
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f fx_key.json ]]; then
  echo "fx_key.json saknas. Kopiera fx_key.example.json och lägg in API-nyckeln." >&2
  exit 1
fi

flutter build web --release --dart-define-from-file=fx_key.json --no-wasm-dry-run

if [[ "${1:-}" == "preview" ]]; then
  firebase hosting:channel:deploy preview --expires 7d
else
  firebase deploy --only hosting
fi
