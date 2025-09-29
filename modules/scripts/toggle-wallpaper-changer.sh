#!/bin/sh

# This script toggles the wallpaper changer UI.

# --- Source Logging Library ---
. "$HOME/.config/quickshell/lib/logging.sh"

log_msg "--- Script Start ---"

# --- Configuration ---
QML_FILE="$HOME/.config/quickshell/wallpaper-changer/WallpaperChanger.qml"
WALLPAPER_DIR="$HOME/wallpapers"
PROCESS_PATTERN="quickshell.*WallpaperChanger.qml"
APPLY_THEME_SCRIPT="$HOME/.local/bin/apply-theme.sh"
TEMP_JSON_FILE="$HOME/.cache/rice/wallpapers.json"

# Set QML_IMPORT_PATH to help quickshell find modules
export QML_IMPORT_PATH="$HOME/.config/quickshell"

# --- Main Logic ---

# Kill existing process if it's running
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    log_msg "Process found. Killing existing changer."
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    log_msg "Wallpaper directory not found at $WALLPAPER_DIR"
    exit 1
fi

log_msg "Finding wallpapers in $WALLPAPER_DIR"

# Find all jpg and png files, create a JSON array of their full paths.
WALLPAPER_JSON=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | jq -R -s 'split("\n") | map(select(length > 0))')

log_msg "Found JSON: $WALLPAPER_JSON"

# Write JSON to a temporary file
echo "$WALLPAPER_JSON" > "$TEMP_JSON_FILE"

# Export the path to the JSON file as an environment variable
export RICE_WALLPAPER_JSON_FILE="$TEMP_JSON_FILE"

# Launch the QML window without passing the property via command line.
# Redirect stderr to the main log file to catch QML errors.
SELECTED_WALLPAPER=$(quickshell -p "$QML_FILE" 2>> "$LOG_FILE")

log_msg "Captured selection: '$SELECTED_WALLPAPER'"

# If a wallpaper was selected (printed to stdout), apply the theme.
if [ -n "$SELECTED_WALLPAPER" ]; then
    log_msg "Executing theme change..."
    sh "$APPLY_THEME_SCRIPT" "$SELECTED_WALLPAPER" >> "$LOG_FILE" 2>&1
else
    log_msg "No wallpaper selected."
fi

log_msg "--- Script End ---"
