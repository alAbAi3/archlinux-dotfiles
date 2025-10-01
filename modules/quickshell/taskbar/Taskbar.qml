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

    // --- State Properties ---
    property int activeWorkspace: 1
    property var workspaceModel: []

    // --- Function to load and parse state ---
    function loadState() {
        var url = "file:///home/alibek/.cache/rice/workspace_state.json";
        try {
            // Use a simpler, synchronous file read.
            var fileContent = Qt.readUrl(url);

            if (fileContent) {
                var state = JSON.parse(fileContent);
                taskbar.activeWorkspace = state.active;
                taskbar.workspaceModel = state.workspaces;
            } else {
                console.log("!!! QML READ WARNING: File is empty or could not be read.")
            }
        } catch (e) {
            console.log("!!! QML PARSE/READ ERROR: " + e.toString());
        }
    }

    // --- Initial Load ---
    Component.onCompleted: {
        loadState()
    }

    // --- Timer for Clock and State Polling ---
    Timer {
        interval: 1000 // 1 second
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
            loadState() // Poll for workspace state changes
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
