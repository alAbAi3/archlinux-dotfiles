import QtQuick 6.0
import QtQuick.Window 6.0
import "taskbar"

// shell.qml (main)
// This is the root of the UI. It assembles the Taskbar component.

Window {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    title: "QuickShell-Taskbar"

    // Set window flags for a panel/dock type application
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000" // Transparent background for the root window

    Item {
        width: root.width
        height: root.height

        // Instantiate the Taskbar component.
        Taskbar {
            id: taskbar
            // Anchor it to the top of the screen.
            anchors.top: parent.top
            // Make it as wide as the screen.
            width: parent.width
        }
    }
}
