#!/bin/sh

# This script toggles the launcher.
# It uses a temporary file to receive a command from the QML process.

QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
PROCESS_PATTERN="quickshell.*launcher/Launcher.qml"
COMMAND_FILE="/tmp/quickshell-launcher.command"

# If the launcher is already running, just kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

# Clear any leftover command file
rm -f "$COMMAND_FILE"

# Run the QML launcher and wait for it to finish.
# The QML app will write the desired command to COMMAND_FILE before exiting.
quickshell -qml "$QML_FILE"

# After the launcher closes, check if it produced a command.
if [ -f "$COMMAND_FILE" ]; then
    COMMAND_TO_RUN=$(cat "$COMMAND_FILE")
    rm -f "$COMMAND_FILE"

    # If a command was written, execute it via hyprctl
    if [ -n "$COMMAND_TO_RUN" ]; then
        hyprctl dispatch exec "$COMMAND_TO_RUN"
    fi
fi
