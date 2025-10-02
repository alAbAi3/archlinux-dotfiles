#!/bin/bash

# This script toggles the launcher.

# Source the centralized logging script
source "$HOME/.config/quickshell/lib/logging.sh"

# --- Configuration ---
CACHE_DIR="$HOME/.cache/quickshell"
APPS_JSON_FILE="$CACHE_DIR/apps.json"
QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
TEMP_QML_FILE="$CACHE_DIR/launcher.qml"
PROCESS_PATTERN="quickshell.*launcher.qml"

# --- App List Generation ---
_find_icon_path() {
    local icon_name=$1
    # Return early if it's already an absolute path
    if [[ "$icon_name" == /* ]]; then
        echo "file://$icon_name"
        return
    fi

    # Search in common directories
    local search_paths=(
        "/usr/share/pixmaps"
        "/usr/share/icons/hicolor/scalable/apps"
        "/usr/share/icons/hicolor/256x256/apps"
        "/usr/share/icons/hicolor/128x128/apps"
        "/usr/share/icons/hicolor/64x64/apps"
        "/usr/share/icons/hicolor/48x48/apps"
        "/usr/share/icons/Adwaita/scalable/apps"
        "/usr/share/icons/Adwaita/256x256/apps"
        "/usr/share/icons/breeze/apps/48"
        "/usr/share/icons/gnome/48x48/apps"
    )

    for path in "${search_paths[@]}"; do
        if [ -f "$path/$icon_name.png" ]; then
            echo "file://$path/$icon_name.png"
            return
        fi
        if [ -f "$path/$icon_name.svg" ]; then
            echo "file://$path/$icon_name.svg"
            return
        fi
        if [ -f "$path/$icon_name" ]; then
            echo "file://$path/$icon_name"
            return
        fi
    done

    # Fallback icon
    echo ""
}

_generate_app_list() {
    log_msg "Generating app list..."
    local app_dirs=("/usr/share/applications" "$HOME/.local/share/applications")
    local temp_json=$(mktemp)

    for dir in "${app_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            grep -l -r --include='*.desktop' -E "^Name=|^Exec=|^Icon=" "$dir" | while read -r file; do
                if grep -q "NoDisplay=true" "$file"; then continue; fi

                local name=$(grep -m 1 "^Name=" "$file" | cut -d'=' -f2)
                local exec_cmd=$(grep -m 1 "^Exec=" "$file" | cut -d'=' -f2 | sed 's/ %./ /g')
                local icon_name=$(grep -m 1 "^Icon=" "$file" | cut -d'=' -f2)
                local icon_path=$(_find_icon_path "$icon_name")

                if [[ -n "$name" && -n "$exec_cmd" ]]; then
                    jq -n --arg name "$name" --arg icon "${icon_path}" --arg command "$exec_cmd" \
                       '{name: $name, icon: $icon, command: $command}' >> "$temp_json"
                fi
            done
        fi
    done

    jq -s '.' "$temp_json" > "$APPS_JSON_FILE"
    rm "$temp_json"
    log_msg "App list generation complete."
}

# --- Main Logic ---
log_msg "--- Script Start ---"

# If launcher is running, kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    log_msg "Process found. Killing existing launcher."
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

# Generate a fresh app list.
_generate_app_list

# Inject the JSON data into the QML file.
log_msg "Injecting app data into QML template."
awk -v r="$(<"$APPS_JSON_FILE")" '{gsub(/__APPS_JSON__/, r)}1' "$QML_FILE" > "$TEMP_QML_FILE"
log_msg "Temporary QML file created at ${TEMP_QML_FILE}"


# Set necessary environment variables for QML
export QML_IMPORT_PATH="$HOME/.config/quickshell:$HOME/.config/quickshell/launcher"

log_msg "Starting launcher with QML file: $TEMP_QML_FILE"
# We only capture stdout, as stderr may contain unrelated Qt warnings.
# The QML component is responsible for printing ONLY the command to stdout.
OUTPUT=$(quickshell -p "$TEMP_QML_FILE")
log_msg "Launcher process finished. Raw output: '$OUTPUT'"

# --- Handle Launcher Output ---
# If the output is not empty, we assume it's the command to run.
if [[ -n "$OUTPUT" ]]; then
    log_msg "Output detected, executing command via hyprctl: '$OUTPUT'"
    hyprctl dispatch exec "$OUTPUT"
fi

log_msg "--- Script End ---"
