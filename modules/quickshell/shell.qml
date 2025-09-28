import QtQuick
import QtQuick.Layouts
import Qt.labs.platform 1.1 // For FileSystemWatcher

// Phase 1: MVP Baseline Panel + Launcher
// - A top bar with 8 workspace buttons and a live clock.
// - A basic launcher window, toggled by a file signal.

Rectangle {
    id: root
    width: parent.width
    height: 40
    color: "#282A36"

    // --- Timer for the Clock ---
    Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "h:mm AP")
        }
    }

    // --- Main Panel UI ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // --- Workspace Buttons ---
        RowLayout {
            id: workspaceList
            spacing: 5

            Repeater {
                model: 8 // Phase 1: 8 workspaces

                delegate: Rectangle {
                    width: 30
                    height: 30
                    color: index === 0 ? "#BD93F9" : "#44475A" // Active state is still hardcoded
                    radius: 5
                    border.color: "#6272A4"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: "#F8F8F2"
                        font.bold: true
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // --- Clock ---
        Text {
            id: clockText
            text: Qt.formatDateTime(new Date(), "h:mm AP")
            color: "#F8F8F2"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // --- Launcher Window ---
    // A semi-transparent background that catches clicks to close the launcher
    Rectangle {
        id: launcherOverlay
        anchors.fill: parent
        color: "#00000080" // Semi-transparent black
        visible: false

        MouseArea {
            anchors.fill: parent
            onClicked: {
                launcherOverlay.visible = false
            }
        }

        Rectangle {
            id: launcher
            width: parent.width / 2
            height: parent.height / 2
            anchors.centerIn: parent
            
            color: "#44475A"
            border.color: "#BD93F9"
            border.width: 2
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "Application Launcher"
                color: "#F8F8F2"
                font.pixelSize: 24
            }

            // This inner MouseArea prevents clicks *on* the launcher from propagating
            // to the overlay and closing it.
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }
        }
    }

    // --- File-based Signal for Launcher ---
    FileSystemWatcher {
        id: launcherWatcher
        // The client script will 'touch' this file.
        // Using a file in /tmp or $XDG_RUNTIME_DIR is standard for signals.
        filePath: "/tmp/quickshell.launcher.toggle" 

        onFileChanged: {
            launcherOverlay.visible = !launcherOverlay.visible
        }
    }
}