#!/bin/bash

# ws-listener.sh (v4 - Micro-Component Orchestrator)
# Listens to Hyprland events and redraws the workspace indicator component.

# --- Source Logging Library ---
if [ -f "$HOME/.config/quickshell/lib/logging.sh" ]; then
    . "$HOME/.config/quickshell/lib/logging.sh"
else
    log_msg() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ws-listener] $1"; }
fi

# --- Configuration ---
QML_TEMPLATE_FILE="$HOME/.config/quickshell/taskbar/workspace/templates/WorkspaceIndicator.qml.template"
QML_OUTPUT_FILE="$HOME/.config/quickshell/taskbar/workspace/WorkspaceIndicator.qml"
INDICATOR_PROCESS_NAME="QuickShell-Indicator"

# --- UI Update Function ---
update_ui() {
    log_msg "Redrawing workspace indicator UI..."
    
    # 1. Get current workspace state from hyprctl
    active_ws_id=$(hyprctl activeworkspace -j | jq '.id')
    workspaces_json=$(hyprctl workspaces -j | jq 'sort_by(.id) | .[] | {id: .id, windows: .windows}' | jq -s)
    final_json=$(jq -n --argjson active "$active_ws_id" --argjson workspaces "$workspaces_json" '{active: $active, workspaces: $workspaces}')

    # 2. Inject JSON data into the QML template
    # Using awk for robustness with special characters in JSON
    awk -v r="$final_json" '{gsub(/__WORKSPACES_JSON__/, r)}1' "$QML_TEMPLATE_FILE" > "$QML_OUTPUT_FILE"
    log_msg "QML file updated with new state."

    # 3. Kill the old indicator process if it's running
    if pgrep -f "$INDICATOR_PROCESS_NAME" > /dev/null; then
        log_msg "Killing existing indicator process."
        pkill -f "$INDICATOR_PROCESS_NAME"
    fi

    # 4. Launch the new indicator process in the background
    log_msg "Launching new indicator process."
    quickshell -p "$QML_OUTPUT_FILE" & 
}

# --- Main ---

# Initial UI draw on script start
sleep 1 # Give Hyprland a moment
update_ui

# Main loop to listen for events and trigger UI updates
socat -U - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r event; do
    log_msg "Received event: $event"
    
    case $event in
        workspace* |
        createworkspace* |
        destroyworkspace* |
        openwindow* |
        closewindow*)
            update_ui
            ;;
    esac
done
