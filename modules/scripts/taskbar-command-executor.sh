#!/bin/bash

# taskbar-command-executor.sh
# This script monitors a command file and executes commands written to it by the QML taskbar.
# This allows the taskbar to trigger actions like opening the launcher or switching workspaces.

# Source the centralized logging script (with fallback)
if [ -f "$HOME/.config/quickshell/lib/logging.sh" ]; then
    source "$HOME/.config/quickshell/lib/logging.sh"
else
    # Fallback logging function
    log_msg() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [taskbar-command-executor] $1" >> "$HOME/.cache/rice/rice.log"
    }
fi

COMMAND_FILE="$HOME/.cache/rice/taskbar_commands.txt"

# Ensure cache directory exists
mkdir -p "$HOME/.cache/rice"

# Initialize empty command file
> "$COMMAND_FILE"

log_msg "Command executor started. Monitoring: $COMMAND_FILE"

# Monitor the file and execute commands
while true; do
    if [[ -s "$COMMAND_FILE" ]]; then
        # Read the command
        command=$(cat "$COMMAND_FILE")
        
        # Clear the file immediately
        > "$COMMAND_FILE"
        
        if [[ -n "$command" ]]; then
            log_msg "Executing command: $command"
            # Execute the command in the background
            eval "$command" >> "$HOME/.cache/rice/rice.log" 2>&1 &
        fi
    fi
    
    # Small sleep to prevent CPU spinning
    sleep 0.1
done
