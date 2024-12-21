#!/bin/bash

CACHE_FILE="/tmp/todoist_tasks"
CACHE_MAX_AGE=300
ENV_FILE="$HOME/.config/conky/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found"
  exit 1
fi

# Source the .env file
source "$ENV_FILE"

# Check if API token is set
if [ -z "$TODOIST_API_TOKEN" ]; then
  echo "Error: TODOIST_API_TOKEN not set in .env"
  exit 1
fi

# Check if cache exists and is less than 5 minutes old
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_MAX_AGE ]; then
    cat "$CACHE_FILE"
else
    # Fetch tasks from Todoist API
    response=$(curl -s \
        -H "Authorization: Bearer $TODOIST_API_TOKEN" \
        "https://api.todoist.com/rest/v2/tasks?filter=today|overdue")

    # Get total task count
    total_tasks=$(echo "$response" | jq '. | length')

    # Output total tasks and tasks to cache file
    {
        if [ "$total_tasks" -eq 1 ]; then
            echo "1 task left to do."
        else
            echo "${total_tasks} tasks left to do."
        fi
        echo ""
        echo "$response" | jq -r '.[] | select(.due != null) | .content' | while read -r task; do
            echo "• ${task}"
        done
    } > "$CACHE_FILE"

    cat "$CACHE_FILE"
fi
