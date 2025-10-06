#!/bin/bash

# taskbar-command-executor.sh
# This script monitors a command file and executes commands written to it by the QML taskbar.
# This allows the taskbar to trigger actions like opening the launcher or switching workspaces.

COMMAND_FILE="$HOME/.cache/rice/taskbar_commands.txt"
LOG_FILE="$HOME/.cache/rice/command-executor.log"

# Ensure cache directory exists
mkdir -p "$HOME/.cache/rice"

# Initialize empty command file
> "$COMMAND_FILE"

echo "[$(date)] Command executor started. Monitoring: $COMMAND_FILE" >> "$LOG_FILE"

# Monitor the file and execute commands
while true; do
    if [[ -s "$COMMAND_FILE" ]]; then
        # Read the command
        command=$(cat "$COMMAND_FILE")
        
        # Clear the file immediately
        > "$COMMAND_FILE"
        
        if [[ -n "$command" ]]; then
            echo "[$(date)] Executing: $command" >> "$LOG_FILE"
            # Execute the command in the background
            eval "$command" >> "$LOG_FILE" 2>&1 &
        fi
    fi
    
    # Small sleep to prevent CPU spinning
    sleep 0.1
done
