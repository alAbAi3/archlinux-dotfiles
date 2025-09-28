import QtQuick
import QtQuick.Window
import QtQuick.Layouts

Window {
    id: window
    width: 800
    height: 500
    visible: true
    title: "QuickShell-Launcher"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    // --- Models ---
    ListModel {
        id: sourceAppModel
        ListElement { name: "Terminal"; icon: "T"; command: "alacritty" }
        ListElement { name: "Browser"; icon: "B"; command: "firefox" }
        ListElement { name: "Files"; icon: "F"; command: "dolphin" }
        ListElement { name: "VS Code"; icon: "C"; command: "code" }
        ListElement { name: "Settings"; icon: "S"; command: "" }
    }

    // --- Main UI ---
    Rectangle {
        id: launcherOverlay
        anchors.fill: parent
        color: "#00000080"

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    Rectangle {
        id: launcher
        width: 650
        height: 450
        anchors.centerIn: parent
        color: "#282A36"
        border.color: "#6272A4"
        border.width: 1
        radius: 10

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 130
                cellHeight: 120
                model: sourceAppModel // Display the full model directly
                
                delegate: AppDelegate {
                    appName: model.name
                    appIcon: model.icon
                    appCommand: model.command // Pass the command to the delegate
                }
            }
        }
    }
}
