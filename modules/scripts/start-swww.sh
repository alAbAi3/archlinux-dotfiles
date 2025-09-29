#!/bin/sh

# start-swww.sh
# Wrapper script to start swww daemon and log its output.

. "$HOME/.config/quickshell/lib/logging.sh"

log_msg "--- Attempting to start swww daemon via swww init ---"

# Run swww init and redirect all its output (stdout and stderr) to the rice.log
swww init >> "$HOME/.cache/rice/rice.log" 2>&1

if [ $? -eq 0 ]; then
    log_msg "swww init command executed successfully."
else
    log_msg "swww init command failed. Check rice.log for details."
fi

log_msg "--- Finished attempting to start swww daemon ---"
