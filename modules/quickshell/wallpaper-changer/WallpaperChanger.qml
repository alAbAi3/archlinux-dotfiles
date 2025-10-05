import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls // Added for ScrollView

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
        var wallpaperJsonFile = "file:///home/alibek/.cache/rice/wallpapers.json";
        var xhr = new XMLHttpRequest();
        xhr.open("GET", wallpaperJsonFile);
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
    }

    // --- Main UI ---
    Rectangle {
        id: changerOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: 0
        
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
        }
        
        MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
    }

    Rectangle {
        id: changer
        width: 1000
        height: 600
        anchors.centerIn: parent
        color: Qt.rgba(0.12, 0.12, 0.12, 0.95)
        border.color: Qt.rgba(0.5, 0.5, 0.5, 0.3)
        border.width: 2
        radius: 16
        
        scale: 0.9
        opacity: 0
        
        NumberAnimation on scale {
            from: 0.9
            to: 1.0
            duration: 300
            easing.type: Easing.OutBack
        }
        
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
        }
        
        // Subtle shadow
        layer.enabled: true
        layer.effect: ShaderEffect {
            property color shadowColor: Qt.rgba(0, 0, 0, 0.5)
        }

        MouseArea { anchors.fill: parent; onClicked: {} } // Prevent background click-through

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            // Title
            Text {
                text: "Wallpaper Gallery"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: "#FFFFFF"
                Layout.alignment: Qt.AlignLeft
            }
            
            Text {
                text: "Click a wallpaper to apply it"
                font.pixelSize: 13
                color: Qt.rgba(1, 1, 1, 0.6)
                Layout.alignment: Qt.AlignLeft
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                GridView {
                    id: wallpaperGrid
                    width: parent.width
                    model: wallpaperModel
                    cellWidth: 320
                    cellHeight: 200
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: WallpaperDelegate {
                        wallpaperPath: model.path
                    }
                }
            }
        }
    }
}
