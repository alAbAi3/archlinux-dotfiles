#!/bin/sh

# apply-theme.sh
# Applies a theme based on the selected wallpaper.

# --- Source Logging Library ---
. "$HOME/.config/quickshell/lib/logging.sh"

log_msg "--- Script Start ---"

# --- Configuration ---
# Get the directory of the script's original location, even if symlinked
ORIGINAL_SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$ORIGINAL_SCRIPT_PATH")
PROJECT_ROOT=$(dirname "$(dirname "$(dirname "$ORIGINAL_SCRIPT_PATH")")")

# The OUTPUT_FILE needs to be the live config file, not the one in the source repo.
THEME_DIR="$HOME/.config/quickshell/theme"
TEMPLATE_FILE="$THEME_DIR/templates/colors.qml.template"
OUTPUT_FILE="$HOME/.config/quickshell/theme/colors.qml"
WAL_CACHE="$HOME/.cache/wal"

# --- Default Wallpaper Handling ---
if [ -z "$1" ]; then
    log_msg "No wallpaper path provided. Using a random wallpaper as default."
    WALLPAPER=$(find "$PROJECT_ROOT/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | shuf -n 1)
    
    if [ -z "$WALLPAPER" ]; then
        log_msg "Error: No default wallpapers found in '$PROJECT_ROOT/wallpapers'."
        exit 1
    fi
    set -- "$WALLPAPER" # Set the first argument to the found wallpaper
fi

# --- Debugging Paths ---
log_msg "DEBUG: SCRIPT_DIR = $SCRIPT_DIR"
log_msg "DEBUG: PROJECT_ROOT = $PROJECT_ROOT"
log_msg "DEBUG: THEME_DIR = $THEME_DIR"
log_msg "DEBUG: TEMPLATE_FILE = $TEMPLATE_FILE"
log_msg "DEBUG: OUTPUT_FILE = $OUTPUT_FILE"

# --- Validation ---
WALLPAPER=$(realpath "$1")
log_msg "Applying theme from wallpaper: $WALLPAPER"

if [ ! -f "$WALLPAPER" ]; then
    log_msg "Error: Wallpaper file not found at '$WALLPAPER'"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    log_msg "Error: Template file not found at '$TEMPLATE_FILE'"
    exit 1
fi

# --- Main Logic ---

# Note for Alacritty theming:
# For this to work, your alacritty.yml should contain the following line:
# import:
#   - "~/.cache/wal/alacritty.yml"

log_msg "1. Generating color palette with 'wal'..."
# We remove the -n flag to allow wal to generate backend files (for alacritty)
# and send the reload sequence to running terminals.
wal -i "$WALLPAPER"

if [ ! -f "$WAL_CACHE/colors.json" ]; then
    log_msg "Error: 'wal' did not generate colors.json. Is 'wal' installed and working?"
    exit 1
fi

log_msg "2. Reading colors from wal cache..."
sed_script=""
for i in $(seq 0 15); do
    color=$(jq -r ".colors.color$i" "$WAL_CACHE/colors.json")
    sed_script="$sed_script; s/%%color$i%%/$color/g"
done

special_bg=$(jq -r '.special.background' "$WAL_CACHE/colors.json")
special_fg=$(jq -r '.special.foreground' "$WAL_CACHE/colors.json")
special_cursor=$(jq -r '.special.cursor' "$WAL_CACHE/colors.json")

sed_script="$sed_script; s/%%background%%/$special_bg/g"
sed_script="$sed_script; s/%%foreground%%/$special_fg/g"
sed_script="$sed_script; s/%%cursor%%/$special_cursor/g"

log_msg "3. Generating colors.qml from template..."
sed "$sed_script" "$TEMPLATE_FILE" > "$OUTPUT_FILE"

if [ ! -f "$OUTPUT_FILE" ]; then
    log_msg "Error: Failed to create '$OUTPUT_FILE'"
    exit 1
fi

log_msg "4. Setting wallpaper with 'swww'..."
swww img "$WALLPAPER" --transition-type any

log_msg "Theme applied successfully! New color palette written to '$OUTPUT_FILE'"
log_msg "--- Script End ---"
