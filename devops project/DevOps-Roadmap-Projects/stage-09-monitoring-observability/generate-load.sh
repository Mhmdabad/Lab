#!/usr/bin/env bash
# generate-load.sh — hit the app so the dashboards, logs, and traces fill up.
# Run it in a second terminal after `docker compose up`.
set -euo pipefail
URL="${1:-http://localhost:8000}"

echo "Generating load against $URL (Ctrl-C to stop)..."
while true; do
  curl -s "$URL/" > /dev/null
  curl -s "$URL/work" > /dev/null      # variable latency -> traces + histogram
  curl -s "$URL/error" > /dev/null     # ~50% 500s -> error-rate panel
  sleep 0.3
done
