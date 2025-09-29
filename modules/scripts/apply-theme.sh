#!/bin/sh

# apply-theme.sh
# Applies a theme based on the selected wallpaper.

# --- Configuration ---
THEME_DIR="$HOME/.config/quickshell/theme"
TEMPLATE_FILE="$THEME_DIR/templates/colors.qml.template"
OUTPUT_FILE="$THEME_DIR/colors.qml"
WAL_CACHE="$HOME/.cache/wal"

# --- Validation ---
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/wallpaper.jpg"
    exit 1
fi

WALLPAPER=$(realpath "$1")

if [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper file not found at '$WALLPAPER'"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found at '$TEMPLATE_FILE'"
    exit 1
fi

# --- Main Logic ---

echo "1. Generating color palette with 'wal'..."
# Generate colors but don't let wal set the wallpaper (-n)
wal -i "$WALLPAPER" -n

if [ ! -f "$WAL_CACHE/colors.json" ]; then
    echo "Error: 'wal' did not generate colors.json. Is 'wal' installed and working?"
    exit 1
fi

echo "2. Reading colors from wal cache..."
# Read all 16 colors + special background/foreground colors into variables
# We use jq to parse the JSON file from pywal's cache.
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

echo "3. Generating colors.qml from template..."
# Use sed to replace placeholders in the template and create the final file.
sed "$sed_script" "$TEMPLATE_FILE" > "$OUTPUT_FILE"

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Error: Failed to create '$OUTPUT_FILE'"
    exit 1
fi

echo "4. Setting wallpaper with 'swww'..."
# Now, set the wallpaper using swww for a smooth transition.
swww img "$WALLPAPER" --transition-type any

echo "
Theme applied successfully!"
echo "New color palette written to '$OUTPUT_FILE'"
