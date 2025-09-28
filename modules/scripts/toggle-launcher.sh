#!/bin/sh
# Toggles the launcher by creating or deleting a signal file.
SIGNAL_FILE="/tmp/quickshell/launcher.signal"
mkdir -p "$(dirname "$SIGNAL_FILE")"

if [ -f "$SIGNAL_FILE" ]; then
    rm "$SIGNAL_FILE"
else
    touch "$SIGNAL_FILE"
fi
