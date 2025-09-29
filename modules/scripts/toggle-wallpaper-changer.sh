#!/bin/sh

# This script toggles the wallpaper changer UI.

LOG_FILE="/tmp/wallpaper-changer-debug.log"
echo "--- Script Start ---" > "$LOG_FILE"

# --- Configuration ---
QML_FILE="$HOME/.config/quickshell/wallpaper-changer/WallpaperChanger.qml"
WALLPAPER_DIR="$HOME/wallpapers"
PROCESS_PATTERN="quickshell.*WallpaperChanger.qml"
APPLY_THEME_SCRIPT="$HOME/.local/bin/apply-theme.sh"

# --- Main Logic ---

# Kill existing process if it's running
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    echo "Process found. Killing existing changer." >> "$LOG_FILE"
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found at $WALLPAPER_DIR" >> "$LOG_FILE"
    exit 1
fi

echo "Finding wallpapers in $WALLPAPER_DIR" >> "$LOG_FILE"

# Find all jpg and png files, create a JSON array of their full paths.
WALLPAPER_JSON=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | jq -R -s 'split("\n") | map(select(length > 0))')

echo "Found JSON: $WALLPAPER_JSON" >> "$LOG_FILE"

# Launch the QML window, passing the JSON as a property.
# Note: The way to pass properties might differ based on the quickshell version.
# We are setting the root object's 'wallpaperJson' property.
# The JSON string must be properly quoted to be passed as a single argument.
SELECTED_WALLPAPER=$(quickshell -p "$QML_FILE" --property "{\"wallpaperJson\": \"$WALLPAPER_JSON\"}" 2>> "$LOG_FILE")

echo "Captured selection: '$SELECTED_WALLPAPER'" >> "$LOG_FILE"

# If a wallpaper was selected (printed to stdout), apply the theme.
if [ -n "$SELECTED_WALLPAPER" ]; then
    echo "Executing theme change..." >> "$LOG_FILE"
    sh "$APPLY_THEME_SCRIPT" "$SELECTED_WALLPAPER" >> "$LOG_FILE" 2>&1
else
    echo "No wallpaper selected." >> "$LOG_FILE"
fi

echo "--- Script End ---" >> "$LOG_FILE"
