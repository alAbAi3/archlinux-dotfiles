#!/bin/bash

# update-volume.sh
# Updates volume information for the taskbar widget

# Source the centralized logging script (with fallback)
if [ -f "$HOME/.config/quickshell/lib/logging.sh" ]; then
    source "$HOME/.config/quickshell/lib/logging.sh"
    log_msg "Volume monitor started"
fi

OUTPUT_FILE="/tmp/rice_volume.txt"

while true; do
    # Get volume percentage (remove % sign)
    VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
    
    # Check if muted (yes = 1, no = 0)
    MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes' && echo "1" || echo "0")
    
    # Write to file in format: volume:muted
    echo "${VOLUME}:${MUTED}" > "$OUTPUT_FILE"
    
    sleep 1
done
