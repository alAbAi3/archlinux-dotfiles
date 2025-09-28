import QtQuick
import QtQuick.Layouts

// Phase 1 (revised): MVP Baseline Panel + Launcher
// - A top bar with a launcher button, 8 workspace buttons, and a live clock.
// - Launcher is toggled by the button, contains a grid of applications.

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

        // --- Launcher Button ---
        Rectangle {
            width: 100
            height: 30
            Layout.alignment: Qt.AlignVCenter
            color: "#6272A4"
            radius: 5

            Text {
                anchors.centerIn: parent
                text: "Launcher"
                color: "#F8F8F2"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    launcherOverlay.visible = !launcherOverlay.visible
                }
            }
        }

        // --- Workspace Buttons ---
        RowLayout {
            id: workspaceList
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

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
    Rectangle {
        id: launcherOverlay
        parent: root.parent
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

            // Model containing the applications for the grid
            ListModel {
                id: appModel
                ListElement { name: "Terminal"; icon: ""; command: "alacritty" } // Icon for Alacritty/Terminal
                ListElement { name: "Browser"; icon: ""; command: "firefox" } // Icon for Firefox
                ListElement { name: "Files"; icon: ""; command: "dolphin" } // Icon for Folder
                ListElement { name: "Settings"; icon: ""; command: "" }      // Icon for Gear
            }

            // Grid view to display the applications
            GridView {
                id: appGrid
                anchors.fill: parent
                anchors.margins: 20
                cellWidth: 120
                cellHeight: 120

                model: appModel

                delegate: Rectangle {
                    width: 100
                    height: 100
                    color: "transparent"

                    Text { // Icon
                        id: appIcon
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 15
                        // NOTE: You must have a Nerd Font installed for these icons to render correctly.
                        // e.g., 'Symbols Nerd Font' or 'FiraCode Nerd Font'.
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 40
                        text: icon
                        color: "#F8F8F2"
                    }

                    Text { // Name
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 15
                        text: name
                        color: "#F8F8F2"
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        
                        // Visual feedback on hover
                        onEntered: parent.color = "#6272A4"
                        onExited: parent.color = "transparent"

                        onClicked: {
                            // For now, clicking just closes the launcher.
                            // The next step is to execute the 'command' property.
                            launcherOverlay.visible = false;
                        }
                    }
                }
            }

            // This inner MouseArea prevents clicks *on* the launcher from propagating
            // to the overlay and closing it.
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }
        }
    }
}