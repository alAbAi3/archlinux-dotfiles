#!/bin/bash

set -x # Enable verbose debug logging

# This script toggles the launcher.

# --- Configuration ---
CACHE_DIR="$HOME/.cache/quickshell"
APPS_JSON_FILE="$CACHE_DIR/apps.json"
QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
TEMP_QML_FILE="$CACHE_DIR/launcher.qml"
PROCESS_PATTERN="quickshell.*launcher.qml"
LOG_FILE="/tmp/launcher_debug.log" # Use a public, temporary log file for debugging

# --- Setup ---
# Clear previous log for clean debugging
rm -f "$LOG_FILE"
mkdir -p "$CACHE_DIR"

# --- Logging ---
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# --- App List Generation ---
_generate_app_list() {
    log "[DEBUG] Generating app list..."
    local app_dirs=("/usr/share/applications" "$HOME/.local/share/applications")
    local temp_json=$(mktemp)

    for dir in "${app_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            grep -l -r --include='*.desktop' -E "^Name=|^Exec=|^Icon=" "$dir" | while read -r file; do
                if grep -q "NoDisplay=true" "$file"; then continue; fi

                local name=$(grep -m 1 "^Name=" "$file" | cut -d'=' -f2)
                local exec_cmd=$(grep -m 1 "^Exec=" "$file" | cut -d'=' -f2 | sed 's/ %./ /g')
                local icon=$(grep -m 1 "^Icon=" "$file" | cut -d'=' -f2)

                if [[ -n "$name" && -n "$exec_cmd" ]]; then
                    jq -n --arg name "$name" --arg icon "${icon:-application-x-executable}" --arg command "$exec_cmd" \
                       '{name: $name, icon: $icon, command: $command}' >> "$temp_json"
                fi
            done
        fi
    done

    jq -s '.' "$temp_json" > "$APPS_JSON_FILE"
    rm "$temp_json"
    log "[DEBUG] App list generation complete."
}

# --- Main Logic ---
log "--- SCRIPT START ---"

# If launcher is running, kill it and exit.
log "[DEBUG] Checking for existing process with pattern: $PROCESS_PATTERN"
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    log "[DEBUG] Process found. Killing existing launcher."
    pkill -f "$PROCESS_PATTERN"
    log "[DEBUG] Script exiting after kill."
    exit 0
fi
log "[DEBUG] No existing process found."

# Generate a fresh app list.
_generate_app_list

# Inject the JSON data into the QML file.
log "[DEBUG] Injecting app data into QML template."
JSON_CONTENT=$(<"$APPS_JSON_FILE")
awk -v r="$(<"$APPS_JSON_FILE")" '{gsub(/__APPS_JSON__/, r)}1' "$QML_FILE" > "$TEMP_QML_FILE"
log "[DEBUG] Temporary QML file created at ${TEMP_QML_FILE}"


# Set necessary environment variables for QML
log "[DEBUG] Setting environment variables."
export QML_XHR_ALLOW_FILE_READ=1
export QML_IMPORT_PATH="$HOME/.config/quickshell"

log "[DEBUG] Starting launcher with QML file: $TEMP_QML_FILE"
OUTPUT=$(quickshell -p "$TEMP_QML_FILE" 2>> "$LOG_FILE")
log "[DEBUG] Launcher process finished. Raw output: '$OUTPUT'"

# --- Handle Launcher Output ---
if [[ -n "$OUTPUT" ]]; then
    log "[DEBUG] Output detected, executing command via hyprctl: '$OUTPUT'"
    hyprctl dispatch exec "$OUTPUT" >> "$LOG_FILE" 2>&1
fi

log "--- SCRIPT END ---"
