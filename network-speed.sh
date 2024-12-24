#!/bin/bash

SPEED_CACHE_FILE="/tmp/network_speed"
CACHE_MAX_AGE=900

# Function to format the output specifically for conky
format_output() {
  local output=""
  while IFS= read -r line; do
    if [[ $line == *"Ping:"* && ${line#*: } != "N/A" ]]; then
      output+="Internet ping: ${line#*: }\n"
    elif [[ $line == *"Download:"* && ${line#*: } != "N/A" ]]; then
      output+="Download speed: ${line#*: }\n"
    elif [[ $line == *"Upload:"* && ${line#*: } != "N/A" ]]; then
      output+="Upload speed: ${line#*: }\n"
    fi
  done
  if [ -n "$output" ]; then
    echo -e "$output"
  fi
}

# Function to get speed test results
get_speed_test() {
  # Requires speedtest-cli package
  speedtest-cli --simple 2>/dev/null | format_output > "$SPEED_CACHE_FILE"
  if [ $? -ne 0 ]; then
    echo "" > "$SPEED_CACHE_FILE"
  fi
  cat "$SPEED_CACHE_FILE"
}

# Check if cache exists and is fresh (15 minutes)
if [ -f "$SPEED_CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$SPEED_CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$SPEED_CACHE_FILE"
else
    get_speed_test
fi
