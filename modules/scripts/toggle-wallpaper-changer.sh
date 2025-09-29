#!/bin/sh

# This script toggles the wallpaper changer UI.

# --- Source Logging Library ---
. "$HOME/.config/quickshell/lib/logging.sh"

log_msg "--- Script Start ---"

# --- Configuration ---
QML_FILE="$HOME/.config/quickshell/wallpaper-changer/WallpaperChanger.qml"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
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

# Write JSON to a temporary file
# Create cache directory if it doesn't exist
mkdir -p "$(dirname "$TEMP_JSON_FILE")"
echo "$WALLPAPER_JSON" > "$TEMP_JSON_FILE"

# Allow QML to read local files via XMLHttpRequest, which is required for our JSON loading.
export QML_XHR_ALLOW_FILE_READ=1

# Launch the QML window, capturing all output to parse it.
SELECTION_OUTPUT=$(quickshell -p "$QML_FILE" 2>&1)

log_msg "Captured selection output: '$SELECTION_OUTPUT'"

# Parse the output to find the line with our debug prefix.
SELECTED_WALLPAPER=$(echo "$SELECTION_OUTPUT" | grep "DEBUG qml:" | sed 's/^.*DEBUG qml: //')

# If a wallpaper was selected, apply the theme.
if [ -n "$SELECTED_WALLPAPER" ]; then
    log_msg "Executing theme change for: $SELECTED_WALLPAPER"
    sh "$APPLY_THEME_SCRIPT" "$SELECTED_WALLPAPER" >> "$LOG_FILE" 2>&1
else
    log_msg "No wallpaper selected."
fi

log_msg "--- Script End ---"
