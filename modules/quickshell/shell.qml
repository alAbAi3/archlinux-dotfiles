import QtQuick
import QtQuick.Layouts

// Phase 1 (revised): MVP Baseline Panel + Launcher
// - A top bar with a launcher button, 8 workspace buttons, and a live clock.
// - Launcher is toggled by the button, not a keybinding.

Rectangle {
    id: root
    width: parent.width
    height: 40
    color: "#282A36"

    // --- Timer for the Clock ---
    Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
        }
    }

    // --- Main Panel UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // --- Launcher Button ---
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

        // --- Workspace Buttons ---
        RowLayout {
            id: workspaceList
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: 8 // Phase 1: 8 workspaces

                delegate: Rectangle {
                    width: 30
                    height: 30
                    color: index === 0 ? "#BD93F9" : "#44475A" // Active state is still hardcoded
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

        // --- Clock ---
        Text {
            id: clockText
            text: Qt.formatDateTime(new Date(), "h:mm AP")
            color: "#F8F8F2"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // --- Launcher Window ---
    Rectangle {
        id: launcherOverlay
        // Use the main window as the parent for the overlay
        parent: root.parent
        anchors.fill: parent
        color: "#00000080" // Semi-transparent black
        visible: false

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

            Text {
                anchors.centerIn: parent
                text: "Application Launcher"
                color: "#F8F8F2"
                font.pixelSize: 24
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }
        }
    }
}
