import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import "../theme"

Window {
    id: window
    width: 1000
    height: 600
    visible: true
    title: "QuickShell-WallpaperChanger"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    // This property will be set by the shell script that launches this window.
    // It will contain a JSON string of wallpaper paths.
    property string wallpaperJson: "[]"

    // The model that will be populated by parsing the JSON.
    ListModel {
        id: wallpaperModel
    }

    Component.onCompleted: {
        try {
            var paths = JSON.parse(wallpaperJson);
            for (var i = 0; i < paths.length; i++) {
                wallpaperModel.append({ "path": paths[i] });
            }
        } catch (e) {
            console.error("Failed to parse wallpaper JSON:", e);
            console.error("Received JSON:", wallpaperJson);
        }
    }

    // --- Main UI ---
    Rectangle {
        id: changerOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
    }

    Rectangle {
        id: changer
        width: 950
        height: 550
        anchors.centerIn: parent
        color: Colors.background
        border.color: Colors.color4
        border.width: 1
        radius: 10

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            GridView {
                id: wallpaperGrid
                width: parent.width
                model: wallpaperModel
                cellWidth: 300
                cellHeight: 200

                delegate: WallpaperDelegate {
                    wallpaperPath: model.path
                }
            }
        }
    }
}
