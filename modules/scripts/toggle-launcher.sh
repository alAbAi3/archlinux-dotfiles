#!/bin/sh

# This script toggles the launcher and handles search logic.

. "$HOME/.config/quickshell/lib/logging.sh"

# --- Configuration ---
QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
PROCESS_PATTERN="quickshell.*launcher/Launcher.qml"
MASTER_APP_LIST="$HOME/.cache/quickshell_master_apps.json"
DISPLAY_APP_LIST="$HOME/.cache/quickshell_apps.json" # The file QML actually reads

# --- App List Generation ---
generate_master_app_list() {
    log_msg "Generating master app list..."
    local temp_json_list=$(mktemp)

    find /usr/share/applications ~/.local/share/applications -name "*.desktop" |
    while read -r file; do
        if grep -q "NoDisplay=true" "$file"; then continue; fi
        name=$(grep -m 1 "^Name=" "$file" | sed 's/^Name=//')
        exec_cmd=$(grep -m 1 "^Exec=" "$file" | sed 's/^Exec=//' | sed 's/ %.*//')
        icon=$(grep -m 1 "^Icon=" "$file" | sed 's/^Icon=//')
        if [ -n "$name" ] && [ -n "$exec_cmd" ]; then
            jq -n \
               --arg name "$name" \
               --arg icon "${icon:-application-x-executable}" \
               --arg command "$exec_cmd" \
               '{name: $name, icon: $icon, command: $command}' >> "$temp_json_list"
        fi
    done
    jq -s '.' "$temp_json_list" > "$MASTER_APP_LIST"
    rm "$temp_json_list"
    log_msg "Master app list generated at $MASTER_APP_LIST"
}

# --- Main Logic ---
log_msg "--- Script Start ---"

# If launcher is running, kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    log_msg "Process found. Killing existing launcher."
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

# Ensure master list exists
if [ ! -f "$MASTER_APP_LIST" ]; then
    generate_master_app_list
fi

# Filter the list based on search query ($1)
SEARCH_QUERY=$1
if [ -n "$SEARCH_QUERY" ]; then
    log_msg "Filtering list with query: '$SEARCH_QUERY'"
    jq --arg query "$SEARCH_QUERY" 'map(select(.name | test($query; "i")))' "$MASTER_APP_LIST" > "$DISPLAY_APP_LIST"
else
    log_msg "No search query. Using master list."
    cp "$MASTER_APP_LIST" "$DISPLAY_APP_LIST"
fi

# Run the QML launcher and capture its output
export QML_IMPORT_PATH="$HOME/.config/quickshell"
log_msg "Starting launcher..."
OUTPUT=$(quickshell -p "$QML_FILE" 2>> "$LOG_FILE")
log_msg "Launcher output: '$OUTPUT'"

# --- Handle Launcher Output ---
case "$OUTPUT" in
    SEARCH:*) 
        # Relaunch with the new search query
        NEW_QUERY=$(echo "$OUTPUT" | sed 's/SEARCH://')
        log_msg "Relaunching with new search: '$NEW_QUERY'"
        exec "$0" "$NEW_QUERY" # exec replaces the current script process
        ;; 
    "")
        # Launcher was closed without selection
        log_msg "Launcher closed without action."
        ;; 
    *)
        # An app was selected, execute it
        log_msg "Executing command: '$OUTPUT'"
        hyprctl dispatch exec "$OUTPUT" >> "$LOG_FILE" 2>&1
        ;; 
esac

log_msg "--- Script End ---"