import QtQuick
import QtQuick.Layouts
import QtDBus 1.0
import "../theme"

// Taskbar.qml
// This component is the top bar, containing the workspaces and clock.

Rectangle {
    id: taskbar
    height: 40
    color: Qt.rgba(Colors.color0.r, Colors.color0.g, Colors.color0.b, 0.6)
    border.color: Colors.color8
    border.width: 1

    // --- D-Bus Service Adaptor ---
    // Registers this component on D-Bus so shell scripts can call its methods.
    DBusAdaptor {
        id: dbusAdaptor
        service: "org.rice.QuickShell"
        iface: "org.rice.QuickShell.Taskbar"
        path: "/Taskbar"

        // This function can be called from the command line via qdbus.
        // It expects a single string argument containing the JSON data.
        Q_NOREPLY function updateState(jsonString) {
            try {
                var state = JSON.parse(jsonString);
                taskbar.activeWorkspace = state.active;
                taskbar.workspaceModel = state.workspaces;
            } catch (e) {
                console.log("!!! QML D-Bus PARSE ERROR: " + e.toString())
            }
        }
    }

    // --- State Properties ---
    property int activeWorkspace: 1
    property var workspaceModel: [{ "id": 1, "windows": 0 }] // Start with one workspace

    // --- Timer for Clock ---
    Timer {
        interval: 1000 // 1 second
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
        }
    }

    // --- Main Taskbar UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Workspaces {
            id: workspaceList
            active: taskbar.activeWorkspace
            model: taskbar.workspaceModel
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            id: clockText
            text: Qt.formatDateTime(new Date(), "h:mm AP")
            color: Colors.foreground
            font.pixelSize: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
