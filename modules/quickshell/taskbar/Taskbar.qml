import QtQuick
import QtQuick.Layouts
import "../theme"
import "widgets/ClockWidget.qml"

// Taskbar.qml
// This component is the top bar, which assembles other widgets.

Rectangle {
    id: taskbar
    height: 40
    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.6)
    border.color: Colors.color8
    border.width: 1

    // --- Main Taskbar UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // The Workspaces component is a separate, externally managed process.

        Item {
            Layout.fillWidth: true
        }

        ClockWidget {
            color: Colors.foreground
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
