#!/bin/bash

# cycle-workspace.sh
# Switches to the next workspace, wrapping around from 8 to 1.

MAX_WORKSPACES=8

# Get the ID of the currently active workspace
active_ws=$(hyprctl activeworkspace -j | jq '.id')

# Calculate the next workspace ID
next_ws=$((active_ws + 1))

# Wrap around if we've exceeded the max
if [ "$next_ws" -gt "$MAX_WORKSPACES" ]; then
    next_ws=1
fi

# Switch to the next workspace
hyprctl dispatch workspace "$next_ws"
