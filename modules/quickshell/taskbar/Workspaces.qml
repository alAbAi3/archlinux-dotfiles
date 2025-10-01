import QtQuick
import QtQuick.Layouts
import "../theme"

// Workspaces.qml
// This component displays the workspace buttons dynamically.

RowLayout {
    id: workspaceList
    spacing: 5
    Layout.alignment: Qt.AlignVCenter

    // These properties are now set by the parent component (Taskbar.qml)
    property int active: 1
    property var model: []

    // --- Repeater ---
    Repeater {
        model: workspaceList.model
        delegate: Rectangle {
            width: 30
            height: 30
            
            // Style based on workspace state passed from parent
            color: modelData.id === workspaceList.active ? Colors.color5 : "transparent"
            radius: 5
            border.color: Colors.color4
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: Colors.foreground
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // A separate process would be needed to listen to the main shell's output
                    // and execute this command.
                    console.log("hyprctl dispatch workspace " + modelData.id)
                }
            }
        }
    }
}
