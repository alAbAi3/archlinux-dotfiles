import QtQuick
import QtQuick.Layouts
import "../theme"

// Workspaces.qml
// This component displays the workspace buttons.

RowLayout {
    id: workspaceList
    spacing: 5
    Layout.alignment: Qt.AlignVCenter

    // TODO: This model should be dynamic, driven by hyprland state.
    Repeater {
        model: 8
        delegate: Rectangle {
            width: 30
            height: 30
            // TODO: Color should reflect workspace state (active, has windows, etc.)
            color: index === 0 ? Colors.color5 : "transparent"
            radius: 5
            border.color: Colors.color4
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: Colors.foreground
                font.bold: true
            }
        }
    }
}
