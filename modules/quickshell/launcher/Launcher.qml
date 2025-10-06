import QtQuick 6.0
import QtQuick.Window 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.0
import "../theme"

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

            // Search Box
            Rectangle {
                id: searchBoxContainer
                height: 55
                Layout.fillWidth: true
                color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.5)
                radius: 10
                border.color: searchInput.activeFocus ? Colors.color4 : Qt.rgba(Colors.color5.r, Colors.color5.g, Colors.color5.b, 0.3)
                border.width: searchInput.activeFocus ? 2 : 1

                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on border.width { NumberAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "🔍"
                        font.pixelSize: 20
                        color: Colors.foreground
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.pixelSize: 16
                        color: Colors.foreground
                        selectionColor: Colors.color4
                        selectedTextColor: Colors.background
                        clip: true

                        Text {
                            text: "Search applications..."
                            font.pixelSize: 16
                            color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.5)
                            visible: !searchInput.text && !searchInput.activeFocus
                        }

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (appGrid.model.length > 0) {
                                    var firstItem = appGrid.model[0];
                                    console.log(firstItem.command);
                                    Qt.quit();
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                Qt.quit();
                                event.accepted = true;
                            }
                        }

                        onTextChanged: {
                            filterText = text;
                        }

                        Component.onCompleted: {
                            forceActiveFocus();
                        }
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

                delegate: Item {
                    width: 120
                    height: 110

                    property string appName: modelData.name
                    property string appIcon: modelData.icon
                    property string appCommand: modelData.command

                    Rectangle {
                        id: background
                        anchors.fill: parent
                        color: mouseArea.containsMouse ? Qt.rgba(Colors.color4.r, Colors.color4.g, Colors.color4.b, 0.2) : "transparent"
                        radius: 12
                        border.color: mouseArea.containsMouse ? Colors.color4 : "transparent"
                        border.width: 1
                        
                        scale: mouseArea.pressed ? 0.95 : 1.0
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on scale { 
                            NumberAnimation { 
                                duration: 100 
                                easing.type: Easing.OutCubic
                            } 
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignHCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 48
                                    height: 48
                                    radius: 10
                                    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.3)

                                    Image {
                                        anchors.centerIn: parent
                                        width: 36
                                        height: 36
                                        source: appIcon || ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        visible: appIcon !== ""
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: appName ? appName.charAt(0).toUpperCase() : "?"
                                        font.pixelSize: 24
                                        font.weight: Font.Bold
                                        color: Colors.color4
                                        visible: appIcon === ""
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                text: appName
                                font.pixelSize: 11
                                color: Colors.foreground
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                console.log(appCommand);
                                Qt.quit();
                            }
                        }
                    }
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