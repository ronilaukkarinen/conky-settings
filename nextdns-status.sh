#!/bin/bash

CACHE_FILE="/tmp/nextdns_status"
CACHE_MAX_AGE=30

if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$CACHE_FILE"
else
  # Check if NextDNS CLI is installed
  if ! command -v nextdns >/dev/null 2>&1; then
    echo "DISCONNECTED" > "$CACHE_FILE"
    cat "$CACHE_FILE"
    exit 1
  fi

  # Get full status output and convert to uppercase for comparison
  status_output=$(nextdns status | tr '[:lower:]' '[:upper:]')

  if echo "$status_output" | grep -q "RUNNING"; then
    echo "CONNECTED" > "$CACHE_FILE"
  else
    echo "DISCONNECTED" > "$CACHE_FILE"
  fi

  cat "$CACHE_FILE"
fi
