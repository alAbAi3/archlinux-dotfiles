
// modules/quickshell/launcher/AppDelegate.qml
import QtQuick 6.0
import "../theme"

Item {
    id: delegateRoot
    width: 120
    height: 110

    property string appName: ""
    property string appIcon: ""
    property string appCommand: ""

    Rectangle {
        id: background
        anchors.fill: parent
        color: mouseArea.containsMouse ? Qt.rgba(Colors.color4.r, Colors.color4.g, Colors.color4.b, 0.2) : "transparent"
        radius: 12
        border.color: mouseArea.containsMouse ? Colors.color4 : "transparent"
        border.width: 1
        
        scale: mouseArea.pressed ? 0.95 : 1.0
        
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { 
            NumberAnimation { 
                duration: 100 
                easing.type: Easing.OutCubic
            } 
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 10
        
        Image {
            id: appIconImage
            anchors.horizontalCenter: parent.horizontalCenter
            width: 48
            height: 48
            source: appIcon
            fillMode: Image.PreserveAspectFit
            smooth: true
            
            scale: mouseArea.containsMouse ? 1.1 : 1.0
            
            Behavior on scale { 
                NumberAnimation { 
                    duration: 150 
                    easing.type: Easing.OutCubic
                } 
            }
        }

        Text {
            id: appNameText
            anchors.horizontalCenter: parent.horizontalCenter
            width: delegateRoot.width - 10
            text: appName
            color: Colors.foreground
            font.pixelSize: 11
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            if (appCommand) {
                console.log(appCommand)
                Qt.quit()
            }
        }
    }
}
