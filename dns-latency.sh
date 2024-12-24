#!/bin/bash

CACHE_FILE="/tmp/dns_latency"
CACHE_MAX_AGE=5
TEST_DOMAIN="google.com"

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
  cat "$CACHE_FILE"
else
  # Get DNS resolution time using dig
  dns_time=$(dig "@8.8.8.8" "$TEST_DOMAIN" | grep "Query time:" | awk '{print $4}')

  if [ -n "$dns_time" ]; then
    echo "${dns_time}ms" > "$CACHE_FILE"
    echo "${dns_time}ms"
  else
    echo "N/A" > "$CACHE_FILE"
    echo "N/A"
  fi
fi
