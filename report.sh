#!/bin/bash

# If there are not enough arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <directory> <ERROR|WARN> [--top N]"
    exit 1
fi

DIR="$1"
LEVEL="$2"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: directory '$DIR' does not exist."
    exit 1
fi

# Check level
if [ "$LEVEL" != "ERROR" ] && [ "$LEVEL" != "WARN" ]; then
    echo "Error: level must be ERROR or WARN."
    exit 1
fi

# Count messages by module
RESULT=$(grep -rh "$LEVEL" "$DIR" | \
    awk '{print $2}' | \
    sort | uniq -c | sort -nr)

# --top N mode
if [ "$3" = "--top" ]; then
    if [ -z "$4" ]; then
        echo "Error: specify N after --top"
        exit 1
    fi

    RESULT=$(echo "$RESULT" | head -n "$4")
fi

echo "COUNT MODULE"
echo "$RESULT"