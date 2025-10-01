#!/bin/bash

# ws-listener.sh (v3 - D-Bus)
# Listens to Hyprland socket2 events and pushes state updates to the
# running Taskbar component via D-Bus.

# --- Source Logging Library ---
if [ -f "$HOME/.config/quickshell/lib/logging.sh" ]; then
    . "$HOME/.config/quickshell/lib/logging.sh"
else
    log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ws-listener] $1"; }
fi

# --- D-Bus Configuration ---
DBUS_SERVICE="org.rice.QuickShell"
DBUS_PATH="/Taskbar"
DBUS_IFACE="org.rice.QuickShell.Taskbar"
DBUS_METHOD="updateState"

# --- State Update Function ---
update_state() {
    log_msg "Updating workspace state via D-Bus..."
    
    active_ws_id=$(hyprctl activeworkspace -j | jq '.id')
    workspaces_json=$(hyprctl workspaces -j | jq 'sort_by(.id) | .[] | {id: .id, windows: .windows}' | jq -s)

    final_json=$(jq -n --argjson active "$active_ws_id" --argjson workspaces "$workspaces_json" '{active: $active, workspaces: $workspaces}')

    # Push the state to the QML component via D-Bus
    qdbus "$DBUS_SERVICE" "$DBUS_PATH" "$DBUS_IFACE.$DBUS_METHOD" "$final_json"
    log_msg "D-Bus signal sent. Active: $active_ws_id"
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