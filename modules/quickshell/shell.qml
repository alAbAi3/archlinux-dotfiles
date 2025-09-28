import QtQuick
import QtQuick.Layouts
import QtQuick.Window 2.15 // Import for Screen

// Phase 1 (revised v3): Corrected Layout with Explicit Size
// - The root item now has an explicit size matching the screen.
// This fixes the layout collapse from the previous version.

Item {
    id: shellRoot
    width: Screen.width
    height: Screen.height

    // --- Panel ---
    Rectangle {
        id: panel
        width: parent.width
        height: 40
        anchors.top: parent.top
        color: "#282A36"

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Rectangle {
                width: 100
                height: 30
                Layout.alignment: Qt.AlignVCenter
                color: "#6272A4"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "Launcher"
                    color: "#F8F8F2"
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        launcherOverlay.visible = !launcherOverlay.visible
                    }
                }
            }

            RowLayout {
                id: workspaceList
                spacing: 5
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: 8
                    delegate: Rectangle {
                        width: 30
                        height: 30
                        color: index === 0 ? "#BD93F9" : "#44475A"
                        radius: 5
                        border.color: "#6272A4"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: "#F8F8F2"
                            font.bold: true
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                id: clockText
                text: Qt.formatDateTime(new Date(), "h:mm AP")
                color: "#F8F8F2"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    // --- Launcher Window ---
    Rectangle {
        id: launcherOverlay
        anchors.fill: parent
        color: "#00000080"
        visible: false
        enabled: visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                launcherOverlay.visible = false
            }
        }

        Rectangle {
            id: launcher
            width: parent.width / 2
            height: parent.height / 2
            anchors.centerIn: parent
            
            color: "#44475A"
            border.color: "#BD93F9"
            border.width: 2
            radius: 10

            ListModel {
                id: appModel
                ListElement { name: "Terminal"; icon: "T"; command: "alacritty" }
                ListElement { name: "Browser"; icon: "B"; command: "firefox" }
                ListElement { name: "Files"; icon: "F"; command: "dolphin" }
                ListElement { name: "Settings"; icon: "S"; command: "" }
            }

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
                            launcherOverlay.visible = false;
                        }
                    }
                }
            }
        }
    }
}