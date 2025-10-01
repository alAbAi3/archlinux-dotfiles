#!/bin/bash

# go-to-ws.sh
# Helper script to switch to a workspace and update the state file.

. "$HOME/.config/quickshell/lib/logging.sh"

STATE_FILE="$HOME/.cache/rice/active_workspace.txt"
TARGET_WS=$1

if [ -z "$TARGET_WS" ]; then
    log_msg "ERROR: No workspace number provided to go-to-ws.sh"
    exit 1
fi

log_msg "Switching to workspace $TARGET_WS"

# Switch workspace in Hyprland
hyprctl dispatch workspace "$TARGET_WS"

# Update the state file
echo "$TARGET_WS" > "$STATE_FILE"

log_msg "State file updated to $TARGET_WS"
