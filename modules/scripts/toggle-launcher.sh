#!/bin/sh

# This script toggles the launcher by starting or stopping the process.

QML_FILE="$HOME/.config/quickshell/Launcher.qml"
PROCESS_PATTERN="quickshell.*Launcher.qml"

if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    # If the process is running, kill it
    pkill -f "$PROCESS_PATTERN"
else
    # If the process is not running, launch it
    # We run it in the background and disown it so it doesn't die with the script
    quickshell -qml "$QML_FILE" &
fi
