#!/bin/bash

CACHE_FILE="/tmp/lastfm_current_track"
CACHE_MAX_AGE=15
ENV_FILE="$HOME/.config/conky/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Source the .env file
source "$ENV_FILE"

# Check if required variables are set
if [ -z "$LASTFM_API_KEY" ] || [ -z "$LASTFM_USERNAME" ]; then
    echo "Error: LASTFM_API_KEY or LASTFM_USERNAME not set in .env"
    exit 1
fi

# Check if cache exists and is less than 30 seconds old
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$CACHE_FILE"
else
  # Fetch the current track
  response=$(curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USERNAME&api_key=$LASTFM_API_KEY&format=json")

  # Extract artist and track name separately
  artist=$(echo "$response" | jq -r '.recenttracks.track[0].artist."#text"')
  track=$(echo "$response" | jq -r '.recenttracks.track[0].name')

  # URL encode artist and track names
  artist_encoded=$(echo -n "$artist" | jq -sRr @uri)
  track_encoded=$(echo -n "$track" | jq -sRr @uri)

  # Get track info including playcount
  track_info=$(curl -s "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=$LASTFM_API_KEY&artist=${artist_encoded}&track=${track_encoded}&username=$LASTFM_USERNAME&format=json")
  playcount=$(echo "$track_info" | jq -r '.track.userplaycount | select(. != null) // "0"')

  # Ensure playcount is set to 0 if empty or null
  if [ -z "$playcount" ]; then
      playcount="0"
  fi

  # Format output with artist/track on first line and plays on second line
  current_track="$artist - $track\nHistorical plays: $playcount"

  # Save to cache file
  echo -e "$current_track" > "$CACHE_FILE"
  echo -e "$current_track"
fi
