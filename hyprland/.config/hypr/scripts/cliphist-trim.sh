#!/usr/bin/env bash

MAX_ITEMS=50

while true; do
    # Get the total count of stored items
    COUNT=$(cliphist list | wc -l)
    
    # If we exceed the limit, delete the oldest item
    if [ "$COUNT" -gt "$MAX_ITEMS" ]; then
        # The last line of 'cliphist list' corresponds to the oldest item
        cliphist list | tail -n 1 | cliphist delete
    else
        # Sleep briefly if within limits to avoid high CPU usage
        sleep 1800 
    fi
done

