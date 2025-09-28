import QtQuick
import QtQuick.Window 2.15

// shell.qml (main)
// This is the root of the UI. It assembles the Panel and Launcher components.

Item {
    width: Screen.width
    height: Screen.height

    // Instantiate the Launcher component. It will be invisible by default.
    Launcher {
        id: launcher
    }

    // Instantiate the Panel component.
    Panel {
        id: panel
        // Anchor it to the top of the screen.
        anchors.top: parent.top
        // Make it as wide as the screen.
        width: parent.width

        // Connect the panel's signal to the launcher's function.
        // When the button in the panel is clicked, it will call launcher.open().
        onLauncherButtonClicked: {
            console.log("DEBUG: Signal received in shell.qml. Calling launcher.open()...")
            launcher.open()
        }
    }
}
