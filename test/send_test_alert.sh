#!/usr/bin/env bash
# Send a single test alert to the NetDoc Pro webhook server.
#
# Usage:
#   WEBHOOK_TOKEN=yourtoken ./send_test_alert.sh                   # default Down alert for 192.168.1.1
#   WEBHOOK_TOKEN=yourtoken ./send_test_alert.sh 10.0.99.1 Up      # specific device + status
#   WEBHOOK_HOST=http://192.168.1.50:9741 WEBHOOK_TOKEN=yourtoken ./send_test_alert.sh
#
# WEBHOOK_TOKEN is required from NetDoc Pro 1.14.0 onwards.
# Copy it from Network Tools → Discover → PRTG WEBHOOK SERVER in the app.
#
# WSL note: localhost does not reach the Windows host in WSL2.
# Get the Windows host IP first:
#   export WEBHOOK_HOST="http://$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):9741"

set -euo pipefail

WEBHOOK_HOST="${WEBHOOK_HOST:-http://localhost:9741}"
WEBHOOK_TOKEN="${WEBHOOK_TOKEN:-}"
DEVICE_IP="${1:-192.168.1.1}"
STATUS="${2:-Down}"

if [ -z "$WEBHOOK_TOKEN" ]; then
  echo "WARNING: WEBHOOK_TOKEN not set. Requests will return 401 on NetDoc Pro 1.14.0+." >&2
fi

# Step 1 — verify webhook is running
echo "Checking webhook health at ${WEBHOOK_HOST}/health..."
if ! HEALTH=$(curl -sS --max-time 5 "${WEBHOOK_HOST}/health"); then
  echo "ERROR: webhook not reachable at ${WEBHOOK_HOST}." >&2
  echo "Is the PRTG toggle enabled in NetDoc Pro (API menu → PRTG Webhook)?" >&2
  exit 1
fi
echo "Webhook health response: ${HEALTH}"

# Step 2 — send the test alert
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
PAYLOAD=$(printf '{"device":"%s","status":"%s","sensor":"Test sensor","message":"Test alert sent at %s"}' \
  "${DEVICE_IP}" "${STATUS}" "${TIMESTAMP}")

echo "Sending test alert to ${DEVICE_IP} (status: ${STATUS})..."
CURL_ARGS=(-sS --max-time 5 -H "Content-Type: application/json" -X POST -d "${PAYLOAD}")
[ -n "$WEBHOOK_TOKEN" ] && CURL_ARGS+=(-H "X-Webhook-Token: ${WEBHOOK_TOKEN}")

RESPONSE=$(curl "${CURL_ARGS[@]}" "${WEBHOOK_HOST}/prtg")

echo "Server response: ${RESPONSE}"
echo "✓ Test alert sent. Check the NetDoc Pro canvas for the status change on device ${DEVICE_IP}."
