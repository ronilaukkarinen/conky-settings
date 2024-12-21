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
    current_track=$(curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USERNAME&api_key=$LASTFM_API_KEY&format=json" | \
        jq -r '.recenttracks.track[0] | "\(.artist."#text") - \(.name)"')

    # Save to cache file
    echo "$current_track" > "$CACHE_FILE"
    echo "$current_track"
fi
