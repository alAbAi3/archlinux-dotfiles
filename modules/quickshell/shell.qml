import QtQuick
import QtQuick.Window
import "panel"

// shell.qml (main)
// This is the root of the UI. It assembles the Panel component.

Window {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    title: "QuickShell-Panel"

    // Set window flags for a panel/dock type application
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000" // Transparent background for the root window

    Item {
        width: root.width
        height: root.height

        // Instantiate the Panel component.
        Panel {
            id: panel
            // Anchor it to the top of the screen.
            anchors.top: parent.top
            // Make it as wide as the screen.
            width: parent.width
        }
    }
}
