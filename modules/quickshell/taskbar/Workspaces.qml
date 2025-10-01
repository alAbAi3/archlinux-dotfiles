import QtQuick
import QtQuick.Layouts

// Workspaces.qml
// This component displays the workspace indicators as circles.

RowLayout {
    id: workspaceList
    spacing: 8 // Add some space between the circles
    Layout.alignment: Qt.AlignVCenter

    // These properties are set by the parent component (Taskbar.qml)
    property int active: 1
    property var model: []

    // --- Repeater ---
    Repeater {
        model: workspaceList.model
        delegate: Rectangle {
            width: 12
            height: 12
            
            // Style as a circle, color depends on active state.
            radius: 6
            color: modelData.id === workspaceList.active ? "lightgray" : "#444444" // Using a specific dark gray

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
