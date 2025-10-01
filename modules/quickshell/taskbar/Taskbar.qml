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
        var xhr = new XMLHttpRequest();
        var url = "file:///home/alibek/.cache/rice/workspace_state.json";
        xhr.open("GET", url, true);

        xhr.onreadystatechange = function() {
            // Log all state changes for debugging
            // console.log("XHR readyState: " + xhr.readyState + " Status: " + xhr.status)

            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) { // Status 0 is for local files
                    if (xhr.responseText) {
                        // console.log("XHR responseText length: " + xhr.responseText.length)
                        try {
                            var state = JSON.parse(xhr.responseText);
                            taskbar.activeWorkspace = state.active;
                            taskbar.workspaceModel = state.workspaces;
                        } catch (e) {
                            console.log("!!! QML PARSE ERROR: " + e.toString() + " | In file: " + xhr.responseText)
                        }
                    } else {
                        console.log("!!! QML FILE READ WARNING: File is empty.")
                    }
                } else {
                    console.log("!!! QML FILE READ ERROR: Status was " + xhr.status)
                }
            }
        }
        xhr.send();
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
