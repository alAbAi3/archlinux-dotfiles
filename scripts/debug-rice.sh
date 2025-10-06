#!/bin/bash
#
# debug-rice.sh
# Diagnose why taskbar/launcher aren't appearing
#

# Source the centralized logging script
source "$HOME/.config/quickshell/lib/logging.sh"

log_msg "--- Debug Script Start ---"

echo "🔍 RICE DEBUG REPORT"
echo "===================="
echo ""

# Check if QuickShell is running
echo "1. Checking if QuickShell is running..."
if pgrep -x quickshell > /dev/null; then
    echo "   ✅ QuickShell is running (PID: $(pgrep -x quickshell))"
    log_msg "QuickShell is running (PID: $(pgrep -x quickshell))"
else
    echo "   ❌ QuickShell is NOT running!"
    log_msg "ERROR: QuickShell is NOT running"
fi
echo ""

# Check if background services are running
echo "2. Checking background services..."
if pgrep -f taskbar-command-executor > /dev/null; then
    echo "   ✅ taskbar-command-executor is running"
    log_msg "taskbar-command-executor is running"
else
    echo "   ❌ taskbar-command-executor is NOT running"
    log_msg "ERROR: taskbar-command-executor is NOT running"
fi

if pgrep -f update-volume > /dev/null; then
    echo "   ✅ update-volume is running"
    log_msg "update-volume is running"
else
    echo "   ❌ update-volume is NOT running"
    log_msg "ERROR: update-volume is NOT running"
fi

if pgrep -x swww-daemon > /dev/null; then
    echo "   ✅ swww-daemon is running"
    log_msg "swww-daemon is running"
else
    echo "   ❌ swww-daemon is NOT running"
    log_msg "ERROR: swww-daemon is NOT running"
fi
echo ""

# Check critical files exist
echo "3. Checking critical files..."
if [ -f "$HOME/.config/quickshell/shell.qml" ]; then
    echo "   ✅ shell.qml exists"
    log_msg "shell.qml found"
else
    echo "   ❌ shell.qml NOT FOUND!"
    log_msg "ERROR: shell.qml NOT FOUND"
fi

if [ -f "$HOME/.config/quickshell/theme/Colors.qml" ]; then
    echo "   ✅ Colors.qml exists"
    log_msg "Colors.qml found"
else
    echo "   ❌ Colors.qml NOT FOUND! (Theme not initialized)"
    log_msg "ERROR: Colors.qml NOT FOUND - theme not initialized"
fi

if [ -d "$HOME/.config/quickshell/taskbar" ]; then
    echo "   ✅ taskbar directory exists"
    log_msg "taskbar directory found"
else
    echo "   ❌ taskbar directory NOT FOUND!"
    log_msg "ERROR: taskbar directory NOT FOUND"
fi

if [ -d "$HOME/.config/quickshell/launcher" ]; then
    echo "   ✅ launcher directory exists"
    log_msg "launcher directory found"
else
    echo "   ❌ launcher directory NOT FOUND!"
    log_msg "ERROR: launcher directory NOT FOUND"
fi
echo ""

# Check logs
echo "4. Checking logs..."
if [ -f "$HOME/.cache/rice/rice.log" ]; then
    echo "   📄 Last 10 lines of rice.log:"
    tail -n 10 "$HOME/.cache/rice/rice.log" | sed 's/^/      /'
else
    echo "   ❌ No rice.log found"
fi
echo ""

# Check Hyprland clients
echo "5. Checking Hyprland windows..."
QUICKSHELL_WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.class | contains("quickshell")) | .title' 2>/dev/null)
if [ -n "$QUICKSHELL_WINDOWS" ]; then
    echo "   ✅ QuickShell windows found:"
    echo "$QUICKSHELL_WINDOWS" | sed 's/^/      /'
else
    echo "   ❌ No QuickShell windows detected by Hyprland"
fi
echo ""

# Check environment variables
echo "6. Checking environment variables..."
if [ -n "$QML_XHR_ALLOW_FILE_READ" ]; then
    echo "   ✅ QML_XHR_ALLOW_FILE_READ=$QML_XHR_ALLOW_FILE_READ"
else
    echo "   ❌ QML_XHR_ALLOW_FILE_READ not set"
fi

if [ -n "$QT_QPA_PLATFORM" ]; then
    echo "   ✅ QT_QPA_PLATFORM=$QT_QPA_PLATFORM"
else
    echo "   ⚠️  QT_QPA_PLATFORM not set (might be OK)"
fi
echo ""

# Check for errors in Hyprland log
echo "7. Checking Hyprland log for errors..."
if [ -f "$HOME/.cache/hyprland/hyprland.log" ]; then
    ERRORS=$(grep -i "error\|fail\|critical" "$HOME/.cache/hyprland/hyprland.log" | tail -n 5)
    if [ -n "$ERRORS" ]; then
        echo "   ⚠️  Recent errors found:"
        echo "$ERRORS" | sed 's/^/      /'
    else
        echo "   ✅ No recent errors in Hyprland log"
    fi
else
    echo "   ❌ No Hyprland log found"
fi
echo ""

# Recommendations
echo "===================="
echo "🔧 RECOMMENDED ACTIONS:"
echo ""

if ! pgrep -x quickshell > /dev/null; then
    echo "   1. QuickShell is not running. Try starting it manually:"
    echo "      quickshell >> ~/.cache/rice/rice.log 2>&1 &"
    echo ""
fi

if [ ! -f "$HOME/.config/quickshell/theme/Colors.qml" ]; then
    echo "   2. Theme not initialized. Generate it:"
    echo "      apply-theme.sh ~/Pictures/Wallpapers/<any-image>.jpg"
    echo ""
fi

if ! pgrep -f taskbar-command-executor > /dev/null; then
    echo "   3. Command executor not running. Start it:"
    echo "      taskbar-command-executor.sh &"
    echo ""
fi

echo "   4. Check the full logs:"
echo "      cat ~/.cache/rice/rice.log"
echo "      cat ~/.cache/hyprland/hyprland.log"
echo ""

echo "   5. Try manual QuickShell launch to see errors:"
echo "      quickshell"
echo "      (Press Ctrl+C to stop, then restart in background)"
echo ""

log_msg "--- Debug Script End ---"
