#!/bin/sh

# This script toggles the launcher.
# It captures the stdout of the QML process to get the command to run.

QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
PROCESS_PATTERN="quickshell.*launcher/Launcher.qml"

# If the launcher is already running, just kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

# Run the QML launcher and capture its standard output.
COMMAND_TO_RUN=$(quickshell -qml "$QML_FILE")

# After the launcher closes, check if it produced a command.
if [ -n "$COMMAND_TO_RUN" ]; then
    # Execute the command via hyprctl
    hyprctl dispatch exec "$COMMAND_TO_RUN"
fi
