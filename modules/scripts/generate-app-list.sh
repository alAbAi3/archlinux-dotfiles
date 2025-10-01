#!/bin/bash
# generate-app-list.sh
# Scans for .desktop files and generates a JSON list for the QuickShell launcher.

# Set the output file path
CACHE_DIR="$HOME/.cache/quickshell"
OUTPUT_FILE="$CACHE_DIR/apps.json"
mkdir -p "$CACHE_DIR"

# Find all .desktop files in the standard application directories
# We will look in /usr/share/applications and ~/.local/share/applications
APP_DIRS=("/usr/share/applications" "$HOME/.local/share/applications")

# Start JSON array
echo "[" > "$OUTPUT_FILE"

first_entry=true
for dir in "${APP_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for file in "$dir"/*.desktop; do
            if [ -f "$file" ]; then
                # Skip entries that shouldn't be shown
                if grep -q "NoDisplay=true" "$file"; then
                    continue
                fi

                # Extract Name, Exec, and Icon
                name=$(grep -m 1 "^Name=" "$file" | cut -d'=' -f2)
                exec_cmd=$(grep -m 1 "^Exec=" "$file" | cut -d'=' -f2 | sed 's/ %./ /g') # Remove %U, %F, etc.
                icon=$(grep -m 1 "^Icon=" "$file" | cut -d'=' -f2)

                # Only add entries that have a name and a command
                if [ -n "$name" ] && [ -n "$exec_cmd" ]; then
                    # If icon is empty, use a default
                    if [ -z "$icon" ]; then
                        icon="application-x-executable"
                    fi

                    # Add comma if not the first entry
                    if [ "$first_entry" = false ]; then
                        echo "," >> "$OUTPUT_FILE"
                    fi
                    first_entry=false

                    # Write JSON object
                    jq -n --arg name "$name" --arg icon "$icon" --arg command "$exec_cmd" \
                       '{name: $name, icon: $icon, command: $command}' >> "$OUTPUT_FILE"
                fi
            fi
        done
    fi
done

# End JSON array
echo "]" >> "$OUTPUT_FILE"

echo "App list generated at $OUTPUT_FILE"
