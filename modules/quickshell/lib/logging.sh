#!/bin/sh

# logging.sh
# Provides a standardized logging function for other scripts.
# This script is meant to be sourced, not executed directly.

# --- Configuration ---
LOG_FILE="$HOME/.cache/rice/rice.log"

# --- Functions ---

# log_msg
# Appends a timestamped message to the central log file.
# Usage: log_msg "Your message here"
log_msg() {
    # Get the name of the script that called this function
    local calling_script
    calling_script=$(basename "$0")
    
    # Format: [YYYY-MM-DD HH:MM:SS] [script_name] Message
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$calling_script] $1" >> "$LOG_FILE"
}
