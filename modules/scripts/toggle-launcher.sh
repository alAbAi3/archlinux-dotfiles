#!/bin/bash

# This script toggles the launcher.

# --- Configuration ---
CACHE_DIR="$HOME/.cache/quickshell"
APPS_JSON_FILE="$CACHE_DIR/apps.json"
QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
TEMP_QML_FILE="$CACHE_DIR/launcher.qml"
PROCESS_PATTERN="quickshell.*launcher.qml"
LOG_FILE="$CACHE_DIR/launcher.log"

# --- Setup ---
mkdir -p "$CACHE_DIR"

# --- Logging ---
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# --- App List Generation ---
_generate_app_list() {
    log "Generating app list..."
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
    log "App list generation complete."
}

# --- Main Logic ---
log "--- Script Start ---"

# If launcher is running, kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    log "Process found. Killing existing launcher."
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

# Generate a fresh app list.
_generate_app_list

# Inject the JSON data into the QML file.
log "Injecting app data into QML template."
JSON_CONTENT=$(<"$APPS_JSON_FILE")
sed "s|__APPS_JSON__|${JSON_CONTENT}|" "$QML_FILE" > "$TEMP_QML_FILE"
log "Temporary QML file created at ${TEMP_QML_FILE}"


# Set necessary environment variables for QML
export QML_XHR_ALLOW_FILE_READ=1
export QML_IMPORT_PATH="$HOME/.config/quickshell"

log "Starting launcher..."
OUTPUT=$(quickshell -p "$TEMP_QML_FILE" 2>> "$LOG_FILE")
log "Launcher output: '$OUTPUT'"

# --- Handle Launcher Output ---
if [[ -n "$OUTPUT" ]]; then
    log "Executing command: '$OUTPUT'"
    hyprctl dispatch exec "$OUTPUT" >> "$LOG_FILE" 2>&1
fi

log "--- Script End ---"