import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import Qt.labs.platform 1.0
import theme
import "../lib/fuzzysort.js" as FuzzySort

Window {
    id: window
    width: 800
    height: 500
    visible: true
    title: "QuickShell-Launcher"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    property var allApps: []

    // --- Functions ---
    function readAppsFromFile() {
        var xhr = new XMLHttpRequest();
        // The script generates this file in the user's cache
        var url = "file:///" + System.getenv("HOME") + "/.cache/quickshell_apps.json";
        xhr.open("GET", url, false); // Synchronous request
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                allApps = JSON.parse(xhr.responseText);
                appGrid.model = allApps; // Set initial model
            }
        }
        xhr.send();
    }

    // --- Component Initialization ---
    Component.onCompleted: {
        readAppsFromFile();
        searchBox.input.forceActiveFocus(); // Focus the search box on open
    }

    // --- Main UI ---
    Rectangle {
        id: launcherOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5) // Semi-transparent background

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    Rectangle {
        id: launcher
        width: 650
        height: 450
        anchors.centerIn: parent
        color: Colors.background
        border.color: Colors.color4
        border.width: 1
        radius: 10

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            SearchBox {
                id: searchBox
                Layout.fillWidth: true
                // When Enter is pressed, quit and output the search query.
                onAccepted: {
                    Qt.quit("SEARCH:" + text)
                }
            }

            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 130
                cellHeight: 120
                // Model is now set dynamically
                
                delegate: AppDelegate {
                    appName: modelData.name
                    // Use first letter of name as a fallback icon
                    appIcon: modelData.name ? modelData.name.substring(0, 1) : "?"
                    appCommand: modelData.command
                }
            }
        }
    }
}
