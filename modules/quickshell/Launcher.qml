import QtQuick
import QtQuick.Window 2.15
import QtQuick.Layouts
import Qt.labs.process 1.0

// Launcher.qml
// This is a standalone launcher application.

Window {
    id: window
    width: Screen.width
    height: Screen.height
    visible: true

    // Set window flags for an overlay/launcher type application
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000" // Transparent background for the window itself

    Process {
        id: process
    }

    // Semi-transparent overlay that covers the screen
    Rectangle {
        id: launcherOverlay
        anchors.fill: parent
        color: "#00000080"

        // Close the launcher by clicking the background
        MouseArea {
            anchors.fill: parent
            onClicked: {
                window.visible = false
            }
        }
    }

    // The main launcher window
    Rectangle {
        id: launcher
        width: parent.width / 2
        height: parent.height / 2
        anchors.centerIn: parent
        
        color: "#44475A"
        border.color: "#BD93F9"
        border.width: 2
        radius: 10

        // This inner MouseArea prevents clicks on the launcher body from closing it
        MouseArea { anchors.fill: parent; onClicked: {} }

        // Model containing the applications for the grid
        ListModel {
            id: appModel
            ListElement { name: "Terminal"; icon: "T"; command: "alacritty" }
            ListElement { name: "Browser"; icon: "B"; command: "firefox" }
            ListElement { name: "Files"; icon: "F"; command: "dolphin" }
            ListElement { name: "Settings"; icon: "S"; command: "" }
        }

        // Grid view to display the applications
        GridView {
            id: appGrid
            anchors.fill: parent
            anchors.margins: 20
            cellWidth: 120
            cellHeight: 120
            model: appModel

            delegate: Item {
                width: 100
                height: 100

                Text {
                    id: appIcon
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 15
                    font.family: "monospace"
                    font.pixelSize: 40
                    text: icon
                    color: mouseArea.containsMouse ? "#BD93F9" : "#F8F8F2"
                }

                Text {
                    id: appName
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 15
                    text: name
                    color: mouseArea.containsMouse ? "#BD93F9" : "#F8F8F2"
                    font.bold: true
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        if (command) {
                            process.exec("hyprctl", ["dispatch", "exec", command]);
                            window.visible = false;
                        }
                    }
                }
            }
        }
    }
}
