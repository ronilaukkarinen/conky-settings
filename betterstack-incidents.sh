#!/bin/bash

CACHE_FILE="/tmp/betterstack_incidents"
CACHE_MAX_AGE=3600  # 1 hour in seconds
ENV_FILE="$HOME/.config/conky/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found"
  exit 1
fi

# Source the .env file
source "$ENV_FILE"

# Check if API key is set
if [ -z "$BETTERSTACK_API_KEY" ]; then
  echo "Error: BETTERSTACK_API_KEY not set in .env"
  exit 1
fi

# Check if cache exists and is less than 1 hour old
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$CACHE_FILE"
else
  # Get the raw response first for debugging
  response=$(curl -s -H "Authorization: Bearer $BETTERSTACK_API_KEY" \
    "https://uptime.betterstack.com/api/v2/incidents")

  # Print the raw response for debugging
  echo "Debug: $response" > /tmp/betterstack_debug

  # Get the count of unresolved incidents (Started or Unconfirmed)
  count=$(echo "$response" | jq '[.data[] | select(.attributes.status == "Started" or .attributes.status == "Unconfirmed")] | length')

  # Save to cache file
  echo "$count" > "$CACHE_FILE"
  echo "$count"
fi
