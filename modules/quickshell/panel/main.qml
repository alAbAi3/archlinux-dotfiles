import QtQuick
import QtQuick.Layouts

// Phase 0: Proof-of-Concept Panel
// - A simple bar at the top
// - Shows 3 workspace buttons
// - Placeholder for a clock

Rectangle {
    id: root
    width: parent.width // Take full width of the screen
    height: 40
    color: "#282A36" // A dark, Dracula-like color for the bar

    // Use a RowLayout to arrange items horizontally
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // --- Workspace Buttons ---
        RowLayout {
            id: workspaceList
            spacing: 5

            // Repeater is a good way to create multiple similar items
            Repeater {
                model: 3 // For Phase 0, we just create 3 workspaces

                delegate: Rectangle {
                    width: 30
                    height: 30
                    // Use a different color for the active workspace (e.g., workspace 1)
                    color: index === 0 ? "#BD93F9" : "#44475A"
                    radius: 5
                    border.color: "#6272A4"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: index + 1 // Display workspace number
                        color: "#F8F8F2"
                        font.bold: true
                    }

                    // In the future, we'll add mouse areas to switch workspaces
                }
            }
        }

        // This spacer pushes the clock to the right
        Item {
            Layout.fillWidth: true
        }

        // --- Clock (Placeholder) ---
        Text {
            id: clockText
            text: "10:30 PM" // Placeholder text
            color: "#F8F8F2"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
