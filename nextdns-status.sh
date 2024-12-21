#!/bin/bash

CACHE_FILE="/tmp/nextdns_status"
CACHE_MAX_AGE=30
ENV_FILE="$HOME/.config/conky/.env"

# Source the .env file if it exists
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

# Check if API key and profile ID are set
if [ -z "$NEXTDNS_API_KEY" ] || [ -z "$NEXTDNS_PROFILE_ID" ]; then
  echo "Error: NEXTDNS_API_KEY or NEXTDNS_PROFILE_ID not set in .env"
  exit 1
fi

if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
  cat "$CACHE_FILE"
else
  # Check if NextDNS CLI is installed
  if ! command -v nextdns >/dev/null 2>&1; then
    echo "DISCONNECTED|0" > "$CACHE_FILE"
    cat "$CACHE_FILE"
    exit 1
  fi

  # Get status from NextDNS CLI
  status_output=$(nextdns status | tr '[:lower:]' '[:upper:]')

  # Get last 24 hours of analytics from NextDNS API
  yesterday=$(date -d "yesterday" +%Y-%m-%d)
  today=$(date +%Y-%m-%d)

  blocked_count=$(curl -s -H "X-Api-Key: $NEXTDNS_API_KEY" \
    "https://api.nextdns.io/profiles/$NEXTDNS_PROFILE_ID/analytics/status?from=$yesterday&to=$today" | \
    jq -r '.data[] | select(.status == "blocked") | .queries')

  # Default to 0 if no count found
  blocked_count=${blocked_count:-0}

  if echo "$status_output" | grep -q "RUNNING"; then
    echo "CONNECTED|$blocked_count" > "$CACHE_FILE"
  else
    echo "DISCONNECTED|$blocked_count" > "$CACHE_FILE"
  fi

  cat "$CACHE_FILE"
fi
