#!/bin/sh

# This script toggles the launcher.
# It captures the stdout of the QML process to get the command to run.

LOG_FILE="/tmp/launcher-debug.log"

echo "--- Script Start ---" >> "$LOG_FILE"
date >> "$LOG_FILE"

QML_FILE="$HOME/.config/quickshell/launcher/Launcher.qml"
PROCESS_PATTERN="quickshell.*launcher/Launcher.qml"

echo "QML File: $QML_FILE" >> "$LOG_FILE"
echo "Process Pattern: $PROCESS_PATTERN" >> "$LOG_FILE"

# If the launcher is already running, just kill it and exit.
if pgrep -f "$PROCESS_PATTERN" > /dev/null; then
    echo "Process found. Killing existing launcher." >> "$LOG_FILE"
    pkill -f "$PROCESS_PATTERN"
    exit 0
fi

echo "Process not found. Starting launcher..." >> "$LOG_FILE"

# Run the QML launcher and capture its standard output.
# Crucially, also redirect stderr to the log to catch QML errors.
COMMAND_TO_RUN=$(quickshell -p "$QML_FILE" 2>> "$LOG_FILE")

echo "Captured command: '$COMMAND_TO_RUN'" >> "$LOG_FILE"

# After the launcher closes, check if it produced a command.
if [ -n "$COMMAND_TO_RUN" ]; then
    echo "Executing command with hyprctl..." >> "$LOG_FILE"
    hyprctl dispatch exec "$COMMAND_TO_RUN" >> "$LOG_FILE" 2>&1
    echo "hyprctl command finished." >> "$LOG_FILE"
else
    echo "No command was captured. Nothing to execute." >> "$LOG_FILE"
fi

echo "--- Script End ---" >> "$LOG_FILE"
