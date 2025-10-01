#!/bin/bash

# cycle-workspace.sh
# Switches to the next workspace, wrapping around from 8 to 1.

. "$HOME/.config/quickshell/lib/logging.sh"
log_msg "--- Script Start: cycle-workspace.sh ---"

MAX_WORKSPACES=8

# Get the ID of the currently active workspace
log_msg "Getting active workspace..."
active_ws=$(hyprctl activeworkspace -j | jq '.id')
log_msg "Active workspace is: $active_ws"

# Calculate the next workspace ID
next_ws=$((active_ws + 1))

# Wrap around if we've exceeded the max
if [ "$next_ws" -gt "$MAX_WORKSPACES" ]; then
    log_msg "Max workspace reached, wrapping around to 1."
    next_ws=1
fi

# Switch to the next workspace
log_msg "Dispatching to workspace: $next_ws"
hyprctl dispatch workspace "$next_ws"
log_msg "--- Script End: cycle-workspace.sh ---"
