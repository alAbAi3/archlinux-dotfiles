#!/bin/bash
#
# workspace-launcher.sh
# Launches an application on a specific workspace using hyprctl.
#

set -euo pipefail

# --- Functions ---

# Show usage information
usage() {
  cat <<EOF
Usage: $(basename "$0") <workspace> <command>
  <workspace>   The workspace number (e.g., 1, 2, 3...).
  <command>     The command to execute.

Examples:
  $(basename "$0") 2 firefox
  $(basename "$0") 3 "code --new-window"
EOF
}

# --- Main Script ---

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

WORKSPACE=$1
COMMAND=$2

# Validate that workspace is a number between 1 and 8
if ! [[ "$WORKSPACE" =~ ^[1-8]$ ]]; then
  echo "Error: Workspace must be a number between 1 and 8." >&2
  usage
  exit 1
fi

# Validate that command is not empty
if [ -z "$COMMAND" ]; then
  echo "Error: Command cannot be empty." >&2
  usage
  exit 1
fi

# Use hyprctl to dispatch the command to the specified workspace
# The 'silent' flag tells Hyprland not to focus the workspace after opening the app.
if ! hyprctl dispatch exec "[workspace $WORKSPACE silent] $COMMAND"; then
  echo "Error: Failed to execute command via hyprctl." >&2
  echo "Please ensure Hyprland is running and hyprctl is in your PATH." >&2
  exit 1
fi

# TODO: Implement fallback mechanism for apps that don't work well with dispatch.
# This would involve:
# 1. Get current workspace.
# 2. Switch to target workspace.
# 3. Launch the app.
# 4. Poll for the new window to appear (using `hyprctl clients`).
# 5. Move the window to the target workspace if it's not there.
# 6. Switch back to the original workspace.

exit 0