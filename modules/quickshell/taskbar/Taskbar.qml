import QtQuick
import QtQuick.Layouts
import "../theme"

// Taskbar.qml
// This component is the top bar, containing the workspaces and clock.

Rectangle {
    id: taskbar
    // The width will be set by the parent (the main shell.qml)
    height: 40
    
    // Use a semi-transparent "glassy" background and an accent border
    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.6)
    border.color: Colors.color8
    border.width: 1

    // --- Timer for the Clock ---
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
        }
    }

    // --- Main Taskbar UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // --- Workspace Buttons ---
        Workspaces {
            id: workspaceList
        }

        Item {
            Layout.fillWidth: true
        }

        // --- Clock ---
        Text {
            id: clockText
            text: Qt.formatDateTime(new Date(), "h:mm AP")
            color: Colors.foreground
            font.pixelSize: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
