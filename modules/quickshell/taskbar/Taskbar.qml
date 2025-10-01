import QtQuick
import QtQuick.Layouts
import "../theme"

// Taskbar.qml
// This component is the top bar, containing the workspaces and clock.

Rectangle {
    id: taskbar
    height: 40
    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.6)
    border.color: Colors.color8
    border.width: 1

    // --- DIANOSTIC: Hardcoded State Properties ---
    property int activeWorkspace: 2 // Hardcoded to 2 for testing
    property var workspaceModel: [ { "id": 1 }, { "id": 2 } ] // Hardcoded two workspaces

    // --- Timer for Clock ---
    Timer {
        interval: 1000 // 1 second
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
            // Polling is temporarily disabled for diagnostics
            // loadState()
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
            // Pass the model and active state down to the child component
            active: taskbar.activeWorkspace
            model: taskbar.workspaceModel
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
