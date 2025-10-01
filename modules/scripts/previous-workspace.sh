#!/bin/bash

# previous-workspace.sh
# Switches to the previous workspace, wrapping around from 1 to 8.

. "$HOME/.config/quickshell/lib/logging.sh"
log_msg "--- Script Start: previous-workspace.sh ---"

MAX_WORKSPACES=8

# Get the ID of the currently active workspace
log_msg "Getting active workspace..."
active_ws=$(hyprctl activeworkspace -j | jq '.id')
log_msg "Active workspace is: $active_ws"

# Calculate the previous workspace ID
prev_ws=$((active_ws - 1))

# Wrap around if we've gone below 1
if [ "$prev_ws" -lt 1 ]; then
    log_msg "Min workspace reached, wrapping around to $MAX_WORKSPACES."
    prev_ws=$MAX_WORKSPACES
fi

# Switch to the previous workspace
log_msg "Dispatching to workspace: $prev_ws"
hyprctl dispatch workspace "$prev_ws"
log_msg "--- Script End: previous-workspace.sh ---"
