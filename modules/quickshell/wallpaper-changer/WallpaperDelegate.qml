import QtQuick

Item {
    id: delegateRoot
    width: 310
    height: 190

    property string wallpaperPath: ""
    property string wallpaperFile: wallpaperPath.substring(wallpaperPath.lastIndexOf('/') + 1)

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 5
        color: Qt.rgba(0.18, 0.18, 0.18, 0.8)
        radius: 12
        border.color: mouseArea.containsMouse ? "#4A9EFF" : Qt.rgba(0.35, 0.35, 0.35, 0.6)
        border.width: mouseArea.containsMouse ? 3 : 2
        
        scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.02 : 1.0)
        
        Behavior on border.color { ColorAnimation { duration: 200 } }
        Behavior on border.width { NumberAnimation { duration: 200 } }
        Behavior on scale { 
            NumberAnimation { 
                duration: 150 
                easing.type: Easing.OutCubic
            } 
        }
        
        // Drop shadow
        layer.enabled: mouseArea.containsMouse
        layer.effect: ShaderEffect {
            property color shadowColor: Qt.rgba(0, 0, 0, 0.4)
        }

        Image {
            id: thumbnail
            anchors.fill: parent
            anchors.margins: 8
            source: "file://" + wallpaperPath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            clip: true
            
            // Overlay gradient on hover
            Rectangle {
                anchors.fill: parent
                radius: 8
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, mouseArea.containsMouse ? 0.4 : 0) }
                }
                
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        // File name label at bottom
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8
            height: 30
            color: Qt.rgba(0, 0, 0, 0.7)
            radius: 6
            
            Text {
                anchors.centerIn: parent
                text: wallpaperFile
                color: "#FFFFFF"
                font.pixelSize: 11
                font.weight: Font.Medium
                elide: Text.ElideMiddle
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: {
                console.log("DEBUG qml: " + wallpaperPath)
                Qt.quit()
            }
        }
    }
}
