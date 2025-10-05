import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
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
        color: Qt.rgba(0, 0, 0, 0.7) // Darker semi-transparent background
        opacity: 0

        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    Rectangle {
        id: launcher
        width: 700
        height: 500
        anchors.centerIn: parent
        color: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.95)
        border.color: Qt.rgba(Colors.color4.r, Colors.color4.g, Colors.color4.b, 0.5)
        border.width: 2
        radius: 16
        
        scale: 0.9
        opacity: 0
        
        NumberAnimation on scale {
            from: 0.9
            to: 1.0
            duration: 300
            easing.type: Easing.OutBack
        }
        
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
        }
        
        // Subtle shadow
        layer.enabled: true
        layer.effect: ShaderEffect {
            property color shadowColor: Qt.rgba(0, 0, 0, 0.5)
        }

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // Title
            Text {
                text: "Applications"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: Colors.foreground
                Layout.alignment: Qt.AlignLeft
            }

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

            // Results count
            Text {
                visible: filterText.length > 0
                text: appGrid.model.length + " apps found"
                font.pixelSize: 12
                color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.6)
                Layout.alignment: Qt.AlignLeft
            }

            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 140
                cellHeight: 120
                clip: true
                
                // Filter the model based on the search text
                model: allApps.filter(function(app) {
                    return app.name.toLowerCase().includes(filterText.toLowerCase())
                })

                delegate: AppDelegate {
                    appName: modelData.name
                    appIcon: modelData.icon
                    appCommand: modelData.command
                }
                
                // Smooth scrolling
                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }
            }
        }
    }
}