import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import theme
import launcher

Window {
    id: window
    width: 800
    height: 500
    visible: true
    title: "QuickShell-Launcher"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    property var allApps: __APPS_JSON__
    property string filterText: ""

    // --- Component Initialization ---
    Component.onCompleted: {
        appGrid.model = allApps;
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
        radius: 12

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
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