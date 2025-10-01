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

    property int activeWorkspace: 1

    // --- State Loading Function ---
    function loadState() {
        var url = "file:///home/alibek/.cache/rice/active_workspace.txt";
        try {
            var fileContent = Qt.readUrl(url);
            if (fileContent) {
                var newActive = parseInt(fileContent.trim(), 10);
                if (taskbar.activeWorkspace !== newActive) {
                    taskbar.activeWorkspace = newActive;
                }
            }
        } catch (e) {
            // Fail silently, the timer will try again
        }
    }

    // --- Timer for Polling ---
    Timer {
        interval: 250 // Poll every 250ms for responsiveness
        running: true
        repeat: true
        onTriggered: { loadState() }
    }

    // --- Main Taskbar UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // --- Workspace Indicators ---
        RowLayout {
            id: workspaceIndicators
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: 5
                delegate: Rectangle {
                    id: indicator
                    width: 12
                    height: 12
                    radius: 6

                    // Animate scale and color changes
                    Behavior on scale { NumberAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    // Properties are bound to the active workspace
                    scale: taskbar.activeWorkspace === (index + 1) ? 1.2 : 1.0
                    color: taskbar.activeWorkspace === (index + 1) ? "lightgray" : "#444444"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // The helper script handles the state change
                            console.log("sh ~/.local/bin/go-to-ws.sh " + (index + 1))
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ClockWidget {
            color: Colors.foreground
            Layout.alignment: Qt.AlignVCenter
        }
    }
}