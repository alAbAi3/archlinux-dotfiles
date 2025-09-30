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
    
    # Find all .desktop files, excluding those that shouldn't be shown
    find /usr/share/applications ~/.local/share/applications -name "*.desktop" -print0 |
    xargs -0 awk -F'=' '
        /^Name=/ {name=$2}
        /^Icon=/ {icon=$2}
        /^Exec=/ {
            exec_cmd=$2;
            gsub(/%[a-zA-Z]/, "", exec_cmd); # Remove placeholders like %U, %F
            print "{"name":"" name "","icon":"" (icon ? icon : "application-x-executable") "","command":"" exec_cmd ""}"
        }
        /^NoDisplay=true/ {exit} # Skip entries that shouldn't be displayed
    ' |
    jq -s '.' > "$app_list_json"

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
