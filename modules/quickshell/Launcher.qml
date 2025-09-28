import QtQuick
import QtQuick.Layouts

// Launcher.qml
// This component is the entire launcher window, including the overlay.
// It is designed to be controlled from outside.

Rectangle {
    id: launcherOverlay
    anchors.fill: parent
    color: "#00000080"
    visible: false
    enabled: visible

    // Public function to be called to show the launcher
    function open() {
        console.log("DEBUG: launcher.open() called in Launcher.qml. Setting visible to true.")
        visible = true;
    }

    // Close the launcher by clicking the background
    MouseArea {
        anchors.fill: parent
        onClicked: {
            launcherOverlay.visible = false
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
                        // Clicking an icon closes the launcher
                        launcherOverlay.visible = false;
                    }
                }
            }
        }
    }
}
