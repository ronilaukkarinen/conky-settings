#!/bin/bash

CACHE_FILE="/tmp/temperatures"
CACHE_MAX_AGE=60
TEMP_URL="https://c.rolle.wtf/json.php"

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
  cat "$CACHE_FILE"
else
  # Fetch and format temperatures
  curl -s "$TEMP_URL" | jq -r '.measurements[] | "\(.name): \(.temperature)°C"' > "$CACHE_FILE"
  cat "$CACHE_FILE"
fi
