#!/bin/bash

CACHE_FILE="/tmp/irc_lastlog"
TIMESTAMP_CACHE="/tmp/irc_lastlog_timestamp"
CACHE_MAX_AGE=1
LASTLOG_URL="https://botit.pulina.fi/lastlog.log"
INDENT="                "
NICK_WIDTH=15

# Function to calculate relative time
get_relative_time() {
  local timestamp=$1
  local now=$(date +%s)
  local diff=$((now - timestamp))

  # Show "just now" if less than 2 minutes ago
  if [ $diff -lt 180 ]; then
    echo "a moment ago"
    return
  fi

  local days=$((diff / 86400))
  local hours=$(((diff % 86400) / 3600))
  local minutes=$(((diff % 3600) / 60))

  local result=""
  if [ $days -gt 0 ]; then
    if [ $days -eq 1 ]; then
      result="1 day"
    else
      result="${days} days"
    fi
    if [ $hours -gt 0 ]; then
      if [ $hours -eq 1 ]; then
        result="${result}, 1 hour"
      else
        result="${result}, ${hours} hours"
      fi
    fi
    if [ $minutes -gt 0 ]; then
      if [ $minutes -eq 1 ]; then
        result="${result}, 1 minute"
      else
        result="${result}, ${minutes} minutes"
      fi
    fi
  elif [ $hours -gt 0 ]; then
    if [ $hours -eq 1 ]; then
      result="1 hour"
    else
      result="${hours} hours"
    fi
    if [ $minutes -gt 0 ]; then
      if [ $minutes -eq 1 ]; then
        result="${result}, 1 minute"
      else
        result="${result}, ${minutes} minutes"
      fi
    fi
  else
    if [ $minutes -eq 1 ]; then
      result="1 minute"
    else
      result="${minutes} minutes"
    fi
  fi

  echo "$result ago"
}

# Function to format message with URL preservation
format_message() {
  local message="$1"
  local words=($message)
  local line=""
  local url_max_length=40

  for word in "${words[@]}"; do
    if [[ "$word" =~ ^https?:// ]]; then
      # If we have accumulated text, format it
      if [ -n "$line" ]; then
        echo "$line" | fmt -w 41
        line=""
      fi
      # Truncate URL if it's too long
      if [ ${#word} -gt $url_max_length ]; then
        printf '%s...\n' "${word:0:$((url_max_length-3))}"
      else
        printf '%s\n' "$word"
      fi
    else
      # Add word to current line
      if [ -z "$line" ]; then
        line="$word"
      else
        line="$line $word"
      fi
    fi
  done

  # Format any remaining text
  if [ -n "$line" ]; then
    echo "$line" | fmt -w 41
  fi
}

# Get and cache the last timestamp
if [ ! -f "$TIMESTAMP_CACHE" ] || [ $(($(date +%s) - $(stat -c %Y "$TIMESTAMP_CACHE"))) -gt $CACHE_MAX_AGE ]; then
  last_timestamp=$(curl -s "$LASTLOG_URL" | tail -n 1 | cut -d' ' -f1)
  # Convert IRC timestamp to Unix timestamp
  unix_timestamp=$(date -d "$last_timestamp" +%s)
  relative_time=$(get_relative_time "$unix_timestamp")
  echo "Last message sent $relative_time" > "$TIMESTAMP_CACHE"
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
    format_message "$message" | sed "1!s/^/${INDENT}/"
  done > "$CACHE_FILE"

  cat "$CACHE_FILE"
fi
