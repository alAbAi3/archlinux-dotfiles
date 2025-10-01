import QtQuick
import QtQuick.Window
import QtQuick.Layouts

// WorkspaceIndicator.qml
// A standalone micro-application to display workspace indicators.

Window {
    id: window
    width: 200 // Adjust width as needed
    height: 40
    visible: true
    title: "QuickShell-Indicator"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000" // Transparent background

    // The JSON data will be injected here by the listener script
    property var workspaceData: { "active": 1, "workspaces": [ { "id": 1 } ] }

    RowLayout {
        id: workspaceList
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10

        Repeater {
            model: window.workspaceData.workspaces
            delegate: Rectangle {
                width: 12
                height: 12
                radius: 6
                color: modelData.id === window.workspaceData.active ? "lightgray" : "#444444"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("hyprctl dispatch workspace " + modelData.id)
                    }
                }
            }
        }
    }
}
