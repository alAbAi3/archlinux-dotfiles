#!/bin/bash

# ws-listener.sh (v2 - Dynamic)
# Listens to Hyprland socket2 events and updates a state file
# with the current workspace status.

# --- Source Logging Library ---
if [ -f "$HOME/.config/quickshell/lib/logging.sh" ]; then
    . "$HOME/.config/quickshell/lib/logging.sh"
else
    log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ws-listener] $1"; }
fi

# --- Configuration ---
STATE_FILE="$HOME/.cache/rice/workspace_state.json"

# --- State Update Function ---
update_state() {
    log_msg "Updating workspace state..."
    
    # Get active workspace and all workspaces in one call, then format
    active_ws_id=$(hyprctl activeworkspace -j | jq '.id')
    workspaces_json=$(hyprctl workspaces -j | jq 'sort_by(.id) | .[] | {id: .id, windows: .windows}' | jq -s)

    # Combine into the final JSON structure
    final_json=$(jq -n --argjson active "$active_ws_id" --argjson workspaces "$workspaces_json" '{active: $active, workspaces: $workspaces}')

    # Write to state file
    echo "$final_json" > "$STATE_FILE"
    log_msg "State updated. Active: $active_ws_id"
}

# --- Main ---

# Initial state update on script start
# Give hyprland a moment to start up fully

sleep 1
update_state

# Main loop to listen for events
socat -U - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r event; do
    log_msg "Received event: $event"
    
    # Events that trigger a state update
    case $event in
        workspace* |
        createworkspace* |
        destroyworkspace* |
        openwindow* |
        closewindow*)
            update_state
            ;;
    esac
done