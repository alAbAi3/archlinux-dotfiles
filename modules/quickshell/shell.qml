import QtQuick
import QtQuick.Layouts

// Test: Reverted to a simpler version to diagnose launch failure.
// - 8 workspaces and live clock from Phase 1.
// - Launcher and FileSystemWatcher from Phase 1 are REMOVED.

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

        // --- Workspace Buttons ---
        RowLayout {
            id: workspaceList
            spacing: 5

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
}
