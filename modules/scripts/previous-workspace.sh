#!/bin/bash

# previous-workspace.sh
# Switches to the previous workspace, wrapping around from 1 to 5.

. "$HOME/.config/quickshell/lib/logging.sh"
log_msg "--- Script Start: previous-workspace.sh ---"

MAX_WORKSPACES=5
HELPER_SCRIPT="$HOME/.local/bin/go-to-ws.sh"

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

# Execute the helper script
log_msg "Executing helper script for workspace: $prev_ws"
sh "$HELPER_SCRIPT" "$prev_ws"

log_msg "--- Script End: previous-workspace.sh ---"
