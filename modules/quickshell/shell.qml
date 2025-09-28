import QtQuick
import QtQuick.Window 2.15

// shell.qml (main)
// This is the root of the UI. It assembles the Panel component.

Item {
    width: Screen.width
    height: Screen.height

    // Instantiate the Panel component.
    Panel {
        id: panel
        // Anchor it to the top of the screen.
        anchors.top: parent.top
        // Make it as wide as the screen.
        width: parent.width
    }
}
