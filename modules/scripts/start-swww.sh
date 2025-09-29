#!/bin/sh

# start-swww.sh
# Wrapper script to start swww daemon and log its output.

. "$HOME/.config/quickshell/lib/logging.sh"

log_msg "--- Attempting to start swww daemon via swww-daemon ---"

sleep 1 # Give Hyprland a moment to initialize Wayland components

# Run swww-daemon and redirect all its output (stdout and stderr) to the rice.log
swww-daemon >> "$HOME/.cache/rice/rice.log" 2>&1

if [ $? -eq 0 ]; then
    log_msg "swww-daemon command executed successfully."
else
    log_msg "swww-daemon command failed. Check rice.log for details."
fi

log_msg "--- Finished attempting to start swww daemon ---"
