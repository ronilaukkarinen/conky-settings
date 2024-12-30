#!/bin/bash

CACHE_FILE="/tmp/irc_lastlog"
TIMESTAMP_CACHE="/tmp/irc_lastlog_timestamp"
CACHE_MAX_AGE=1
LASTLOG_URL="https://botit.pulina.fi/lastlog.log"
INDENT="                "
NICK_WIDTH=15

# Get and cache the last timestamp
if [ ! -f "$TIMESTAMP_CACHE" ] || [ $(($(date +%s) - $(stat -c %Y "$TIMESTAMP_CACHE"))) -gt $CACHE_MAX_AGE ]; then
    curl -s "$LASTLOG_URL" | tail -n 1 | cut -d' ' -f1 > "$TIMESTAMP_CACHE"
fi

# Check if message cache exists and is less than 1 minute old
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$CACHE_FILE"
else
  # Fetch last 20 messages from the IRC log
  curl -s "$LASTLOG_URL" | tail -n 20 | while IFS= read -r line; do
    # Format timestamp and message
    timestamp=$(echo "$line" | cut -d' ' -f1)
    nick=$(echo "$line" | cut -d' ' -f2)
    message=$(echo "$line" | cut -d' ' -f3-)

    # Print nick right-aligned with fixed width
    printf "%${NICK_WIDTH}s " "$nick"

    # Print message with wrapping and indentation for wrapped lines
    echo "$message" | fmt -w 50 | sed "1!s/^/${INDENT}/"
  done > "$CACHE_FILE"

  cat "$CACHE_FILE"
fi
