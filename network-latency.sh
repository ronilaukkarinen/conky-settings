#!/bin/bash

CACHE_FILE="/tmp/network_latency"
CACHE_MAX_AGE=5
PING_HOST="8.8.8.8"

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
  cat "$CACHE_FILE"
else
  # Get latency using ping
  latency=$(ping -c 1 $PING_HOST | grep "time=" | cut -d "=" -f4)

  if [ -n "$latency" ]; then
    echo "$latency" > "$CACHE_FILE"
    echo "$latency"
  else
    echo "N/A" > "$CACHE_FILE"
    echo "N/A"
  fi
fi
