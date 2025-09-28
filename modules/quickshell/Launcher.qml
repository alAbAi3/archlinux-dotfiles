import QtQuick
import QtQuick.Layouts

// Launcher.qml
// This component is the entire launcher window, including the overlay.
// It is controlled by an external script via a signal file.
// This version uses a Timer and XHR to check for the signal file, avoiding experimental modules.

Rectangle {
    id: launcherOverlay
    anchors.fill: parent
    color: "#00000080"
    
    property bool launcherShouldBeVisible: false
    visible: launcherShouldBeVisible
    enabled: visible

    // Timer to periodically check for the signal file
    Timer {
        interval: 250 // Check every 250ms
        running: true
        repeat: true

        onTriggered: {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    // For local files, a status of 0 or 200 is success.
                    if (xhr.status === 200 || xhr.status === 0) {
                        launcherOverlay.launcherShouldBeVisible = true;
                    } else {
                        launcherOverlay.launcherShouldBeVisible = false;
                    }
                }
            }
            // Add a cache-busting query to the URL
            xhr.open("GET", "file:///tmp/quickshell/launcher.signal?t=" + new Date().getTime());
            xhr.send();
        }
    }

    // Clicking the background no longer closes the launcher.
    // The user must press the hotkey again to toggle it.
    MouseArea {
        anchors.fill: parent
        onClicked: {} // Absorb clicks
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

        // This inner MouseArea prevents clicks on the launcher body from propagating
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
                        // Clicking an icon also no longer closes the launcher.
                        // This is now a pure toggle via the hotkey.
                    }
                }
            }
        }
    }
}
