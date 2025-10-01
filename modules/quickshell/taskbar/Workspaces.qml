import QtQuick
import QtQuick.Layouts
import Qt.labs.platform // For FileSystemWatcher
import "../theme"

// Workspaces.qml
// This component displays the workspace buttons dynamically.

RowLayout {
    id: workspaceList
    spacing: 5
    Layout.alignment: Qt.AlignVCenter

    property int activeWorkspace: 1
    property var workspaceModel: []

    // --- State File Watcher ---
    // NOTE: You must have qt6-labs-platform installed for this to work.
    // The path is hardcoded for now as getenv() can be unreliable in QML.
    FileSystemWatcher {
        id: stateWatcher
        path: "file:///home/alibek/.cache/rice/workspace_state.json"
        onFileChanged: {
            console.log("Workspace state file changed, reloading.")
            loadState()
        }
    }

    // --- Function to load and parse state ---
    function loadState() {
        var xhr = new XMLHttpRequest();
        // NOTE: This requires QML_XHR_ALLOW_FILE_READ=1 to be set.
        var url = "file:///home/alibek/.cache/rice/workspace_state.json";
        xhr.open("GET", url, true); // Asynchronous
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 0)) {
                if (xhr.responseText) {
                    try {
                        var state = JSON.parse(xhr.responseText);
                        activeWorkspace = state.active;
                        workspaceModel = state.workspaces;
                        console.log("Successfully parsed state. Active workspace:", activeWorkspace);
                    } catch (e) {
                        console.log("!!! JSON PARSE ERROR in Workspaces.qml:", e.toString());
                    }
                }
            }
        }
        xhr.send();
    }

    // --- Component Initialization ---
    Component.onCompleted: {
        // Initial load
        loadState()
    }

    // --- Repeater ---
    Repeater {
        model: workspaceModel
        delegate: Rectangle {
            width: 30
            height: 30
            
            // Style based on workspace state
            color: modelData.id === activeWorkspace ? Colors.color5 : "transparent"
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
                    // This follows the project pattern of printing a command to stdout.
                    // A separate process would be needed to listen to the main shell's output
                    // and execute this command.
                    console.log("hyprctl dispatch workspace " + modelData.id)
                }
            }
        }
    }
}
