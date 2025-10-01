#!/bin/bash

# previous-workspace.sh
# Switches to the previous workspace, wrapping around from 1 to 8.

MAX_WORKSPACES=8

# Get the ID of the currently active workspace
active_ws=$(hyprctl activeworkspace -j | jq '.id')

# Calculate the previous workspace ID
prev_ws=$((active_ws - 1))

# Wrap around if we've gone below 1
if [ "$prev_ws" -lt 1 ]; then
    prev_ws=$MAX_WORKSPACES
fi

# Switch to the previous workspace
hyprctl dispatch workspace "$prev_ws"
