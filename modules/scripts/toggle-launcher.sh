#!/bin/sh

# This script toggles the launcher.
# It captures the stdout of the QML process to get the command to run.

# --- Source Logging Library ---
# Assuming this script will be symlinked to ~/.local/bin, and the lib is in ~/.config
. "$HOME/.config/quickshell/lib/logging.sh"

# --- App List Generation ---
# Scan for .desktop files and generate a JSON list for the QML to read.
generate_app_list() {
    log_msg "Generating app list..."
    local app_list_json="$HOME/.cache/quickshell_apps.json"
    local temp_json_list=$(mktemp)

    # Find all .desktop files
    find /usr/share/applications ~/.local/share/applications -name "*.desktop" |
    while read -r file; do
        # Skip entries that shouldn't be displayed
        if grep -q "NoDisplay=true" "$file"; then
            continue
        fi

        # Extract info using grep and sed for robustness
        name=$(grep -m 1 "^Name=" "$file" | sed 's/^Name=//')
        exec_cmd=$(grep -m 1 "^Exec=" "$file" | sed 's/^Exec=//' | sed 's/ %.*//')
        icon=$(grep -m 1 "^Icon=" "$file" | sed 's/^Icon=//')

        # Only add if name and command are present
        if [ -n "$name" ] && [ -n "$exec_cmd" ]; then
            # Use jq to safely build the JSON object for each entry
            jq -n \
               --arg name "$name" \
               --arg icon "${icon:-application-x-executable}" \
               --arg command "$exec_cmd" \
               '{name: $name, icon: $icon, command: $command}' >> "$temp_json_list"
        fi
    done

    # Combine all the JSON objects into a single JSON array
    jq -s '.' "$temp_json_list" > "$app_list_json"
    rm "$temp_json_list"

    log_msg "App list generated at $app_list_json"
}


log_msg "--- Script Start ---"

# Generate the app list on every run to keep it fresh
generate_app_list

QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
PROCESS_PATTERN="quickshell.*launcher/Launcher.qml"

# Set QML_IMPORT_PATH to help quickshell find modules
export QML_IMPORT_PATH="$HOME/.config/quickshell"

log_msg "QML File: $QML_FILE"
log_msg "Process Pattern: $PROCESS_PATTERN"
log_msg "DEBUG: QML_IMPORT_PATH = $QML_IMPORT_PATH"

# If the launcher is already running, just kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    log_msg "Process found. Killing existing launcher."
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

log_msg "Process not found. Starting launcher..."

# Run the QML launcher and capture its standard output.
# Crucially, also redirect stderr to the main log file to catch QML errors.
COMMAND_TO_RUN=$(quickshell -p "$QML_FILE" 2>> "$LOG_FILE")

log_msg "Captured command: '$COMMAND_TO_RUN'"

# After the launcher closes, check if it produced a command.
if [ -n "$COMMAND_TO_RUN" ]; then
    log_msg "Executing command with hyprctl..."
    # Redirect hyprctl output to the main log file
    hyprctl dispatch exec "$COMMAND_TO_RUN" >> "$LOG_FILE" 2>&1
    log_msg "hyprctl command finished."
else
    log_msg "No command was captured. Nothing to execute."
fi

log_msg "--- Script End ---"
