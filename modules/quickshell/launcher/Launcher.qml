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

    // The shell script will inject the JSON data here
    property var allApps: []
    property string appsJsonPath: "%%APPS_JSON_PATH%%"

    // --- Functions ---
    function readAppsFromFile() {
        var xhr = new XMLHttpRequest();
        var url = appsJsonPath;
        xhr.open("GET", url, false); // Synchronous request
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 0)) {
                allApps = JSON.parse(xhr.responseText);
                appGrid.model = allApps;
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
                
                delegate: AppDelegate {
                    appName: modelData.name
                    appIcon: modelData.name ? modelData.name.substring(0, 1) : "?"
                    appCommand: modelData.command
                }
            }
        }
    }
}