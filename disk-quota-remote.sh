#!/bin/bash

CACHE_FILE="/tmp/remote_disk_quota"
CACHE_MAX_AGE=3600
ENV_FILE="$HOME/.config/conky/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Source the .env file
source "$ENV_FILE"

# Check if all required variables are set
if [ -z "$REMOTE_DISK_URL" ] || [ -z "$REMOTE_DISK_AUTH_USER" ] || [ -z "$REMOTE_DISK_AUTH_PASS" ] || [ -z "$REMOTE_SERVER_NAME" ]; then
  echo "Error: REMOTE_DISK_URL, REMOTE_DISK_AUTH_USER, or REMOTE_DISK_AUTH_PASS not set in .env"
  exit 1
fi

# Check if cache exists and is less than 1 hour old
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
  cat "$CACHE_FILE"
else
  # Fetch quota information with basic auth
  response=$(curl -s -u "$REMOTE_DISK_AUTH_USER:$REMOTE_DISK_AUTH_PASS" "$REMOTE_DISK_URL")

  # Debug: Save raw response
  echo "Debug response:" > /tmp/quota_debug
  echo "$response" >> /tmp/quota_debug

  # Extract space and quota values using awk with debug output
  echo "$response" | awk '
  BEGIN { print "Debug: Starting awk processing" > "/tmp/quota_debug" }
  {
      print "Debug: Processing line: " $0 >> "/tmp/quota_debug"
  }
  NR==3 {
      space=$2
      quota=$3
      print "Debug: Raw values - space=" space " quota=" quota >> "/tmp/quota_debug"
      # Remove G from values and convert to numbers
      gsub("G", "", space)
      gsub("G", "", quota)
      print "Debug: Clean values - space=" space " quota=" quota >> "/tmp/quota_debug"
      # Print used space and total quota
      if (space != "" && quota != "") {
          printf "%.0f %.0f", space, quota
      } else {
          print "0 100"
      }
  }' > "$CACHE_FILE"

  cat "$CACHE_FILE"
fi
