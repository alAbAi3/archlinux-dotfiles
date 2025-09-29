import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls // Added for ScrollView
import "theme"

Window {
    id: window
    width: 1000
    height: 600
    visible: true
    title: "QuickShell-WallpaperChanger"

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
    color: "#00000000"

    // The model that will be populated by parsing the JSON.
    ListModel {
        id: wallpaperModel
    }

    Component.onCompleted: {
        var wallpaperJsonFile = Qt.application.arguments[0];
        if (wallpaperJsonFile) {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "file://" + wallpaperJsonFile);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        try {
                            var paths = JSON.parse(xhr.responseText);
                            for (var i = 0; i < paths.length; i++) {
                                wallpaperModel.append({ "path": paths[i] });
                            }
                        } catch (e) {
                            console.error("Failed to parse wallpaper JSON from file:", e);
                            console.error("File content:", xhr.responseText);
                        }
                    } else {
                        console.error("Failed to load wallpaper JSON file. Status:", xhr.status);
                    }
                }
            };
            xhr.send();
        } else {
            console.warn("No wallpaper JSON file path provided as argument.");
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
