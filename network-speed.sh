#!/bin/bash

SPEED_CACHE_FILE="/tmp/network_speed"
CACHE_MAX_AGE=900

# Function to format the output specifically for conky
format_output() {
  while IFS= read -r line; do
    if [[ $line == *"Ping:"* ]]; then
      echo "Internet Ping: ${line#*: }"
    elif [[ $line == *"Download:"* ]]; then
      echo "Download Speed: ${line#*: }"
    elif [[ $line == *"Upload:"* ]]; then
      echo "Upload Speed: ${line#*: }"
    fi
  done
}

# Function to get speed test results
get_speed_test() {
  # Requires speedtest-cli package
  speedtest-cli --simple 2>/dev/null | format_output > "$SPEED_CACHE_FILE"
  if [ $? -eq 0 ]; then
    cat "$SPEED_CACHE_FILE"
  else
    echo "Internet Ping: N/A"
    echo "Download Speed: N/A"
    echo "Upload Speed: N/A"
  fi
}

# Check if cache exists and is fresh (15 minutes)
if [ -f "$SPEED_CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$SPEED_CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$SPEED_CACHE_FILE"
else
    get_speed_test
fi
