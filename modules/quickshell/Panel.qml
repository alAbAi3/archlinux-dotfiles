import QtQuick
import QtQuick.Layouts

// Panel.qml
// This component is the top bar, containing the launcher button, workspaces, and clock.

Rectangle {
    id: panel
    // The width will be set by the parent (the main shell.qml)
    height: 40
    color: "#282A36"

    // This signal is emitted when the launcher button is clicked
    signal launcherButtonClicked()

    // --- Timer for the Clock ---
    Timer {
        interval: 1000
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
                    // Emit the signal when clicked
                    panel.launcherButtonClicked()
                }
            }
        }

        // --- Workspace Buttons ---
        RowLayout {
            id: workspaceList
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: 8
                delegate: Rectangle {
                    width: 30
                    height: 30
                    color: index === 0 ? "#BD93F9" : "#44475A"
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
}
