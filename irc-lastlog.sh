#!/bin/bash

CACHE_FILE="/tmp/irc_lastlog"
TIMESTAMP_CACHE="/tmp/irc_lastlog_timestamp"
WORDS_CACHE="/tmp/irc_lastlog_words"
CACHE_MAX_AGE=1
LASTLOG_URL="https://botit.pulina.fi/lastlog.log"
INDENT="                "
NICK_WIDTH=15
DEBUG_LOG="/tmp/irc_lastlog_debug.log"
TODAY=$(date +%Y-%m-%d)
DAILY_LOG_URL="https://www.pulina.fi/pulina-days/pul-${TODAY}.log"

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
        echo "$line" | fmt -w 32
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
    echo "$line" | fmt -w 32
  fi
}

# Function to count words from daily log
count_daily_words() {
  # Fetch daily log and count actual chat messages
  curl -s "$DAILY_LOG_URL" | \
    awk '
      /^[0-2][0-9]:[0-5][0-9] <[^>]*>/ {
        # Get everything after the nick
        sub(/^[0-2][0-9]:[0-5][0-9] <[^>]*> /, "")
        # Skip system messages
        if (!/^(liittyi|poistui|Quit|Ping|timeout|Leaving)/) {
          # Remove URLs
          gsub(/https?:\/\/[^ ]*/, "")
          # Count words
          words += NF
        }
      }
      END { print words }
    '
}

# Update the word count cache
if [ ! -f "$WORDS_CACHE" ] || [ $(($(date +%s) - $(stat -c %Y "$WORDS_CACHE"))) -gt $CACHE_MAX_AGE ]; then
  total_words=$(count_daily_words)
  : "${total_words:=0}"  # Default to 0 if empty

  # Save word count for display
  printf "Words today: %d/10000\n" "$total_words" > "$WORDS_CACHE"
  # Save percentage for Conky's execbar
  echo "$((total_words * 100 / 10000))" > "${WORDS_CACHE}.count"
fi

# Get and cache the last timestamp
if [ ! -f "$TIMESTAMP_CACHE" ] || [ $(($(date +%s) - $(stat -c %Y "$TIMESTAMP_CACHE"))) -gt $CACHE_MAX_AGE ]; then
  last_line=$(curl -s "$LASTLOG_URL" | tail -n 1)
  last_timestamp=$(echo "$last_line" | cut -d' ' -f1)
  last_nick=$(echo "$last_line" | grep -o '<[^>]*>' | sed 's/[<>]//g')
  last_message=$(echo "$last_line" | cut -d' ' -f2- | sed 's/^<[^>]*> //')

  # Find the last day change and count words since then
  {
    echo "=== $(date) ==="
    echo "Fetching messages..."

    # Get all messages and find the last day change (23:59 to 00:00)
    all_messages=$(curl -s "$LASTLOG_URL")

    echo "Finding messages since last 00:00..."
    # Find the last day change by looking from bottom up
    day_messages=$(echo "$all_messages" | tac | awk '
      /^[0-2][0-9]:[0-5][0-9] / {
        if ($1 ~ /^00:/) {
          print NR
          exit
        }
      }
    ')

    if [ -n "$day_messages" ]; then
      # Convert line number from bottom to line number from top
      total_lines=$(echo "$all_messages" | wc -l)
      day_start=$((total_lines - day_messages + 1))
      echo "Found messages since line $day_start"

      echo "Sample of today's messages:"
      echo "$all_messages" | tail -n +"$day_start" | head -n 5

      echo "Looking for timestamps:"
      echo "Sample timestamps:"
      echo "$all_messages" | tail -n +"$day_start" | awk '{print $1}' | head -n 5

      total_words=$(echo "$all_messages" | tail -n +"$day_start" | \
        awk -F' <[^>]*> ' '
          /^[0-2][0-9]:[0-5][0-9] </ {
            if (NF > 1) print $2
          }
        ' | \
        grep -v "\(liittyi\|poistui\|Quit\|Ping\|timeout\|Leaving\)" | \
        tr ' ' '\n' | \
        grep -v '^[[:space:]]*$' | \
        grep -v '^[0-9]*$' | \
        grep -v '^https\?://' | \
        grep -v '^[!@#$%^&*()_+=<>?/|\\;:,.-]' | \
        wc -w)
    else
      echo "No day change found"
      total_words=0
    fi

    echo "Words since last day change: $total_words"
    echo "Raw message sample: $last_message"
  } > "$DEBUG_LOG"

  # Convert IRC timestamp to Unix timestamp
  unix_timestamp=$(date -d "$(date +%Y-%m-%d) $last_timestamp" +%s)
  relative_time=$(get_relative_time "$unix_timestamp")

  # Save to separate cache files
  {
    printf "Last message %s\nby %s: \"%s\"\n" "$relative_time" "$last_nick" "$last_message" | fmt -w 40
  } > "$TIMESTAMP_CACHE"

  # Save word count for progress bar
  printf "Words today: %d/10000\n" "$total_words" > "$WORDS_CACHE"
  # Save raw number for Conky's execbar
  printf "%d" "$total_words" > "${WORDS_CACHE}.count"
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
