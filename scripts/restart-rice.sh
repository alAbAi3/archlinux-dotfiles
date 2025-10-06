#!/bin/bash
#
# restart-rice.sh
# Quick script to restart all rice components
#

# Source the centralized logging script (with fallback)
if [ -f "$HOME/.config/quickshell/lib/logging.sh" ]; then
    source "$HOME/.config/quickshell/lib/logging.sh"
    log_msg "--- Restart Script Start ---"
fi

echo "🔄 Restarting rice components..."

# Kill existing processes
echo "-> Stopping existing processes..."
pkill -x quickshell
pkill -f taskbar-command-executor
pkill -f update-volume
log_msg "Killed existing processes"

# Wait a moment
sleep 1

# Start background services
echo "-> Starting background services..."
taskbar-command-executor.sh &
log_msg "Started taskbar-command-executor"

update-volume.sh &
log_msg "Started update-volume"

# Start QuickShell
echo "-> Starting QuickShell..."
quickshell >> ~/.cache/rice/rice.log 2>&1 &
log_msg "Started QuickShell"

sleep 2

# Check if everything started
echo ""
echo "🔍 Checking status..."

if pgrep -x quickshell > /dev/null; then
    echo "   ✅ QuickShell is running"
    log_msg "QuickShell confirmed running"
else
    echo "   ❌ QuickShell failed to start"
    log_msg "ERROR: QuickShell failed to start"
fi

if pgrep -f taskbar-command-executor > /dev/null; then
    echo "   ✅ taskbar-command-executor is running"
else
    echo "   ❌ taskbar-command-executor failed to start"
    log_msg "ERROR: taskbar-command-executor failed to start"
fi

if pgrep -f update-volume > /dev/null; then
    echo "   ✅ update-volume is running"
else
    echo "   ❌ update-volume failed to start"
    log_msg "ERROR: update-volume failed to start"
fi

echo ""
echo "✅ Restart complete! Check logs if something isn't working:"
echo "   tail -f ~/.cache/rice/rice.log"

log_msg "--- Restart Script End ---"
