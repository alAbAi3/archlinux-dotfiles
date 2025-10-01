import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import theme

Window {
    id: window
    width: 800
    height: 500
    visible: true
    title: "QuickShell-Launcher"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    property var allApps: []
    property string filterText: ""

    // --- Functions ---
    function readAppsFromFile() {
        var xhr = new XMLHttpRequest();
        // Use a fixed, predictable path. The toggle script is responsible for creating this file.
        var url = "file://" + Qt.getenv("HOME") + "/.cache/quickshell/apps.json";
        xhr.open("GET", url, false); // Synchronous request
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 0)) {
                try {
                    allApps = JSON.parse(xhr.responseText);
                    appGrid.model = allApps;
                } catch (e) {
                    console.log("JSON Parse Error: " + e);
                }
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
            spacing: 15

            SearchBox {
                id: searchBox
                Layout.fillWidth: true
                onTextChanged: {
                    // Update the filter text and the model will update automatically
                    filterText = text;
                }
                onAccepted: {
                    // If there's a visible item, launch it. Otherwise, do nothing.
                    if (appGrid.model.length > 0) {
                        var firstItem = appGrid.model[0];
                        console.log(firstItem.command);
                        Qt.quit();
                    }
                }
            }

            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 130
                cellHeight: 110
                
                // Filter the model based on the search text
                model: allApps.filter(function(app) {
                    return app.name.toLowerCase().includes(filterText.toLowerCase())
                })

                delegate: AppDelegate {
                    appName: modelData.name
                    appIcon: modelData.icon
                    appCommand: modelData.command
                }
            }
        }
    }
}