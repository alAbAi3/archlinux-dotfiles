
// modules/quickshell/launcher/AppDelegate.qml
import QtQuick
import theme

Rectangle {
    id: delegateRoot
    width: 120
    height: 110
    color: "transparent"
    radius: 8

    property string appName: ""
    property string appIcon: ""
    property string appCommand: ""

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? Colors.color8 : "transparent"
        radius: 8
    }

    Image {
        id: appIconImage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 15
        width: 48
        height: 48
        source: appIcon
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: appNameText
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 15
        text: appName
        color: Colors.foreground
        font.bold: true
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
